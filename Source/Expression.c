#include "Scan.h"
#include "Load.h"
#include "Symbol.h"

// Expression parser, derived from the syntax:
// E -> E "?" E ":" E | E b E | u E | E p | f(E "," ... "," E)
// E -> "<-" E "," ... "," E | "->" E "," ... "," E
// E -> E "[" E "]" | "(" E ")" | constant | variable
// using the C-BC operator precedence rules to resolve ambiguities.

// The operator class stored in this table for the action table to use.
// bit 0: right associative, bits 1-4: precedence.
// 20 (,): ',', 40 (b): infix, postfix, '?'
static int OpTab[] = {
   0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 0, 0x34, 0, 0x41, 0, 0, 0, 0, 0,
   0x13, 0x53, 0x50, 0x4e, 0x0d, 0x4a, 0x46, 0x44, 0x43,
   0x01, 0x41, 0x49, 0x01, 0x01, 0x01,
   0, 0, 0, 0, 0, 0
};

// Contexts. The actions are stored by Context vs. Operator class.
typedef enum { BOT, COND, ARR, PAR, ARG, OUTP, INP, ELS, BIN, UN } Context;

char *Action[10] = {
// " ,b"
   "rss", // BOT:  Exp $
   "rss", // COND: Exp -> A? B $ : C
   "rss", // ARR:  Exp -> L[A $]
   "rss", // PAR:  Exp -> (A $ )
   "rrs", // ARG:  Exp -> f(A $ (, A)*)
   "rrs", // OUTP: Exp -> <- A $ (, A)*
   "rrs", // INP:  Exp -> -> L $ (, L)*
   "r??", // ELS:  Exp -> A? B: C $
   "r??", // BIN:  Exp -> A bin B $
   "r??"  // UN:   Exp -> un A $
};

// Stacks: (S)=main stack, (L)=lexical stack, (V)=value stack, (T)=type stack, (N)=auxiliary stack
// L, V, T, N hold values corresponding to subsets of the items on S.
// Expressions typed by normal humans don't get more than 16 (= 0x10) levels deep.
#define EXP_LEVELS 0x10
static Context SStack[EXP_LEVELS], *SP;
static Lexical LStack[EXP_LEVELS], *LP;
static int VStack[EXP_LEVELS], *VP;
static SType TStack[EXP_LEVELS], *TP;
static int NStack[EXP_LEVELS], *NP;
SType Type;

static void Raise(Context C) {
   if (SP - SStack >= EXP_LEVELS) Fatal("Expression too complex.");
   *SP++ = C;
}

static void TypeCheck(Lexical L, int Op, SType A, SType B) {
   if (Op == '^') {
      if (A == ZeroT) A = NumberT;
      if (B == ZeroT) B = NumberT;
   } else if (A == ComplexT && B == NumberT) B = ComplexT;
   else if (B == ZeroT && A != ZeroT)
      B = IsPointer(A) && (Op == '+' || Op == '-')? NumberT: A;
   else if (L != EQ_OP) {
      if (A == ZeroT) {
         if (B == ZeroT) B = NumberT;
         A = B;
      } else if (A == NumberT && B == ComplexT) A = ComplexT;
   }
   switch (L) {
      case COLON:
         if (A != B) Error("Type mismatch in a? b: c.");
         Type = A;
      break;
      case REL_OP:
         if (A != B) Error("Types mismatch ==, !=, <, >, <=, or >=.");
         else if (Op != '=' && Op != '#' && A != NumberT && A != StringT && !IsPointer(A))
            Error("Only numbers, strings, or pointers can be used with >, <, >=, <=.");
         Type = NumberT;
      break;
      case ADD_OP: case MUL_OP:
         if (Op == '+') {
            if (IsPointer(A) && B == NumberT) { Type = A; break; }
            else if (IsPointer(B) && A == NumberT) { Type = B; break; }
         } else if (Op == '-' && IsPointer(A)) {
            if (B == NumberT) { Type = A; break; }
            else if (B == A) { Type = NumberT; break; }
         }
         Type = A;
         if (A != B) Error("Incompatible types with '%c'.", Op);
         else if (!IsScalar(A)) Error("Only scalar types can be used with '%c'.", Op);
         else if (A == StringT) Error("Strings cannot be used with '%c'.", Op);
         else if (Op == '%' && A != NumberT) Error("Only numbers can be used with '%c'.", Op);
      break;
      case EXP_OP:
         Type = A;
         if (!IsScalar(A)) Error("Only scalar types can be used with '^'.");
         else if (A == StringT) Error("Strings cannot be used with '^'.");
         else if (B != NumberT) Error("Only numeric exponents allowed.");
      break;
      case EQ_OP:
         Type = A;
         if ((Op == '+' || Op == '-') && IsPointer(A) && B == NumberT) break;
         else if (Op != '^' && A != B || Op != '=' && !IsScalar(A)) {
            if (Op == '=') Error("Incompatible types with '='.");
            else Error("Incompatible types with '%c='.", Op);
         } else if (Op != '=' && A == StringT) Error("Strings cannot be used with '%c='.", Op);
         else if ((Op == '^' || Op == '%') && B != NumberT) Error("Only numbers can be used with '%c='.", Op);
      break;
   }
}

// HaveName: start parsing in the context E -> NAME $ x ... if true.
// NameParen: start parsing in the context E -> "(" $ ... if true.
// Name holds a copy of the string, and is "consumed" by Exp()
// Reference:
//    0 = printable value (any scalar value, except relationals and assignments)
//    1 = not printable
//    2 = l-expression
int HaveName, HaveParen, Reference;
char *Name;

// Expression parser:
// Each label is a state, each goto a state transition, contexts indicated next to each label.
// Example: NAME [x] (NAME x)\E means the following:
//    (1) [x] is the current token (L)
//    (2) NAME was parsed before x.
//    (3) (NAME x)\E denotes all those objects e, such that (NAME x e) is an expression.
void Exp(void) {
   Lexical L = LastL; int Y; char Act;
   SP = SStack, Raise(BOT);
   LP = LStack - 1, VP = VStack - 1, NP = NStack - 1, TP = TStack - 1;
   if (HaveName) { HaveName = 0; goto AtName; }
   else if (HaveParen) { HaveParen = 0; Raise(PAR); }
ExS: // [x] x\E
   switch (L) {
      case INPUT: Raise(INP), *++LP = L, *++NP = 0; L = Scan(); goto ExS;
      case OUTPUT: Raise(OUTP), *++LP = L, *++NP = 0; L = Scan(); goto ExS;
      case NOT: Raise(UN), *++LP = NOT; L = Scan(); goto ExS;
      case ADD_OP: Raise(UN), *++LP = SIGN_OP, *++VP = Value; L = Scan(); goto ExS;
      case NEW: case FREE: Raise(UN), *++LP = L; L = Scan(); goto ExS;
      case ADDR: Raise(UN), *++LP = ADDR, *++VP = '&'; L = Scan(); goto ExS;
      case MUL_OP:
         if (Value != '*') goto BAD_OP;
         Raise(UN), *++LP = ADDR, *++VP = '*'; L = Scan();
      goto ExS;
      case INC_OP: Raise(UN); *++LP = L, *++VP = Value; L = Scan(); goto ExS;
      case LPAR: Raise(PAR); L = Scan(); goto ExS;
      case NUMBER: Generate("[%s]", Text), Type = NumberT, Reference = 0; L = Scan(); goto ExF;
      case GALOIS: Generate("%s", Text), Type = GaloisT, Reference = 0; L = Scan(); goto ExF;
      case STRING:
         Generate("\"");
         do Generate("%s", Text), L = Scan(); while (L == STRING);
         Generate("\""), Type = StringT, Reference = 0;
      goto ExF;
      case ZERO: Generate("0", Text), Type = ZeroT, Reference = 0; L = Scan(); goto ExF;
      case NAME: Name = CopyS(Text); L = Scan(); goto AtName;
      default: BAD_OP: Error("Missing expression."); Generate("0"), Type = ZeroT, Reference = 0; goto ExF;
   }
AtName: // NAME [x] (NAME x)\E
   if (L == LPAR) {
      *++VP = LookUp(Name, FUNCTION, ++TP);
      L = Scan();
      if (L == RPAR) { *++NP = 0; goto FunctF; }
      Raise(ARG);
      *++NP = 1; goto ExS;
   } else if (L == LBR) {
      L = Scan();
      Generate(";%p", LookUp(Name, ARRAY, &Type));
      if (L == RBR) { Reference = 1; L = Scan(); goto ExF; }
      Raise(ARR); *++TP = Type;
      goto ExS;
   } else {
      Generate("&%p", LookUp(Name, VARIABLE, &Type));
      Reference = 2; goto ExF;
   }
ExF: // E [x] x\...
   Act = Action[*--SP][OpTab[L] >> 5];
   if (Act == '?') Act = ((OpTab[*LP]&0x1f) <= (OpTab[L]&0x1e))? 'r': 's';
   if (Reference == 2) { // Convert variable into value.
      if (
         Act == 's' && !(L == INC_OP || L == EQ_OP) ||
         Act == 'r' && !(
            *SP == PAR || *SP == INP ||
            *SP == UN && (*LP == INC_OP || *LP == NEW || *LP == FREE || *LP == ADDR && *VP == '&')
         )
      ) {
         Generate("l"), Reference = IsScalar(Type)? 0: 1;
      }
   }
   if (IsArray(Type)) { // Convert array into pointer.
      if (
         Act == 's' && !(L == LBR || L == INC_OP || L == EQ_OP) ||
         Act == 'r' && !(
            *SP == PAR ||
            *SP == UN && *LP == INC_OP ||
            *SP == ARG && IsArray(ParamType(*VP, *NP - 1)) ||
            *SP == BIN && *LP == EQ_OP && IsArray(*TP)
         )
      ) {
         Generate("0:"), Reference = 1, Type = PointerOf(Deref(Type));
      }
   }
   if (Act == 'r') goto ExQ;
// SHIFT: E [infix] E | E [?] E : E | E [postfix] ...
   SP++;
   switch (L) {
      case QUEST: Raise(COND), Generate("%Z", *++VP = Label()); break;
      case COMMA: Raise(BIN), Generate(","), *++LP = L; break;
      case OR: Raise(BIN), Generate("%N", *++VP = Label()), *++LP = L; break;
      case AND: Raise(BIN), Generate("%Z", *++VP = Label()), *++LP = L; break;
      case REL_OP: case ADD_OP: case MUL_OP: case EXP_OP:
         Raise(BIN), *++LP = L, *++TP = Type, *++VP = Value;
      break;
      case EQ_OP:
         Raise(BIN), *++LP = L, *++TP = Type, *++VP = Value;
         *++NP = Reference;
         if (Reference < 2) {
            if (Value == '=')
               Error("'=' requires variable."), Generate(",");
            else
               Error("'%c=' requires variable.", Value);
         } else if (Value != '=') Generate("d");
      break;
      case INC_OP:
         if (Reference < 2)
            Error("'%c%c' requires variable.", Value, Value);
         else {
            if (Type == StringT)
               Error("Strings cannot be used with '%c%c'.", Value, Value);
            else if (IsArray(Type))
               Error("Arrays cannot be used with '%c%c'.", Value, Value);
            Generate(Value == '+'? "a": "m");
         }
         Reference = 1; L = Scan();
      goto ExF;
      case LBR: Raise(ARR); *++TP = Type; break;
   }
   L = Scan();
goto ExS;
ExQ: // E [x] x\...
switch (*SP) {
   case BOT: return;
   case INP: case OUTP:
      if (*SP == INP) {
         if (*LP == INPUT) {
            if (Reference < 2) {
               *LP = 0; Error("'->' requires variables.");
            } else if (!IsScalar(Type)) {
               *LP = 0; Error("'->' can only read scalar values.");
            }
         }
         Generate(*LP == INPUT? "r": ",0");
      } else {
         if (*LP == OUTPUT && !IsScalar(Type)) {
            *LP = 0; Error("'<-' can only write scalar values.");
         }
         Generate(*LP == OUTPUT? "w": ",0");
      }
      if (++*NP >= 2) {
         if (*NP == 2) *++VP = Label();
         Generate("%Z1+", *VP);
      }
      if (L == COMMA) { L = Scan(); SP++; goto ExS; }
      LP--;
      if (*NP-- >= 2) Generate("%M", *VP--);
      Type = NumberT; Reference = 1;
   goto ExF;
   case COND:
      if (L != COLON) Error("Missing ':'."); else L = Scan();
      Generate("%J", Y = Label(), *VP);
      Raise(ELS), *++TP = Type, *VP = Y, *++LP = COLON;
   goto ExS;
   case ELS:
      TypeCheck(*LP--, ':', *TP--, Type);
      Generate("%M", *VP--); Reference = 1;
   goto ExF;
   case BIN:
      switch (*LP--) {
         case COMMA: break;
         case OR:
            Y = Label(); Generate("%N0%J1%M", *VP, Y, *VP, Y), VP--;
            Type = NumberT; Reference = 1;
         break;
         case AND:
            Y = Label(); Generate("%Z1%J0%M", *VP, Y, *VP, Y), VP--;
            Type = NumberT; Reference = 1;
         break;
         case REL_OP: case ADD_OP: case MUL_OP: case EXP_OP:
            TypeCheck(LP[1], *VP, *TP--, Type);
            Generate("%c", *VP--);
            Reference = (LP[1] == REL_OP || !IsScalar(Type))? 1: 0;
         break;
         case EQ_OP:
            TypeCheck(LP[1], *VP, *TP--, Type);
            if (*VP != '=') Generate("%c", *VP);
            VP--;
            if (*NP-- >= 2) Generate("s");
            Reference = 1;
         break;
      }
   goto ExF;
   case UN: switch (*LP--) {
      case NOT: Generate("!"); Type = NumberT; Reference = 1; break;
      case SIGN_OP:
         if (Type == StringT) Error("Strings cannot be used with '+' or '-'.");
         else if (!IsScalar(Type)) Error("Only scalars allows with prefix '+', '-'");
         if (*VP-- == '-') Generate("n");
         Reference = 0;
      break;
      case NEW: case FREE:
         if (!IsPointer(Type)) Error("'new', 'free' require pointers.");
         else if (Reference < 2) Error("'new', 'free' require variables.");
         else Generate(LP[1] == NEW? "N": "F");
         Reference = 1;
      break;
      case ADDR:
         if (*VP-- == '&') {
            if (Reference < 2) Error("'&' requires an addressible expression.");
            else { Type = PointerOf(Type); Reference = 1; }
         } else {
            if (!IsPointer(Type)) Error("'*' requires a pointer.");
            else { Type = Deref(Type); Reference = 2; }
         }
      break;
      case INC_OP:
         if (Reference < 2) {
            Error("'%c%c' requires variable.", *VP, *VP);
            Generate("1%c", *VP--);
         } else {
            if (Type == StringT)
               Error("Strings cannot be used with '%c%c'.", *VP, *VP);
            else if (IsArray(Type))
               Error("Arrays cannot be used with '%c%c'.", *VP, *VP);
            Generate("%c", *VP-- == '+'? 'A': 'M');
         }
         Reference = 1;
      break;
   }
   goto ExF;
   case PAR:
      if (L == RBR) { L = RPAR; Error("Expected ')', saw ']'."); }
      if (L != RPAR) Error("Missing ')'."); else L = Scan();
   goto ExF;
   case ARR:
      if (L == RPAR) { L = RBR; Error("Expected ']', saw ')'."); }
      if (L != RBR) Error("Missing ']'."); else L = Scan();
      if (Type != ZeroT && Type != NumberT)
         Error("Array indices must be numeric.");
      Type = *TP--;
      if (IsArray(Type)) {
         Generate(":"); Type = Deref(Type), Reference = 2;
      } else {
         Error("'x[...]' requires array type.");
         Generate(","); Reference = 1;
      }
   goto ExF;
   case ARG:
      if (FTab[*VP].Declared && *NP <= Arity(*VP)) {
         SType PType = ParamType(*VP, *NP - 1);
         if (Type == NumberT && PType == ComplexT || Type == ZeroT)
            Type = PType;
         else if (Type != PType)
            Error("Type mismatch, argument %d of %s().", *NP, FTab[*VP].Name);
      }
      if (L == COMMA) {
         SP++; (*NP)++; L = Scan(); goto ExS;
      } else if (L == RBR) { L = RPAR; Error("Expected ')', saw ']'."); }
   goto FunctF;
}
FunctF:
   if (L != RPAR) Error("Missing ')'."); else L = Scan();
   if (!FTab[*VP].Declared)
      Error("Function %s() not declared.", FTab[*VP].Name);
   else if (*NP != Arity(*VP))
      Error("%d parameter(s) expected in %s().", Arity(*VP), FTab[*VP].Name);
   Generate("x%p", *VP--); NP--;
   Type = *TP--; Reference = (IsScalar(Type))? 0: 1;
goto ExF;
}

#include "Scan.h"
#include "Load.h"
#include "Symbol.h"

// To declare exit() and EXIT_FAILURE
#include <stdlib.h>

extern void Exp(void);
extern char *Name;
extern SType Type;
extern int HaveName, HaveParen, Reference;
extern int FakeSemi;

#define LEVELS 20
typedef enum { BotS, WhileS, DoS, ForS, IfS, ElseS, GroupS } Context;

// Stacks: (S)=contexts, (X)=labels, (B)=breaks, (C)=continues
static Context SStack[LEVELS], *SP;
static int XStack[LEVELS], *XP;
static int BStack[LEVELS], *BP;
static int CStack[LEVELS], *CP;

static void Raise(Context Tag) {
   if (++SP >= SStack + LEVELS) Fatal("Statement too complex");
   *SP = Tag;
}

// True when one symbol ahead.
static int Ahead;

// Statement parser:
// Each label is a state, each goto a state transition, contexts indicated next to each label.
void Statement(void) {
   XP = XStack - 1, BP = BStack - 1, CP = CStack - 1, SP = SStack, *SP = BotS;
   HaveName = HaveParen = FakeSemi = 0, Ahead = 0;
   Lexical L = LastL;
   int X, Y; SType FType;
StS: // S -> x $ ...
   switch (L) {
      case Quit: exit(EXIT_FAILURE);
      case If:
         L = Scan();
         if (L != LPAR) Error("Missing '(' in 'if (...)'"); else Scan();
         Exp(); L = LastL;
         Raise(IfS); Generate("%Z", *++XP = Label());
         if (L != RPAR) Error("Missing ')' in 'if (...)'."); else L = Scan();
      goto StS;
      case Else: Error("'else' without if."); L = Scan(); goto StS;
      case While:
         Raise(WhileS);
         Generate("%M", *++CP = Label());
         L = Scan();
         if (L != LPAR) Error("Missing '(' in 'while (...)'"); else Scan();
         Exp(); L = LastL;
         if (L != RPAR) Error("Missing ')' in 'while (...)'."); else L = Scan();
         Generate("%Z", *++BP = Label());
      goto StS;
      case Do:
         Raise(DoS);
         Generate("%M", *++XP = Label()); *++CP = NO_LABEL; *++BP = Label();
         L = Scan();
      goto StS;
      case For:
         L = Scan();
         if (L != LPAR) Error("Missing '(' in 'for (...)'"); else L = Scan();
         if (L != SEMI) { Exp(); L = LastL; Generate(","); }
         if (L != SEMI) Error("Missing ';' in 'for (A;...)'"); else L = Scan();
         Raise(ForS);
         if (L != SEMI) {
            Generate("%M", X = Label()); Exp(); L = LastL;
         } else X = NO_LABEL;
         if (L != SEMI) Error("Missing ';' in 'for (A;B;...)'."); else L = Scan();
         *++BP = Label();
         if (L != RPAR) {
            Y = Label(), *++CP = Label();
            if (X != NO_LABEL) Generate("%B", Y, *BP, *CP); else Generate("%J", Y, *CP);
            Exp(); L = LastL;
            if (X != NO_LABEL) Generate(",%J", X, Y); else Generate(",%M", Y);
         } else {
            if (X != NO_LABEL) Generate("%Z", *BP); else Generate("%M", X = Label());
            *++CP = X;
         }
         if (L != RPAR) Error("Missing ')' in 'for(A;B;C)...'.");
         else L = Scan();
      goto StS;
      case Goto:
         FakeSemi = 1; L = Scan();
         if (L != NAME) Error("goto label missing.");
         else {
            Generate("%J", LookUp(CopyS(Text), LABEL, 0), Label());
            L = Scan();
         }
      goto StSem;
      case Continue:
         if (CP < CStack) Error("continue statement outside loop.");
         else {
            if (*CP == NO_LABEL) *CP = Label();
            Generate("%J", *CP, Label());
         }
         FakeSemi = 1; L = Scan();
      goto StSem;
      case Break:
         if (BP < BStack) Error("break statement outside loop.");
         else {
            if (*BP == NO_LABEL) *BP = Label();
            Generate("%J", *BP, Label());
         }
         FakeSemi = 1; L = Scan();
      goto StSem;
      case Return:
         FakeSemi = 1;
         L = Scan();
         if (L == LPAR) HaveParen = 1, L = Scan();
         if (L == (HaveParen? RPAR: SEMI)) {
            Generate("0"), Type = ZeroT;
            if (HaveParen) HaveParen = 0, L = Scan();
         } else Exp();
         FType = ReturnType();
         if (
            Type == NumberT && FType == ComplexT ||
            Type == ZeroT || FType == ZeroT ||
            Type == FType
         ) ; // The types are compatible.
         else Error("Type mismatch in return statement.");
         Generate("%r");
      goto StSem;
      case Dump: Generate("D"); FakeSemi = 1; L = Scan(); goto StSem;
      case Halt: Generate("%h"); FakeSemi = 1; L = Scan(); goto StSem;
      case LCURL:
         L = Scan();
         if (L == RCURL) { L = LastL = SEMI; goto StSem; } // {} = ;
         Raise(GroupS);
      goto StS;
      case RCURL: Error("Missing '{'"); LastL = SEMI; goto StSem;
      case LBR: Error("Extra '['."); L = Scan(); goto StS;
      case RBR: Error("Extra ']'."); L = Scan(); goto StS;
      case RPAR: Error("Extra ')'."); L = Scan(); goto StS;
      case Include: case Define: case Auto: case Log: case TYPE:
         Error("Reserved word not allowed in statements."); L = Scan();
      goto StS;
      case COLON: case SEMI: goto StSem;
      case NAME:
         Name = CopyS(Text); FakeSemi = 1;
         L = Scan();
         if (L == COLON) {
            Generate("%M", X = LookUp(Name, LABEL, 0));
            L = Scan(); goto StS;
         }
         HaveName = 1;
      default:
         FakeSemi = 1; Exp(); Generate(Reference? ",": "P");
      goto StSem;
   }
StSem: // -> S $ [;] ...
   FakeSemi = 0; L = LastL;
   if (L == COLON)
      Error("Expected ';', saw ':'."), L = SEMI;
   else if (L != SEMI) {
// Semi-colons can be deleted before }.
      if (L != RCURL) Error("Missing ';'");
      Ahead = 1;
   }
StF: // S -> ...$ x ... (if Ahead); S -> ...$ [;] (if !Ahead)
   switch (*SP--) {
      case BotS: return;
      case WhileS: case ForS: Generate("%J", *CP--, *BP--); goto StF;
      case DoS:
         if (*CP != NO_LABEL) Generate("%M", *CP);
         CP--;
         if (Ahead) Ahead = 0; else L = Scan();
         if (L != While) Error("Missing 'while' in do...while."); else L = Scan();
         if (L != LPAR) Error("Missing '(' in do...while (."); else L = Scan();
         Exp(); L = LastL;
         FakeSemi = 1;
         if (L != RPAR) Error("Missing ')' in do...while(...)");
         else L = Scan();
         Generate("%B", *XP--, *BP, *BP), BP--;
      goto StSem;
      case IfS:
         if (Ahead) Ahead = 0; else L = Scan();
         if (L == Else) {
            Generate("%J", Y = Label(), *XP); *XP = Y;
            *++SP = ElseS, L = Scan(); goto StS;
         } else Ahead = 1;
      case ElseS: Generate("%M", *XP--); goto StF;
      case GroupS:
         if (Ahead) Ahead = 0; else L = Scan();
         if (L == RCURL) { L = LastL = SEMI; goto StSem; }
         if (L == 0) { Error("Missing '}'."); Ahead = 1; goto StF; }
         ++SP;
      goto StS;
   }
}

// Declarator Syntax:
//    Dc = "(" Dc ")" | "*" Dc | Dc "[" "]" | Dc "(" [Par ("," Par)*] ")"
//    Par = [Type] Dc
typedef enum { BOT, PAR, POINT, FUNCT } DContext;
DContext DStack[LEVELS], *DP;
static void PushD(DContext Tag) {
   if (++DP >= DStack + LEVELS) Fatal("Declaration too complex");
   *DP = Tag;
}

void Declarator(Scope Mode, SType Type) {
   Lexical L = LastL; char *Name = 0, *FName = 0; SType FType = ZeroT;
   int FValid; Scope FMode; int Errs = Errors;
   unsigned long DS = 0; int LS = 0, NS = 0;
// DS = 2n + 1 ("array of n"), 2n + 2 ("pointer to n") or 0 (scalar).
   DP = DStack, *DP = BOT;
DcS:
   switch (L) {
      case LPAR: PushD(PAR); L = Scan(); goto DcS;
      case NAME: Name = CopyS(Text); L = Scan(); goto DcF;
      case MUL_OP:
         if (Value == '*') { PushD(POINT); L = Scan(); goto DcS; }
      default:
         Error("Missing variable name in declaration.");
      goto DcF;
   }
DcF:
   if (L == LPAR) {
      FValid = 0;
      if (Mode == ParamS || Mode == AutoS) Error("Cannot declare functions locally.");
      else if (DS) Error("Arrays of/pointers to functions not allowed.");
      else if (FType != ZeroT) Error("Functions cannot return functions.");
      else FValid = 1;
      FType = Type, FName = Name; Name = 0;
      L = Scan();
      if (L == RPAR) { L = Scan(); goto DcF; }
      FMode = Mode; Mode = ParamS;
      PushD(FUNCT);
      if (L == TYPE) Type = Value, L = Scan(); else Type = NumberT;
      goto DcS;
   } else if (L == LBR) {
      if (Mode == DefineS && DS == 0) {
         if (NS++ == 0) Error("Function must be declared with 'define'.");
      } else {
         if (++LS == LEVELS) Error("Declaration too complex.");
         DS = (DS << 1) + 1;
      }
      L = Scan();
      if (L == RBR) L = Scan(); else Error("Missing ']' in declaration.");
      goto DcF;
   } else switch (*DP--) {
      case BOT: goto DecS;
      case PAR:
         if (L == RPAR) L = Scan(); else Error("Missing ')' in declaration.");
      goto DcF;
      case POINT:
         if (Mode == DefineS && DS == 0) {
            if (NS++ == 0) Error("Function must be declared with 'define'.");
         } else {
            if (++LS == LEVELS) Error("Declaration too complex.");
            DS = (DS << 1) + 2;
         }
      goto DcF;
      case FUNCT:
         for (; DS > 0; DS = (DS - 1) >> 1)
            Type = (DS&1)? ArrayOf(Type): PointerOf(Type);
         if (FValid) DeclareVar(Name, Mode, Type);
         if (L == COMMA) {
            Name = 0; ++DP; L = Scan();
            if (L == TYPE) Type = Value, L = Scan(); else Type = NumberT;
            goto DcS;
         } else if (L == RPAR) L = Scan();
         else Error("Missing ')' in declaration.");
         Mode = FMode, Type = FType, Name = FName;
      goto DcF;
   }
DecS:
   for (; DS > 0; DS = (DS - 1) >> 1) Type = (DS&1)? ArrayOf(Type): PointerOf(Type);
   if (Mode == DefineS && FType == ZeroT) {
      Error("Missing parameters in function definition.");
      FType = Type;
   }
// Errs == Errors means no new errors in parsing the declarator.
   if (FType != ZeroT) {
      if (IsArray(Type)) Error("Functions cannot return arrays.");
      if (Errs == Errors) DeclareFunct(FName, Mode, FType);
      if (Mode != DefineS) ResetLocals();
   } else if (Errs == Errors) DeclareVar(Name, Mode, Type);
}

void Parse(char *Path) {
   Lexical L; SType Type;
   OpenF(Path);
   for (L = Scan(); L != 0; L = LastL) switch (L) {
      case Include:
         FakeSemi = 1; L = Scan();
         if (L != STRING) Error("Expected filename after 'include'.");
         StartLoad();
         Generate("\"");
         while (L == STRING) Generate("%s", Text), L = Scan();
         Generate("\"I");
         EndLoad(); Interpret();
         while (L != SEMI && L != 0) L = Scan();
         FakeSemi = 0; if (L == SEMI) L = Scan();
      break;
      case Log:
         FakeSemi = 1; L = Scan();
         if (L != STRING && L != SEMI)
            Error("Missing log file name or ';' after 'log'.");
         StartLoad();
         Generate("\"");
         while (L == STRING) Generate("%s", Text), L = Scan();
         Generate("\"L");
         EndLoad(); Interpret();
         while (L != SEMI && L != 0) L = Scan();
         FakeSemi = 0; if (L == SEMI) L = Scan();
      break;
      case TYPE:
         Type = Value; L = Scan();
         while (1) {
            FakeSemi = 1; Declarator(GlobalS, Type); FakeSemi = 0;
            L = LastL; if (L != COMMA) break; L = Scan();
         }
         if (L == SEMI) L = Scan(); else Error("Missing ';'.");
      break;
      case Define:
         L = Scan();
         if (L == TYPE) Type = Value, L = Scan(); else Type = NumberT;
         Declarator(DefineS, Type); L = LastL;
         SetAutos();
         if (L == LCURL) L = Scan(); else Error("Missing '{' in define.");
         while (L == Auto || L == TYPE) {
            if (L == Auto) L = Scan();
            if (L == TYPE) Type = Value, L = Scan(); else Type = NumberT;
            while (1) {
               FakeSemi = 1; Declarator(AutoS, Type); FakeSemi = 0;
               L = LastL; if (L != COMMA) break;
               L = Scan();
            }
            if (L == SEMI) L = Scan(); else Error("Missing ';'.");
         }
         StartLoad();
         while (L != RCURL && L != 0) {
            Statement();
            if (Ahead) Ahead = 0, L = LastL; else L = Scan();
         };
         Generate("0"); // Default return to catch fall-throughs.
         EndLoad(); DefineFunction(); ResetLocals();
         if (L == RCURL) Scan(); else Error("Missing '}'.");
      break;
      default:
         StartLoad(); Statement(); EndLoad(); Interpret();
         if (Ahead) Ahead = 0; else Scan();
      break;
   }
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "Scan.h"

#define LINE_MAX 0x100
char Text[LINE_MAX];
static char *U, *EndText = Text + (LINE_MAX - 1);
int Value, Line, FakeSemi;

// Synch: Used to synchronize \n and ; to the user.
static int Next, Synch;

#define INCLUDE_MAX 5
struct {
   char *Path; long Loc; int Next, Synch, Line;
} IS[INCLUDE_MAX], *ISP = IS - 1;
static FILE *InF = 0;
static char *CurF;

FILE *LogF = 0;
static inline void Skip(void) { // Pre-process out escaped new-lines.
   while (1) {
      Next = fgetc(InF);
      if (LogF != 0 && Next != EOF) fputc(Next, LogF);
      if (Next != '\\') break;
      Next = fgetc(InF);
      if (Next != '\n') {
         ungetc(Next, InF); Next = '\\';
         break;
      } else if (LogF != 0 && Next != EOF) fputc(Next, LogF);
   }
}

int Errors = 0;

void Error(const char *Format, ...) {
   if (CurF != NULL) printf("%s [%d] ", CurF, Line);
   va_list AP; va_start(AP, Format);
   vprintf(Format, AP); putchar('\n');
   va_end(AP);
   if (++Errors >= 40) printf("Too many errors.  Aborting.\n"), exit(1);
}

void Fatal(const char *Format, ...) {
   if (CurF != NULL) printf("%s [%d] ", CurF, Line);
   va_list AP; va_start(AP, Format);
   vprintf(Format, AP); putchar('\n');
   va_end(AP);
   exit(1);
}

void *Allocate(unsigned N) {
   if (N == 0) return NULL;
   void *X = malloc(N); if (X == NULL) Fatal("Out of memory.");
   return X;
}

void *Reallocate(void *X, unsigned N) {
// Should be realloc(X, N). Some ANSI compilers are still not ANSI.
   X = X == NULL? malloc(N): realloc(X, N);
   if (X == NULL) Fatal("Out of memory.");
   return X;
}

char *CopyS(char *S) {
   if (S == NULL) return NULL;
   char *NewS = Allocate(strlen(S) + 1);
   strcpy(NewS, S);
   return NewS;
}

void OpenF(char *Name) {
   if (ISP >= IS + INCLUDE_MAX) Fatal("Too many nested include files.");
   if (ISP >= IS) {
      if (CurF != NULL) {
         ISP->Loc = ftell(InF);
         if (ISP->Loc == -1L) Fatal("Could not save %s's position.", ISP->Path);
      }
      ISP->Next = Next, ISP->Synch = Synch, ISP->Line = Line, ISP->Path = CurF;
   }
   ISP++; CurF = CopyS(Name);
   Line = 1;
   InF = (Name == NULL? stdin: fopen(Name, "r"));
   if (InF == NULL) Fatal("Cannot open %s", Name);
   Synch = 1;
}

#define Insert(U, Ch) if ((U) < EndText) *(U)++ = (Ch)

static void Get(void) {
   if (Next == EOF) {
      while (Next == EOF && ISP > IS) {
         if (CurF != NULL) fclose(InF), free(CurF);
         ISP--;
         Next = ISP->Next, Synch = ISP->Synch, Line = ISP->Line;
         CurF = ISP->Path;
         if (CurF == NULL) InF = stdin;
         else {
            InF = fopen(CurF, "r");
            if (InF == NULL) Fatal("Cannot reopen %s", CurF);
            if (fseek(InF, ISP->Loc, SEEK_SET) != 0) {
               fclose(InF);
               Fatal("Could not restore %s's position.", CurF);
            }
         }
         if (Synch) {
            Synch = 0;
            if (Next != EOF) Skip();
         }
      }
      if (Next == EOF) ISP--, fclose(InF), Next = 0;
      Insert(U, ' ');
   } else {
      if (Next == '\n') Line++;
      Insert(U, Next); Skip();
   }
}

// A keyword hashing routine inspired by gperf.
// This could be generalized to group operators into word classes, as well.
static Lexical WordClass(char *S) {
   static struct Item {
      char *Key; Lexical Word; int Value;
   } KeyTab[] = {
// The original ordering prior to its conversion to a more hash-friendly form.
//    { "dump", Dump, 0 },
//    { "include", Include, 0 }, { "log", Log, 0 },
//    { "define", Define, 0 },   { "auto", Auto, 0 },   { "quit", Quit, 0 },
//    { "if", If, 0 },           { "else", Else, 0 },   { "while", While, 0 },
//    { "do", Do, 0 },           { "for", For, 0 },
//    { "goto", Goto, 0 },       { "break", Break, 0 }, { "return", Return, 0 },
//    { "halt", Halt, 0 },       { "continue", Continue, 0 },
//    { "number", TYPE, NumberT },     { "complex", TYPE, ComplexT },
//    { "galois", TYPE, GaloisT },     { "string",  TYPE, StringT },
//    { "new", NEW, 0 },               { "free", FREE, 0 }
      { "log", Log, 0 }, { "auto", Auto, 0 }, { "else", Else, 0 }, { "halt", Halt, 0 },
      { "break", Break, 0 }, { "quit", Quit, 0 }, { "while", While, 0 }, { "return", Return, 0 },
      { "string",  TYPE, StringT }, { "if", If, 0 }, { "new", NEW, 0 }, { "for", For, 0 },
      { "free", FREE, 0 }, { "number", TYPE, NumberT }, { "include", Include, 0 }, { "do", Do, 0 },
      { "goto", Goto, 0 }, { "dump", Dump, 0 }, { "galois", TYPE, GaloisT }, { "define", Define, 0 },
      { "complex", TYPE, ComplexT }, { "continue", Continue, 0 }
   };
   static int DeltaN[] = { -3, -1, +13, +13, -2, +8, +12, -1, +7, 0, 0, -3, 0, +7, 0, 0, +1, +1, +2, 0, 0, 0, +1 }; // Indexed for 'a' to 'w'.
   int dN, N = strlen(S); if (N < 2) return NAME;
   char Ch = S[0];
   if (Ch < 'a' || Ch > 'w' || (dN = DeltaN[Ch - 'a']) == 0) return NAME; else N += dN;
   if (N < 0 || N >= 'w' - 'a') return NAME;
   char *Key = KeyTab[N].Key;
   if (strcmp(Key, S) != 0) return NAME;
   else { Value = KeyTab[N].Value; return KeyTab[N].Word; }
}
Lexical LastL;
#define Ret(Token) return (*U = '\0', LastL = (Token))

Lexical Scan(void) {
Start:
   if (Synch) Synch = 0, U = Text, Get();
   U = Text;
   if (islower(Next) || Next == '_') {
      while (isalnum(Next) || Next == '_') Get();
      Ret(WordClass(Text));
   }
   if (isxdigit(Next) && !islower(Next)) {
      do Get(); while (isxdigit(Next) && !islower(Next));
      if (Next != '.') {
         if (*Text == '0' && U - Text == 1) Ret(ZERO);
         Ret(NUMBER);
      }
   }
   switch (Next) {
      case '.':
         Get();
         if (U - Text == 1) switch (Next) {
            case 'c': Get(); strcpy(Text, "lastc"); return LastL = NAME;
            case 's': Get(); strcpy(Text, "lasts"); return LastL = NAME;
            case 'g': Get(); strcpy(Text, "lastg"); return LastL = NAME;
            case 'n': Get();
            default:
               if (isxdigit(Next) && !islower(Next)) break;
               strcpy(Text, "last");
            return LastL = NAME;
         }
         while (isxdigit(Next) && !islower(Next)) Get();
      Ret(NUMBER);
      case '$':
         do Get(); while (isalnum(Next));
         if (Next == '$') Get(); else Insert(U, '$');
      Ret(GALOIS);
      case '\n': NewLine:
         Synch = 1;
         if (!FakeSemi) goto Start;
      Ret(SEMI);
      case ';': Synch = 1; Ret(SEMI);
      case '/': switch (Get(), Next) {
         case '/':
            while (Next != '\n') {
               if (Next == EOF) Fatal("Unexpected EOF inside // comment.");
               Skip();
            }
         goto NewLine;
         case '*': {
            Skip();
            while (Next != EOF) {
               if (Next == '*') {
                  while (Next == '*') Skip();
                  if (Next == '/') { Skip(); goto Start; }
               } else {
                  if (Next == '\n') Line++;
                  Skip();
               }
            }
            Fatal("Unexpected EOF inside comment.");
         }
         case '=': Value = '/'; Get(); Ret(EQ_OP);
         default: Value = '/'; Ret(MUL_OP);
      }
      case '"':
         Skip();
         while (Next != '\"') {
            if (Next == EOF) Fatal("Unexpected EOF inside string.");
            else if (Next == '\n') Line++;
            else if (Next == '\\') Get();
            Get();
         }
         Skip();
      Ret(STRING);
      case '<': switch (Get(), Next) {
	 case '=': Get(); Value = '{'; Ret(REL_OP);
         case '-': Get(); Ret(OUTPUT);
         default: Value = '<'; Ret(REL_OP);
      }
      case '>': switch (Get(), Next) {
	 case '=': Get(); Value = '}'; Ret(REL_OP);
	 default: Value = '>'; Ret(REL_OP);
      }
      case '&': switch (Get(), Next) {
	 case '&': Get(); Ret(AND);
	 default: Ret(ADDR);
      }
      case '|': switch (Get(), Next) {
	 case '|': Get(); Ret(OR);
	 default: Error("Incomplete || operator."); Ret(OR);
      }
      case '=': switch (Get(), Next) {
	 case '=': Get(); Value = '='; Ret(REL_OP);
         case '+': case '-': case '*': case '/': case '%': case '^':
            Value = Next; Get();
         Ret(EQ_OP);
	 default: Value = '='; Ret(EQ_OP);
      }
      case '!': switch (Get(), Next) {
	 case '=': Get(); Value = '#'; Ret(REL_OP);
	 default: Ret(NOT);
      }
      case '^': Value = Next; Get();
         if (Next == '=') { Get(); Ret(EQ_OP); }
      Ret(EXP_OP);
      case '*': case '%': Value = Next; Get();
         if (Next == '=') { Get(); Ret(EQ_OP); }
      Ret(MUL_OP);
      case '+': Value = '+'; Get();
         if (Next == '=') { Get(); Ret(EQ_OP); }
         else if (Next == '+') { Get(); Ret(INC_OP); }
      Ret(ADD_OP);
      case '-': Value = '-'; Get();
         if (Next == '=') { Get(); Ret(EQ_OP); }
         else if (Next == '>') { Get(); Ret(INPUT); }
         else if (Next == '-') { Get(); Ret(INC_OP); }
      Ret(ADD_OP);
      case ',': Get(); Ret(COMMA);
      case ':': Get(); Ret(COLON);
      case '?': Get(); Ret(QUEST);
      case '[': Get(); Ret(LBR);
      case ']': Get(); Ret(RBR);
      case '{': Get(); Ret(LCURL);
      case '}': Get(); Ret(RCURL);
      case '(': Get(); Ret(LPAR);
      case ')': Get(); Ret(RPAR);
      case 0: Ret(0);
      default: Get(); goto Start;
   }
}

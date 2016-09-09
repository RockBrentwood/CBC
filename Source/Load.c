#include <stdarg.h>
#include <stdlib.h>
#include "Scan.h"
#include "Load.h"
#include "Symbol.h"
#include "Execute.h"

// Actually, this points to the return statement.
#define NO_LABEL 0

#define LAB_MAX 0x400
static struct State LList[LAB_MAX], *LP, *CurP;

void CheckLabel(char *Name, int Addr) {
   if (Addr < 0 || Addr >= LAB_MAX || LList[Addr].Continue == 0) Error("Label %s undefined.", Name);
}

void PurgeStates(void) {
   for (State Q = LList; Q < LP; Q++) free(Q->Continue);
}

void StoreStates(State *Head, State *Tail) {
   State FH = Allocate((LP - LList)*sizeof *FH);
   *Head = FH, *Tail = FH + (LP - LList);
   State FQ = FH;
   for (State Q = LList; Q < LP; FQ++, Q++)
      FQ->TB = FH + (Q->TB - LList),
      FQ->FB = FH + (Q->FB - LList),
      FQ->Continue = Q->Continue;
}

void FreeStates(State Head, State Tail) {
   for (State Q = Head; Q < Tail; Q++) free(Q->Continue);
   free(Head);
}

static char CBuf[0x2000], *CP;

static void SaveBuf(State Q) {
   char *S = Allocate(CP - CBuf);
   for (int I = 0; I < CP - CBuf; I++) S[I] = CBuf[I];
   Q->Continue = S;
}

static void GenByte(char B) {
   if (CP >= CBuf + sizeof CBuf) Fatal("Program too complex.");
   *CP++ = B;
}

int Label(void) {
   if (LP >= LList + LAB_MAX) Fatal("Program too complex.");
   LP->TB = LP->FB = NULL, LP->Continue = NULL;
   return LP++ - LList;
}

// This routine is actually just a filter to remove control flow operations
// by converting control flow semantics into continuation semantics.
void Generate(char *Format, ...) {
   va_list AP; va_start(AP, Format);
   int X, Y, Q;
   for (char *S = Format; *S != '\0'; S++)
      if (*S != '%') GenByte(*S);
      else switch (*++S) {
         case 's': {
            char *T = va_arg(AP, char *);
            if (T != NULL) for (; *T != '\0'; T++) GenByte(*T);
         }
         break;
         case 'p': {
            unsigned P = va_arg(AP, unsigned);
            GenByte((byte)(P&0xff)), GenByte((byte)((P >> 8)&0xff));
         }
         break;
         case 'c': GenByte((char)va_arg(AP, int)); break;
      // Return
         case 'r': X = Y = 0, Q = Label(); goto Branch;
      // Halt
         case 'h': CurP->TB = CurP->FB = NULL, Q = Label(); goto Mark;
      // Mark Q:
         case 'M': X = Y = Q = va_arg(AP, int); goto Branch;
      // Jump-Zero Y:
         case 'Z': Y = va_arg(AP, int), X = Q = Label(); goto Branch;
      // Jump-Nonzero X:
         case 'N': X = va_arg(AP, int), Y = Q = Label(); goto Branch;
      // Jump X; Mark Q:
         case 'J': X = Y = va_arg(AP, int), Q = va_arg(AP, int); goto Branch;
      // Jump X, or Y; Mark Q:
         case 'B':
            X = va_arg(AP, int), Y = va_arg(AP, int), Q = va_arg(AP, int);
         Branch:
            CurP->TB = &LList[X], CurP->FB = &LList[Y];
         Mark:
            GenByte(0); SaveBuf(CurP);
            CurP = &LList[Q], CP = CBuf;
         break;
      }
   va_end(AP);
}

void EndLoad(void) { // Load in a final return.
   GenByte(0); SaveBuf(CurP);
   CurP->TB = CurP->FB = &LList[0];
   FreeLabels();
}

void StartLoad(void) {
// Label 0 is the return label, label 1 is the entry point.
   LP = LList; Errors = 0;
   Label(); CurP = LP; Label();
   CP = CBuf;
}

void Interpret(void) {
   if (Errors == 0) SetStacks(), Execute(LList, LP);
   PurgeStates();
}

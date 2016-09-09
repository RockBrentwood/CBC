#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "Scan.h"
#include "Load.h"
#include "Symbol.h"

static Tree Form(int Leaf) {
   Tree T = Allocate(sizeof *T);
   if (Leaf)
      for (int I = 0; I < 0x10; I++) T->Leaf[I] = NULL;
   else
      for (int I = 0; I < 0x10; I++) T->Branch[I] = NULL;
   return T;
}

array NewArray(SType Type) {
   static unsigned LABEL = 0;
   array A = Allocate(sizeof *A);
   static char Buf[6]; sprintf(Buf, "#%04x", LABEL++); LABEL &= 0xffff;
   A->Addr = 0, A->Name = CopyS(Buf), A->Type = ArrayOf(Type);
   A->Ref = A->Next = NULL, A->Root = NULL;
   return A;
}

variable GetPointer(array A, unsigned Offset) {
   unsigned N = Offset;
   if (A == NULL) return NULL;
   Tree *TP = &A->Root;
   if (*TP == NULL) *TP = Form(0); TP = &(*TP)->Branch[(N >> 12)&0xf];
   if (*TP == NULL) *TP = Form(0); TP = &(*TP)->Branch[(N >> 8)&0xf];
   if (*TP == NULL) *TP = Form(0); TP = &(*TP)->Branch[(N >> 4)&0xf];
   if (*TP == NULL) *TP = Form(1);
   variable *VP = &(*TP)->Leaf[N&0xf];
   if (*VP == NULL) {
      variable V = Allocate(sizeof *V);
      V->Name = NULL, V->Addr = -1L, V->Next = NULL, V->Type = Deref(A->Type);
      V->Base = A, V->Offset = Offset;
      *VP = V;
      switch (V->Type) {
         case ZeroT: break;
         case NumberT: V->Val.N = Num0(); break;
         case ComplexT: V->Val.C = Com0(); break;
         case GaloisT: Unit(V->Val.G, 0); break;
         case StringT: V->Val.S = CopyS(""); break;
         default:
            if (IsPointer(V->Type))
               V->Val.V = NULL;
            else
               V->Val.A = NewArray(Deref(V->Type)), *V->Val.A->Name = '@';
         break;
      }
   }
   return *VP;
}

// FreeArray & FreeTree are mutually recursive.
void FreeArray(array A);

static void FreeTree(Tree T) {
   static int Level = 0;
   if (T == NULL) return;
   if (++Level < 4)
      for (int I = 0; I < 0x10; I++) FreeTree(T->Branch[I]);
   else
      for (int I = 0; I < 0x10; I++) {
         variable V = T->Leaf[I]; if (V == NULL) continue;
         switch (V->Type) {
            case ZeroT: case GaloisT: break;
            case NumberT: Delete(V->Val.N); break;
            case ComplexT: DeleteC(V->Val.C); break;
            case StringT: free(V->Val.S); break;
            default:
               if (IsArray(V->Type)) FreeArray(V->Val.A);
            break;
         }
         free(V);
      }
   Level--; free(T);
}

void FreeArray(array A) { FreeTree(A->Root), free(A->Name); free(A); }

Function FTab = NULL; int Fs = 0;

static variable *VTab = NULL;
static array *ATab = NULL;
static int Vs = 0, As = 0, FMax = 0, VMax = 0, AMax = 0;

variable GetVar(unsigned Addr) { return VTab[Addr]; }
array GetArr(unsigned Addr) { return ATab[Addr]; }

// Variable/Array Stacking Mechanism: Local variables are stacked when they come into scope.

// Make new variable or array node.
static void PushVar(Arg P, char *Name) {
   if (IsArray(P->Type)) {
      array A = Allocate(sizeof *A);
      A->Next = ATab[P->Addr], A->Type = P->Type;
      if (A->Next == NULL)
         A->Name = Name, A->Addr = P->Addr;
      else
         A->Name = A->Next->Name, A->Addr = -1L;
      A->Ref = NULL; ATab[P->Addr] = A;
   } else {
      variable V = Allocate(sizeof *V);
      V->Next = VTab[P->Addr], V->Type = P->Type;
      if (V->Next == NULL)
         V->Name = Name, V->Addr = P->Addr;
      else
         V->Name = V->Next->Name, V->Addr = -1L;
      V->Base = NULL, V->Offset = 0; VTab[P->Addr] = V;
   }
}

// Remove old variable or array node.
static void PopVar(Arg P) {
   if (IsArray(P->Type)) {
      array A = ATab[P->Addr], Next;
      if (A == NULL) return;
      Next = A->Next, free(A), ATab[P->Addr] = Next;
   } else {
      variable V = VTab[P->Addr], Next;
      if (V == NULL) return;
      Next = V->Next, free(V), VTab[P->Addr] = Next;
   }
}

void NewVar(Arg P, ...) {
   PushVar(P, NULL);
   array A; variable V;
   if (IsArray(P->Type)) A = ATab[P->Addr]; else V = VTab[P->Addr];
   va_list AP; va_start(AP, P);
   switch (P->Type) {
      case NumberT: V->Val.N = va_arg(AP, number); break;
      case ComplexT: V->Val.C = va_arg(AP, complex); break;
      case GaloisT: CopyG(V->Val.G, va_arg(AP, void *)); break;
      case StringT: V->Val.S = va_arg(AP, char *); break;
      default:
         if (IsPointer(P->Type)) V->Val.V = va_arg(AP, variable);
         else if (IsArray(P->Type)) {
            A->Ref = va_arg(AP, array);
            A->Root = A->Ref == NULL? NULL: A->Ref->Root;
         }
      break;
   }
   va_end(AP);
}

void FreeVar(Arg P) {
   if (IsArray(P->Type)) {
      array A = ATab[P->Addr];
      if (A == NULL) return;
      else if (A->Ref == NULL) FreeTree(A->Root);
      else A->Ref->Root = A->Root;
   } else {
      variable V = VTab[P->Addr];
      if (V == NULL) return;
      else switch (V->Type) {
         case NumberT: Delete(V->Val.N); break;
         case ComplexT: DeleteC(V->Val.C); break;
         case GaloisT: break;
         case StringT: free(V->Val.S); break;
      }
   }
   PopVar(P);
}

#define HASH_SIZE 0x10
typedef struct Node *Node;
struct Node { char *Name; unsigned Addr; Node Next; };
static Node VHash[HASH_SIZE], AHash[HASH_SIZE], FHash[HASH_SIZE], LHash[HASH_SIZE];

void FreeLabels(void) {
   for (Node *NP = LHash; NP < LHash + HASH_SIZE; NP++)
      while (*NP != NULL) {
         Node L = *NP; *NP = L->Next;
         CheckLabel(L->Name, L->Addr);
         free(L);
      }
}

static Node Find(char *Name, SymTag Tag) {
// Name is "consumed" by Find(). It must be a copy created by CopyS().
   if (Name == NULL) return NULL;
   int H = 0;
   for (char *S = Name; *S != '\0'; H += *S++);
   H %= HASH_SIZE;
   Node *NP;
   switch (Tag) {
      case FUNCTION: NP = FHash + H; break;
      case ARRAY: NP = AHash + H; break;
      case VARIABLE: NP = VHash + H; break;
      case LABEL: NP = LHash + H; break;
   }
   for (Node N = *NP; N != NULL; N = N->Next)
      if (strcmp(N->Name, Name) == 0) { free(Name); return N; }
   Node N = Allocate(sizeof *N);
   N->Name = Name; N->Next = *NP, *NP = N;
   switch (Tag) {
      case FUNCTION: {
         if (Fs >= FMax) FMax += 0x20, FTab = Reallocate(FTab, FMax*sizeof *FTab);
         Function F = FTab + Fs;
         F->Defined = F->Declared = 0, F->Name = Name, F->Type = NumberT;
         F->PP = F->Params = NULL, F->AP = F->Autos = NULL;
         N->Addr = Fs++;
      }
      break;
      case ARRAY:
         if (As >= AMax) AMax += 0x20, ATab = Reallocate(ATab, AMax*sizeof *ATab);
         ATab[As] = NULL, N->Addr = As++;
      break;
      case VARIABLE:
         if (Vs >= VMax) VMax += 0x20, VTab = Reallocate(VTab, VMax*sizeof *VTab);
         VTab[Vs] = NULL, N->Addr = Vs++;
      break;
      case LABEL: N->Addr = Label(); break;
   }
   return N;
}

#define MAX_LOCALS 0x100
static struct Arg Locals[MAX_LOCALS], *AP = Locals, *PP;
static Function Proto = NULL; // The function last prototyped
static int Forward = 0; // Proto was forward declared

void SetAutos(void) { PP = AP; }

void ResetLocals(void) {
   Proto = NULL;
   for (Arg LP = Locals; LP < AP; LP++) PopVar(LP);
   AP = Locals;
}

void DeclareVar(char *Name, Scope Mode, SType Type) {
   Node N = Find(Name, IsArray(Type)? ARRAY: VARIABLE);
   if (N == NULL) return; // DeclareVar(NULL, M, T) is a null action.
   Name = N->Name;
   if (Mode != GlobalS) {
      for (Arg LP = Locals; LP < AP; LP++) if (LP->Addr == N->Addr)
         if (IsArray(LP->Type) && IsArray(Type)) {
            Error("%s[] already declared as a local array.", Name); return;
         } else if (!IsArray(LP->Type) && !IsArray(Type)) {
            Error("%s already declared as a local variable.", Name); return;
         }
      if (AP >= Locals + MAX_LOCALS) Fatal("Too many local variables.");
      AP->Type = Type, AP->Addr = N->Addr, PushVar(AP++, Name);
   } else {
      struct Arg P; P.Type = Type, P.Addr = N->Addr;
      if (IsArray(Type)) {
         if (ATab[N->Addr] == NULL) {
            NewVar(&P, (array)NULL);
            ATab[N->Addr]->Name = Name;
         } else if (ATab[N->Addr]->Type != Type)
            Error("Array %s[] already declared.", Name);
      } else {
         if (VTab[N->Addr] == NULL) {
            switch (Type) {
               case GaloisT: NewVar(&P, Gal0); break;
               case NumberT: NewVar(&P, Num0()); break;
               case ComplexT: NewVar(&P, Com0()); break;
               case StringT: NewVar(&P, CopyS("")); break;
               default:
                   if (IsPointer(Type)) NewVar(&P, (variable)NULL);
               break;
            }
            VTab[N->Addr]->Name = Name;
         } else if (VTab[N->Addr]->Type != Type)
            Error("Variable %s already declared.", Name);
      }
   }
}

int MatchFunction(Function F, SType Type) {
   if (F->Type != Type) return 0;
   if (AP - Locals != F->PP - F->Params) return 0;
   Arg FP = F->Params;
   for (Arg LP = Locals; LP < AP; FP++, LP++) if (FP->Type != LP->Type) return 0;
   return 1;
}

void DeclareFunct(char *Name, Scope Mode, SType Type) {
   if (Name == NULL) return;
   Node N = Find(Name, FUNCTION);
   Function F = FTab + N->Addr;
   Forward = (Mode == DefineS && F->Declared);
   if (!F->Declared) {
      F->Declared = 1, F->Type = Type;
      if (AP > Locals) {
         Arg FP = F->Params = Allocate((AP - Locals)*sizeof *F->Params);
         F->PP = F->Params + (AP - Locals);
         for (Arg LP = Locals; LP < AP; FP++, LP++) FP->Type = LP->Type;
      }
   } else if (!MatchFunction(F, Type)) {
      Error("Attempted to redeclare function %s().", F->Name); F = NULL;
   }
   Proto = F;
}

static void InitFunction(char *Name, SType Type, char *Types) {
// DeclareFunction(Name, Type);
   Node N = Find(CopyS(Name), FUNCTION);
   Function F = FTab + N->Addr;
   F->Declared = 1, F->Type = Type;
// DefineFunction();
   int Args = strlen(Types);
   F->Defined = 2;
   F->Params = Allocate(Args*sizeof *F->Params);
   F->PP = F->Params + Args;
   F->AP = F->Autos = NULL;
   Arg FP = F->Params;
   for (char *TP = Types; *TP != '\0'; FP++, TP++) {
      FP->Addr = 0;
      switch (*TP) {
         case 'G': FP->Type = ArrayOf(GaloisT); break;
         case 'g': FP->Type = GaloisT; break;
         case 'C': FP->Type = ArrayOf(ComplexT); break;
         case 'c': FP->Type = ComplexT; break;
         case 'S': FP->Type = ArrayOf(StringT); break;
         case 's': FP->Type = StringT; break;
         case 'N': FP->Type = ArrayOf(NumberT); break;
         default: FP->Type = NumberT; break;
      }
   }
   F->Start = F->End = NULL;
}

static void NoMemory(char *Msg) { Fatal(Msg); }

void BuiltIns(void) {
   extern void Put1(char *S, ...);
   MemFailGP = MemFailNP = NoMemory, PutGP = PutNP = Put1;
   DeclareVar("ibase", GlobalS, NumberT);
   DeclareVar("obase", GlobalS, NumberT);
   DeclareVar("scale", GlobalS, NumberT);
   DeclareVar("last", GlobalS, NumberT);
   DeclareVar("lastc", GlobalS, ComplexT);
   DeclareVar("lastg", GlobalS, GaloisT);
   DeclareVar("lasts", GlobalS, StringT);
   InitFunction("sqrt", NumberT, "n");
   InitFunction("scale", NumberT, "n");
   InitFunction("length", NumberT, "n");
   InitFunction("shell", NumberT, "s");
   InitFunction("ifile", NumberT, "s");
   InitFunction("ofile", NumberT, "s");
   InitFunction("afile", NumberT, "s");
   InitFunction("comp", ComplexT, "nn");
   InitFunction("re", NumberT, "c");
   InitFunction("im", NumberT, "c");
   InitFunction("field", NumberT, "nnN");
   InitFunction("gal_p", NumberT, "");
   InitFunction("gal_m", NumberT, "");
   InitFunction("gal_gx", NumberT, "N");
   InitFunction("gal_set", GaloisT, "nN");
   InitFunction("gal_get", NumberT, "gN");
}

int LookUp(char *Name, SymTag Tag, SType *TypeP) {
   Node N = Find(Name, Tag);
   if (TypeP != NULL) switch (Tag) {
      case FUNCTION: {
         Function F = FTab + N->Addr;
         *TypeP = !F->Declared? NumberT: F->Type;
      }
      break;
      case ARRAY:
         if (ATab[N->Addr] == NULL) {
            struct Arg P; P.Addr = N->Addr, P.Type = ArrayOf(NumberT), NewVar(&P, (array)NULL);
            ATab[N->Addr]->Name = N->Name;
         }
         *TypeP = ATab[N->Addr]->Type;
      break;
      case VARIABLE:
         if (VTab[N->Addr] == NULL) {
            struct Arg P; P.Addr = N->Addr, P.Type = NumberT, NewVar(&P, Num0());
            VTab[N->Addr]->Name = N->Name;
         }
         *TypeP = VTab[N->Addr]->Type;
      break;
   }
   return N->Addr;
}

int Arity(unsigned Addr) {
   Function F = &FTab[Addr];
   return (F->Params == NULL)? 0: F->PP - F->Params;
}

SType ParamType(unsigned Addr, int N) {
   Function F = &FTab[Addr];
   if (!F->Declared || N >= F->PP - F->Params || N < 0) return NumberT;
   return F->Params[N].Type;
}

SType ReturnType(void) {
   return (Proto == NULL)? ZeroT: Proto->Type;
}

void DefineFunction(void) {
   if (Errors > 0 || Proto == NULL) {
   // Undo the prototype in absence of forward declarations.
      if (Proto != NULL && !Forward) Proto->Declared = 0, free(Proto->Params);
      PurgeStates();
   } else {
   // Allow redefinitions with the same prototype.
      if (Proto->Defined) free(Proto->Autos), FreeStates(Proto->Start, Proto->End);
      else Proto->Defined = 1;
      if (PP > Locals) {
         Arg FP = Proto->Params;
         for (Arg LP = Locals; LP < PP; FP++, LP++) FP->Addr = LP->Addr;
      }
      if (AP > PP) {
         Arg FP = Proto->Autos = Allocate((AP - PP)*sizeof *Proto->Autos);
         Proto->AP = Proto->Autos + (AP - PP);
         for (Arg LP = PP; LP < AP; FP++, LP++) FP->Addr = LP->Addr, FP->Type = LP->Type;
      }
      StoreStates(&Proto->Start, &Proto->End);
   }
}

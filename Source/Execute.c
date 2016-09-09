#include <stdarg.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "Scan.h"
#include "Load.h"
#include "Symbol.h"
#include "Execute.h"

typedef char *string;

static unsigned GalBuf[GSIZE + 1]; // Used for galois field operations.
static char *PC; // The current location counter.
static State Start, Q, End; // The first, current and last states.

// The largest array component + 1
#define ARRAY_SIZE 0x10000

// I/O FUNCTIONS
static int Get1(void) { return PC == NULL? EOF: *PC == '\0'? '\0': *PC++; }
static void UnGet1(int Ch) { *--PC = Ch; }

static FILE *InF = NULL, *ExF = NULL;

void InitIOFiles(void) { InF = stdin, ExF = stdout; }

static int PCol = 0;
void Put1(char *Format, ...) {
   static char PBuf[0x40], *PP = PBuf;
   va_list AP; va_start(AP, Format); vsprintf(PBuf, Format, AP); va_end(AP);
   int L = strlen(PBuf);
   if ((PCol += L) >= 80) {
      char Ch = *(PP += 79 + L - PCol);
      *PP = '\0'; fprintf(ExF, PBuf); *PP = Ch;
      PCol -= 79;
      fprintf(ExF, "\\\n%s", PP);
   } else fprintf(ExF, PBuf);
}

static void PutStr(int Escape, char *S) {
// Print S, after processing escapes if Escape == 1.
   for (; *S != '\0'; S++)
      if (*S != '\\') fputc(*S, ExF);
      else if (!Escape) fputc(*++S, ExF);
      else switch(*++S) {
         case '\0': break;
         case 'a': fputc('\a', ExF); break;
         case 'b': fputc('\b', ExF); break;
         case 't': fputc('\t', ExF); break;
         case 'n': fputc('\n', ExF); break;
         case 'v': fputc('\v', ExF); break;
         case 'f': fputc('\f', ExF); break;
         case 'r': fputc('\r', ExF); break;
         case 'e': fputc('\x1b', ExF); break;
         default: fputc(*S, ExF); break;
      }
}

static int Get2(void) {
   int Ch;
   while ((Ch = fgetc(InF)) == '\\')
      if ((Ch = fgetc(InF)) != '\n') { ungetc(Ch, InF), Ch = '\\'; break; }
   return Ch;
}

static void UnGet2(int Ch) { ungetc(Ch, InF); }

static string ReadStr(void) {
   char *A = PC;
   for (; *PC != '\"' && *PC != '\0'; PC++) if (*PC == '\\') PC++;
   char Ch = *PC; *PC = '\0';
   string S = CopyS(A);
   if (Ch != '\0') *PC++ = Ch;
   return S;
}

static string GetStr(void) {
   static char SBuf[0x1000];
   static const size_t StrMax = sizeof SBuf/sizeof SBuf[0];
   int I = 0;
   for (; I < StrMax; I++) {
      int Ch = fgetc(InF);
      if (Ch == EOF || Ch == '\n' || Ch == '\0') break;
      SBuf[I] = Ch;
   }
   if (I >= StrMax) I = StrMax - 1;
   SBuf[I] = '\0';
   return CopyS(SBuf);
}

// Execution functions:
// Subsidiary:
//    Push(T, ...) -------- Example, Push(NumberT, N) pushes number N.
//    Pop() --------------- Releases stack item.
//    Increment(V, Dir) --- V++ or V-- if Dir > 0 or Dir < 0.
//    Dump() -------------- Displays the stack (TODO: may allow this to be redirected to a string).
// Main operations          Effect on stack             Action
//    Call(F) ------------- x1...xn -> ...              { execute function F(x1...xn) }
//    Ret() --------------- ...     -> y                { return value y from F() }
//    Write(N) ------------ ... X   -> ... success code { write X (N = 1 -> newline) }
//    Negate() ------------ ... X   -> ... -X
//    PushFlag(F) --------- ...     -> ... F
//    F = PopFlag() ------- ... F   -> ...
//    Memory(Make) -------- ... P   -> ... P            { Make? allocate P: deallocate P }
//    ArrayIndex() -------- ... AX: -> ... &A[X]
//    PushArray(N) -------- ...     -> ... aN[]
//    PushVariable(N) ----- ...     -> ... &vN
//    Duplicate() --------- ... X   -> ... X *X
//    Load(Op) ------------ ... X   -> ... *X           { operate on X } (Op ... l: X, a: X++, m: X--, A: ++X, M: --X)
//    Exponent() ---------- ... X Y -> ... X^Y
//    Modulus() ----------- ... X Y -> ... X%Y
//    Multiplication() ---- ... X Y -> ... X*Y
//    Division() ---------- ... X Y -> ... X/Y
//    Addition() ---------- ... X Y -> ... X + Y
//    Subtraction() ------- ... X Y -> ... X - Y
//    Equality(Op) -------- ... X Y -> ... X Op Y (Op: = is ==, # is !=)
//    Relational(Op) ------ ... X Y -> ... X Op Y (Op: <, >, { is <=, } is >=)
//    Read() -------------- ... X   -> ... success code { X = read() }
//    Store() ------------- ... X Y -> ... Y            { X = Y }

#define MAX_DEPTH 0x40
static struct variable Stack[MAX_DEPTH], *SP;

static void Push(SType Type, ...) {
   if (++SP >= Stack - 1 + MAX_DEPTH) Fatal("Stack full.");
   SP->Type = Type;
   va_list AP; va_start(AP, Type);
   switch (Type) {
      case ZeroT: break;
      case GaloisT: CopyG(SP->Val.G, va_arg(AP, void *)); break;
      case NumberT: SP->Val.N = va_arg(AP, number); break;
      case ComplexT: SP->Val.C = va_arg(AP, complex); break;
      case StringT: SP->Val.S = va_arg(AP, string); break;
      default:
          if (IsArray(Type))
             SP->Val.A = va_arg(AP, array);
          else
             SP->Val.V = va_arg(AP, variable);
      break;
   }
   va_end(AP);
}

static void PushFlag(int Flag) {
   Push(NumberT, Flag? Num1(): Num0());
}

static void Pop(void) {
   switch (SP->Type) {
      case NumberT: Delete(SP->Val.N); break;
      case ComplexT: DeleteC(SP->Val.C); break;
      case StringT: free(SP->Val.S); break;
   }
   SP--;
}

static void Convert(SType B, variable V) {
   if (V == NULL) return;
   SType A = V->Type;
   if (A == NumberT && B == ComplexT) V->Type = ComplexT, V->Val.C = ComplexC(V->Val.N, Num0());
   else if (A == ZeroT) switch (V->Type = B) {
      case ZeroT: break;
      case NumberT: V->Val.N = Num0(); break;
      case ComplexT: V->Val.C = Com0(); break;
      case GaloisT: CopyG(V->Val.G, Gal0); break;
      case StringT: V->Val.S = CopyS(""); break;
      default:
         if (IsArray(B)) V->Val.A = NULL; else V->Val.V = NULL;
      break;
   }
}

#define CHECK(N) if (SP < Stack + (N) - 1) Fatal("Empty stack.")
#define BAD_TYPE Fatal("Internal type-checking error.")
#define CONVERT2(V, W) \
   Convert((V)->Type, (W)), Convert((W)->Type, (V)); \
   if ((V)->Type != (W)->Type) BAD_TYPE

static int DoScale(void) {
   SetNum(&SP->Val.N, NumLong(SP->Val.N->Scale));
   return 1;
}

static int DoLength(void) {
   SetNum(&SP->Val.N, NumLong(SP->Val.N->Scale + SP->Val.N->Digits));
   return 1;
}

static int DoSqrt(void) {
   number N = RootNum(SP->Val.N);
   if (N == NULL) { Error("Square root of negative number."); return 0; }
   SetNum(&SP->Val.N, N);
   return 1;
}

static int DoComp(void) {
   complex C = ComplexC(CopyNum((SP - 1)->Val.N), CopyNum(SP->Val.N));
   Pop(), Pop(), Push(ComplexT, C); return 1;
}

static int DoRe(void) {
   number N = CopyNum(SP->Val.C.X);
   Pop(), Push(NumberT, N); return 1;
}

static int DoIm(void) {
   number N = CopyNum(SP->Val.C.Y);
   Pop(), Push(NumberT, N); return 1;
}

static int DoInFile(void) {
   char *S = SP->Val.S;
   FILE *FP = S == NULL || *S == '\0'? stdin: fopen(S, "r");
   Pop();
   if (FP == NULL) PushFlag(0);
   else {
      if (InF != stdin) fclose(InF);
      InF = FP, PushFlag(1);
   }
   return 1;
}

static int DoExFile(int Append) {
   char *S = SP->Val.S;
   FILE *FP = S == 0 || *S == '\0'? stdout: fopen(S, Append? "a": "w");
   Pop();
   if (FP == NULL) PushFlag(0);
   else {
      if (ExF != stdout) fclose(ExF);
      ExF = FP, PushFlag(1);
   }
   return 1;
}

static int DoShell(void) {
   int Status = system(SP->Val.S);
   Pop(); PushFlag(Status == 0); return 1;
}

static int DoField(void) {
   array A = SP->Val.A;
   long D = Long((SP - 1)->Val.N), P = Long((SP - 2)->Val.N);
   if (D > GSIZE + 1) D = GSIZE + 1;
   Pop(), Pop(), Pop();
   if (P >= 0x10000L) P = 0x10000L;
   for (unsigned I = 0; I < D; I++) {
      variable V = GetPointer(A, I);
      GalBuf[I] = (unsigned)(Long(V->Val.N)%P);
   }
   SetField((unsigned)P, (unsigned)D, GalBuf);
   Push(NumberT, NumLong(gal_error)); return 1;
}

static int DoGx(void) {
   unsigned D = ResidueG(GalBuf);
   array A = SP->Val.A;
   Pop();
   for (unsigned I = 0; I < D; I++) {
      variable V = GetPointer(A, I);
      SetNum(&V->Val.N, NumLong(GalBuf[I]));
   }
   Push(NumberT, NumLong(D)); return 1;
}

static int DoDegree(void) { Push(NumberT, NumLong(DegreeG())); return 1; }

static int DoPrime(void) { Push(NumberT, NumLong(PrimeG())); return 1; }

static int DoGalSet(void) {
   array A = SP->Val.A; unsigned Deg = DegreeG();
   long D = Long((SP - 1)->Val.N); if (D >= Deg) D = Deg - 1;
   galois G; CopyG(G, Gal0);
   unsigned I = 0;
   for (; I <= D; I++) {
       variable V = GetPointer(A, I);
       long L = Long(V->Val.N); if (L == BIG_NUM) L = 0;
       SetN(G, I, L);
   }
   for (; I < Deg; I++) SetN(G, I, 0L);
   Pop(), Pop(), Push(GaloisT, G); return 1;
}

static int DoGalGet(void) {
   array A = SP->Val.A; unsigned Deg = DegreeG();
   galois G; CopyG(G, (SP - 1)->Val.G);
   for (unsigned I = 0; I < Deg; I++) {
       variable V = GetPointer(A, I);
       SetNum(&V->Val.N, NumLong(GetN(G, I)));
   }
   Pop(), Pop(); Push(NumberT, NumLong(Deg)); return 1;
}

// ibase is always treated as a parameter in BC.
typedef struct Frame *Frame;
struct Frame {
   Function F; State Start, Q, End; char *PC; int IBase;
} *FrTab = NULL;
static int Frames = 0, FrMax = 0;

static int Call(unsigned Addr) {
   Function F = &FTab[Addr]; int Size = SP - Stack + 1;
   if (!F->Defined) { Error("%s() not defined.", F->Name); return 0; }
   if (Size < F->PP - F->Params) { Error("%s(): missing parameters.", F->Name); return 0; }
   if (F->Params != 0) {
      int V = 0; Arg A = F->PP - 1;
      for (; A >= F->Params; V--, A--) {
         Convert(A->Type, &SP[V]);
         if (A->Type != SP[V].Type) {
            Error("%s(), parameter %d, type mismatch.", F->Name, A - F->Params + 1);
            return 0;
         }
      }
   }
   switch (Addr) {
      case ScaleA: return DoScale();
      case LengthA: return DoLength();
      case SqrtA: return DoSqrt();
      case CompA: return DoComp();
      case ReA: return DoRe();
      case ImA: return DoIm();
      case IFileA: return DoInFile();
      case OFileA: return DoExFile(0);
      case AFileA: return DoExFile(1);
      case ShellA: return DoShell();
      case FieldA: return DoField();
      case GxA: return DoGx();
      case DegreeA: return DoDegree();
      case PrimeA: return DoPrime();
      case GalSetA: return DoGalSet();
      case GalGetA: return DoGalGet();
   }
   if (F->Autos != 0) for (Arg A = F->AP - 1; A >= F->Autos; A--)
      switch (A->Type) {
         case NumberT: NewVar(A, Num0()); break;
         case ComplexT: NewVar(A, Com0()); break;
         case GaloisT: NewVar(A, Gal0); break;
         case StringT: NewVar(A, CopyS("")); break;
         default:
            if (IsArray(A->Type)) NewVar(A, (array)NULL);
            else if (IsPointer(A->Type)) NewVar(A, (variable)NULL);
         break;
      }
   if (F->Params != 0) for (Arg A = F->PP - 1; A >= F->Params; A--, Pop())
      switch (A->Type) {
         case NumberT: NewVar(A, CopyNum(SP->Val.N)); break;
         case ComplexT: NewVar(A, CopyC(SP->Val.C)); break;
         case GaloisT: NewVar(A, SP->Val.G); break;
         case StringT: NewVar(A, CopyS(SP->Val.S)); break;
         default:
            if (IsArray(A->Type)) NewVar(A, SP->Val.A);
            else if (IsPointer(A->Type)) NewVar(A, SP->Val.V);
         break;
      }
   if (Frames >= FrMax) FrMax += 4, FrTab = (Frame)Reallocate(FrTab, FrMax*sizeof *FrTab);
   FrTab[Frames].F = F, FrTab[Frames].PC = PC, FrTab[Frames].IBase = IBase,
   FrTab[Frames].Start = Start, FrTab[Frames].Q = Q, FrTab[Frames].End = End,
   Start = F->Start, End = F->End;
   Frames++;
   return 2;
}

static void Ret(void) {
   Frames--;
   End = FrTab[Frames].End, Q = FrTab[Frames].Q, Start = FrTab[Frames].Start,
   IBase = FrTab[Frames].IBase, PC = FrTab[Frames].PC;
   Function F = FrTab[Frames].F;
   for (Arg A = F->Autos; A < F->AP; A++) FreeVar(A);
   for (Arg A = F->Params; A < F->PP; A++) FreeVar(A);
}

static void CopyVar(variable V, variable W) {
   switch (W->Addr) {
      case IBaseAddr: V->Type = NumberT, V->Val.N = NumLong(IBase); break;
      case OBaseAddr: V->Type = NumberT, V->Val.N = NumLong(OBase); break;
      case ScaleAddr: V->Type = NumberT, V->Val.N = NumLong(Scale); break;
      default:
         *V = *W;
         switch (V->Type) {
            case NumberT: V->Val.N = CopyNum(V->Val.N); break;
            case ComplexT: V->Val.C = CopyC(V->Val.C); break;
            case StringT: V->Val.S = CopyS(V->Val.S); break;
         }
      break;
   }
}

static void Write(int NL) {
   CHECK(1);
   PCol = 0;
   variable V;
   switch (SP->Type) {
      case ZeroT: Put1("0"); break;
      case NumberT:
         PutNum(SP->Val.N);
         V = GetVar(LastAddr); SetNum(&V->Val.N, CopyNum(SP->Val.N));
      break;
      case ComplexT:
         PutC(SP->Val.C);
         V = GetVar(LastCAddr); SetC(&V->Val.C, CopyC(SP->Val.C));
      break;
      case GaloisT:
         PutGal(SP->Val.G);
         V = GetVar(LastGAddr); CopyG(V->Val.G, SP->Val.G);
      break;
      case StringT:
         PutStr(!NL, SP->Val.S);
         V = GetVar(LastSAddr); free(V->Val.S), V->Val.S = CopyS(SP->Val.S);
      break;
      default: BAD_TYPE;
   }
   Pop();
   if (!NL) PushFlag(1);
   else if (SP->Type != StringT) Put1("\n");
}

static int PopFlag(void) {
   CHECK(1);
   int Flag;
   switch (SP->Type) {
      case ZeroT: Flag = 0; break;
      case NumberT: Flag = !IsZero(SP->Val.N); break;
      case ComplexT: Flag = !ZeroC(SP->Val.C); break;
      case GaloisT: Flag = !ZeroG(SP->Val.G); break;
      case StringT: Flag = (SP->Val.S != NULL && *SP->Val.S != '\0'); break;
      default: Flag = IsPointer(SP->Type)? SP->Val.V != NULL: SP->Val.A != NULL; break;
   }
   Pop(); return Flag;
}

static void Negate(void) {
   CHECK(1);
   switch (SP->Type) {
      case ZeroT: break;
      case ComplexT: SetC(&SP->Val.C, NegC(SP->Val.C)); break;
      case NumberT: SetNum(&SP->Val.N, NegNum(SP->Val.N)); break;
      case GaloisT: NegG(SP->Val.G); break;
      default: BAD_TYPE;
   }
}

static unsigned GetAddr(void) {
   unsigned U = *PC++;
   return U + (*PC++ << 8);
}

static void IncludeFile(void) {
   if (SP->Type != StringT) BAD_TYPE;
   OpenF(SP->Val.S); Pop();
}

static void LogFile(void) {
   if (SP->Type != StringT) BAD_TYPE;
   if (SP->Val.S == NULL || *SP->Val.S == '\0') {
      if (LogF == NULL) Error("Log file already closed.");
      else {
         fputc('\n', LogF); fclose(LogF); LogF = NULL;
         printf("Log file closed.\n");
      }
   } else {
      if (LogF != NULL) Error("Log file already opened.");
      else {
         LogF = fopen(SP->Val.S, "a");
         if (LogF == NULL) Error("Could not open log file %s.\n", SP->Val.S);
         else printf("Log file opened as %s.\n", SP->Val.S);
      }
   }
}

static int Memory(int Make) {
   CHECK(1);
   if (!IsPointer(SP->Type)) BAD_TYPE;
   variable V = SP->Val.V;
   if (V == NULL) { Error("Attempted access to null pointer."); return 0; }
   if (!IsPointer(V->Type)) BAD_TYPE;
   variable W = V->Val.V;
   if (Make? W != NULL: W == NULL) { *SP = *V; return 1; }
   array A;
   if (Make) A = NewArray(Deref(Deref(SP->Type))), V->Val.V = GetPointer(A, 0);
   else {
      unsigned Offset = W->Offset;
      A = W->Base;
      if (A == NULL || *A->Name != '#') {
         Error("Attempted to free static memory."); return 0;
      } else if (Offset != 0) {
         Error("Attempted to free memory from middle of dynamic array.");
         return 0;
      }
      FreeArray(A); V->Val.V = NULL;
   }
   *SP = *V; return 1;
}

static int ArrayIndex(void) {
   CHECK(1);
   long L;
   switch (SP->Type) {
      case ZeroT: L = 0L; break;
      case NumberT: L = Long(SP->Val.N); break;
      default: BAD_TYPE;
   }
   Pop();
   array A;
   if (!IsArray(SP->Type)) BAD_TYPE; else A = SP->Val.A;
   Pop();
   if (A == NULL) { Error("Attempted to access null array."); return 0; }
   if (L >= MAX_STORE) { Error("Array index too large."); return 0; }
   variable V = GetPointer(A, (unsigned)L);
   Push(PointerOf(V->Type), V); return 1;
}

static void PushArray(unsigned Addr) {
   array A = GetArr(Addr);
   if (A == NULL) Push(ZeroT); else Push(A->Type, A);
}

static void PushVariable(unsigned Addr) {
   variable V = GetVar(Addr);
   if (V == NULL) Push(ZeroT); else Push(PointerOf(V->Type), V);
}

static int AddPointer(variable P, long Offset) {
   if (Offset == 0) return 1;
   variable V = P->Val.V; if (V == NULL) { Error("Attempted access to null-pointer."); return 0; }
   array A = V->Base; if (A == NULL) { Error("Attempted pointer arithmetic on non-array pointer."); return 0; }
   if ((Offset += V->Offset) < 0 || Offset >= MAX_STORE) { Error("Out of bounds array access."); return 0; }
   P->Val.V = GetPointer(A, (unsigned)Offset); return 1;
}

static int Increment(variable V, int Dir) {
   Dir = Dir < 0? -1: +1;
   switch (V->Addr) {
      case IBaseAddr:
         if ((IBase += Dir) > 0x10) {
            Error("ibase cannot exceed 16."); IBase = 0x10; return 0;
         } else if (IBase < 2) {
            Error("ibase cannot be less than 2."); IBase = 2; return 0;
         }
      break;
      case OBaseAddr:
         if ((OBase += Dir) > BIG_NUM) {
            Error("obase cannot exceed %ld.", BIG_NUM); OBase = BIG_NUM;
            return 0;
         } else if (OBase < 2) {
            Error("obase cannot be less than 2."); OBase = 2; return 0;
         }
      break;
      case ScaleAddr:
         if ((Scale += Dir) < 0) {
            Error("scale cannot be negative."); Scale = 0; return 0;
         }
      break;
      default: switch (V->Type) {
         case ZeroT: Error("Attempted access to null-pointer."); return 0;
         case GaloisT: IncG(V->Val.G, Dir); break;
         case NumberT: SetNum(&V->Val.N, IncNum(V->Val.N, Dir)); break;
         case ComplexT: SetC(&V->Val.C, IncC(V->Val.C, Dir)); break;
         default: return AddPointer(V, Dir);
      }
      break;
   }
   return 1;
}

static void Duplicate(void) {
   CHECK(1);
   if (!IsPointer(SP->Type)) BAD_TYPE;
   if (++SP >= Stack - 1 + MAX_DEPTH) Fatal("Stack full.");
   CopyVar(SP, SP[-1].Val.V);
}

static int Load(char Op) {
   CHECK(1);
   if (!IsPointer(SP->Type)) BAD_TYPE;
   variable V = SP->Val.V;
   Pop();
   if (V == NULL) { Error("Attempted to access null pointer."); return 0; }
   if (Op != 'l' && (IsArray(V->Type) || V->Type == StringT)) BAD_TYPE;
   if (Op == 'A' && !Increment(V, +1)) return 0;
   else if (Op == 'M' && !Increment(V, -1)) return 0;
   CopyVar(++SP, V);
   if (Op == 'a' && !Increment(V, +1)) return 0;
   else if (Op == 'm' && !Increment(V, -1)) return 0;
   return 1;
}

static int Exponent(void) {
   CHECK(2);
   number E;
   switch (SP->Type) {
      case ZeroT: E = Num0(); break;
      case NumberT: E = CopyNum(SP->Val.N); break;
      default: BAD_TYPE;
   }
   Pop();
   switch (SP->Type) {
      case ZeroT:
         SP->Type = NumberT, SP->Val.N = Num0();
      case NumberT:
         NumError = 0;
         SetNum(&SP->Val.N, ExpNum(SP->Val.N, E));
         if (NumError) {
            if (NumError == NUM_INFINITY) Error("Zero divide.");
            else Error("Exponent too big.");
            return 0;
         }
      break;
      case ComplexT:
         NumError = 0;
         SetC(&SP->Val.C, ExpC(SP->Val.C, E));
         if (NumError) {
            if (NumError == NUM_INFINITY) Error("Zero divide.");
            else Error("Exponent too big.");
            return 0;
         }
      break;
      case GaloisT: {
         long L = Long(E);
         if (L >= BIG_NUM) { Error("Exponent too big."); return 0; }
         if (!ExpG(SP->Val.G, (int)L)) { Error("Zero divide."); return 0; }
      }
      break;
      default: BAD_TYPE;
   }
   return 1;
}

static int Modulus(void) {
   CHECK(2);
   switch (SP->Type) {
      case ZeroT: Error("Remainder by 0."); return 0;
      case NumberT: break;
      default: BAD_TYPE;
   }
   switch ((SP - 1)->Type) {
      case ZeroT:
         (SP - 1)->Type = NumberT, (SP - 1)->Val.N = Num0();
      case NumberT: break;
      default: BAD_TYPE;
   }
   number N = ModNum((SP - 1)->Val.N, SP->Val.N);
   if (N == NULL) { Error("Remainder by 0."); return 0; }
   Pop(), Pop(); Push(NumberT, N); return 1;
}

static int Division(void) {
   CHECK(2);
   variable V = SP - 1;
   if (!IsScalar(SP->Type) || SP->Type == StringT) BAD_TYPE;
   if (!IsScalar(V->Type) || V->Type == StringT) BAD_TYPE;
   CONVERT2(SP, V);
   switch (SP->Type) {
      case GaloisT: {
         galois G;
         if (!DivG(G, V->Val.G, SP->Val.G)) { Error("Zero divide."); return 0; }
         Pop(), Pop(), Push(GaloisT, G);
      }
      break;
      case ComplexT: {
         NumError = 0;
         complex C = DivC(V->Val.C, SP->Val.C);
         if (NumError) { Error("Zero divide."); return 0; }
         Pop(), Pop(), Push(ComplexT, C);
      }
      break;
      case NumberT: {
         number N = DivNum(V->Val.N, SP->Val.N);
         if (N == NULL) { Error("Zero divide."); return 0; }
         Pop(), Pop(), Push(NumberT, N);
      }
      break;
      case ZeroT: Error("Zero divide."); return 0;
   }
   return 1;
}

static int Multiplication(void) {
   CHECK(2);
   variable V = SP - 1;
   if (!IsScalar(SP->Type) || SP->Type == StringT) BAD_TYPE;
   if (!IsScalar(V->Type) || V->Type == StringT) BAD_TYPE;
   CONVERT2(SP, V);
   switch (SP->Type) {
      case ZeroT: Pop(); break;
      case NumberT: {
         number N = MulNum(V->Val.N, SP->Val.N);
         Pop(), Pop(), Push(NumberT, N);
      }
      break;
      case ComplexT: {
         complex C = MulC(V->Val.C, SP->Val.C);
         Pop(), Pop(), Push(ComplexT, C);
      }
      break;
      case GaloisT: {
         galois G; MulG(G, V->Val.G, SP->Val.G);
         Pop(), Pop(), Push(GaloisT, G);
      }
      break;
   }
   return 1;
}

static int Addition(void) {
   CHECK(2);
   variable V = SP - 1;
   if (IsPointer(SP->Type)) {
      if (V->Type != NumberT && V->Type != ZeroT) BAD_TYPE;
      if (V->Type == NumberT && !AddPointer(SP, Long(V->Val.N))) return 0;
      variable W = SP->Val.V; SType Type = SP->Type;
      Pop(), Pop(); Push(Type, W);
      return 1;
   }
   if (IsPointer(V->Type)) {
      if (SP->Type != NumberT && SP->Type != ZeroT) BAD_TYPE;
      if (SP->Type == NumberT && !AddPointer(V, Long(SP->Val.N))) return 0;
      variable W = V->Val.V; SType Type = V->Type;
      Pop(), Pop(); Push(Type, W);
      return 1;
   }
   if (!IsScalar(SP->Type) || SP->Type == StringT) BAD_TYPE;
   if (!IsScalar(V->Type) || V->Type == StringT) BAD_TYPE;
   CONVERT2(SP, V);
   switch (SP->Type) {
      case ZeroT: Pop(); break;
      case NumberT: {
         number N = AddNum(V->Val.N, SP->Val.N);
         Pop(), Pop(), Push(NumberT, N);
      }
      break;
      case ComplexT: {
         complex C = AddC(V->Val.C, SP->Val.C);
         Pop(), Pop(), Push(ComplexT, C);
      }
      break;
      case GaloisT: {
         galois G; CopyG(G, V->Val.G), AddG(G, SP->Val.G);
         Pop(), Pop(), Push(GaloisT, G);
      }
      break;
   }
   return 1;
}

static int Subtraction(void) {
   CHECK(2);
   variable V = SP - 1;
   if (IsPointer(V->Type)) {
      if (IsPointer(SP->Type)) {
         variable W = SP->Val.V;
         if ((V = V->Val.V) == NULL && W == NULL) Pop(), Pop(), PushFlag(0);
         else if (V == NULL || W == NULL) {
            Error("Attempted pointer arithmetic on null pointer.");
            return 0;
         } else {
            array A = W->Base, B = V->Base;
            if (A != B) {
               Error("Attempted pointer arithmetic on incompatible pointers.");
               return 0;
            }
            long Offset = (long)V->Offset - (long)W->Offset;
            Pop(), Pop(), Push(NumberT, NumLong(Offset));
         }
      } else {
         if (SP->Type != ZeroT && !AddPointer(V, -Long(SP->Val.N))) return 0;
         variable W = V->Val.V; SType Type = V->Type;
         Pop(), Pop(); Push(Type, W);
      }
      return 1;
   }
   if (!IsScalar(SP->Type) || SP->Type == StringT) BAD_TYPE;
   if (!IsScalar(V->Type) || V->Type == StringT) BAD_TYPE;
   CONVERT2(SP, V);
   switch (SP->Type) {
      case ZeroT: Pop(); break;
      case NumberT: {
         number N = SubNum(V->Val.N, SP->Val.N);
         Pop(), Pop(), Push(NumberT, N);
      }
      break;
      case ComplexT: {
         complex C = SubC(V->Val.C, SP->Val.C);
         Pop(), Pop(), Push(ComplexT, C);
      }
      break;
      case GaloisT: {
         galois G; CopyG(G, V->Val.G), SubG(G, SP->Val.G);
         Pop(), Pop(), Push(GaloisT, G);
      }
      break;
   }
   return 1;
}

static void Equality(char Op) {
   CHECK(2);
   variable V = SP - 1; CONVERT2(SP, V);
   int Equal = 0;
   switch (SP->Type) {
      case ZeroT: Equal = 1; break;
      case NumberT: Equal = CompNum(V->Val.N, SP->Val.N) == 0; break;
      case ComplexT: Equal = EqualC(V->Val.C, SP->Val.C); break;
      case GaloisT: Equal = EqualG(V->Val.G, SP->Val.G); break;
      case StringT: Equal = strcmp(V->Val.S, SP->Val.S) == 0; break;
      default: Equal = IsPointer(V->Type)? V->Val.V == SP->Val.V: V->Val.A == SP->Val.A; break;
   }
   if (Op == '#') Equal = !Equal;
   Pop(), Pop(), PushFlag(Equal);
}

static void Relational(char Op) {
   CHECK(2);
   switch (SP->Type) {
      case ZeroT:
         SP->Type = NumberT, SP->Val.N = Num0();
      case NumberT: case StringT: break;
      default:
         if (!IsPointer(SP->Type)) BAD_TYPE;
      break;
   }
   variable V = SP - 1;
   switch (V->Type) {
      case ZeroT:
         V->Type = NumberT, V->Val.N = Num0();
      case NumberT: case StringT: break;
      default:
         if (!IsPointer(V->Type)) BAD_TYPE;
      break;
   }
   if (SP->Type != V->Type) BAD_TYPE;
   int Diff = 0;
   switch (SP->Type) {
      case ZeroT: Diff = 0; break;
      case NumberT: Diff = CompNum(V->Val.N, SP->Val.N); break;
      case StringT: Diff = strcmp(V->Val.S, SP->Val.S); break;
      default: {
         variable VA = SP->Val.V, VB = V->Val.V;
         if (VA == NULL || VB == NULL) {
            Pop(), Pop();
            PushFlag(VA == NULL && VB == NULL && (Op == '{' || Op == '}'));
            return;
         } else {
            array A = VA->Base, B = VB->Base;
            if (A != B) { Pop(), Pop(), PushFlag(0); return; }
            Diff = VB->Offset < VA->Offset? -1: VB->Offset > VA->Offset? +1: 0;
         }
      }
      break;
   }
   Pop(), Pop();
   switch (Op) {
      case '<': PushFlag(Diff < 0); break;
      case '{': PushFlag(Diff <= 0); break;
      case '>': PushFlag(Diff > 0); break;
      case '}': PushFlag(Diff >= 0); break;
   }
}

static int StoreVar(variable V, number N) {
   switch (V->Addr) {
      case IBaseAddr:
         IBase = Long(N), Delete(N);
         if (IBase > 0x10) {
            Error("ibase cannot exceed 16."); IBase = 0x10; return 0;
         } else if (IBase < 2) {
            Error("ibase cannot be less than 2."); IBase = 2; return 0;
         }
      break;
      case OBaseAddr:
         OBase = Long(N), Delete(N);
         if (OBase > BIG_NUM) {
            Error("obase cannot exceed %ld.", BIG_NUM); OBase = BIG_NUM;
            return 0;
         } else if (OBase < 2) {
            Error("obase cannot be less than 2."); OBase = 2; return 0;
         }
      break;
      case ScaleAddr:
         Scale = Long(N), Delete(N);
         if (Scale < 0) {
            Error("scale cannot be negative."); Scale = 0; return 0;
         }
      break;
      default: SetNum(&V->Val.N, N); break;
   }
   return 1;
}

static int Read(void) {
   CHECK(1);
   if (!IsPointer(SP->Type)) BAD_TYPE;
   variable V = SP->Val.V;
   Pop();
   int R;
   switch (V->Type) {
      case GaloisT: R = GetGal(V->Val.G); break;
      case NumberT: {
         UnGetNP = UnGet2, GetNP = Get2, NumError = 0;
         number N = GetNum(); R = (N != NULL);
         if (R && !StoreVar(V, N)) return 0;
      }
      break;
      case ComplexT: {
         UnGetNP = UnGet2, GetNP = Get2, NumError = 0;
         complex C = GetC(); R = !NumError;
         if (R) SetC(&V->Val.C, C);
      }
      break;
      case StringT: free(V->Val.S); V->Val.S = GetStr(), R = 1; break;
      default: BAD_TYPE;
   }
   PushFlag(R); return 1;
}

static int Store(void) {
   CHECK(2);
   if (!IsPointer((SP - 1)->Type)) BAD_TYPE;
   variable V = (SP - 1)->Val.V;
   if (V == NULL) { Error("Attempted access to null pointer."); return 0; }
   Convert(V->Type, SP); if (SP->Type != V->Type) BAD_TYPE;
   switch (SP->Type) {
      case ZeroT: break;
      case NumberT: if (!StoreVar(V, CopyNum(SP->Val.N))) return 0; break;
      case ComplexT: SetC(&V->Val.C, CopyC(SP->Val.C)); break;
      case GaloisT: CopyG(V->Val.G, SP->Val.G); break;
      case StringT: free(V->Val.S), V->Val.S = CopyS(SP->Val.S); break;
      default:
         if (IsArray(SP->Type)) V->Val.A = SP->Val.A;
         else V->Val.V = SP->Val.V;
      break;
   }
   V->Type = SP->Type;
   Pop(), Pop(), CopyVar(++SP, V);
   return 1;
}

// Execution machine
// The meaning of the state's contents:
//    Continue is the state's "action". A NULL string means "return".
//    TB and FB are the state's continuations:
//       if TB != FB: Pop value stack, jump to TB or FB if non-zero or zero.
//       if TB == FB != NULL: Jump to TB unconditionally
//       if TB == FB == NULL: Halt
// States:
//    CALL -------- Start of new function
//    NEXT_STATE -- Starts execution in state Q
//    OPERATION --- Executes operation at PC in state Q
//    RETURN ------ Returns from function or from execution
//    UNWIND ------ Error return from execution, all function calls unwound.
// The indentation in Execute() reflects its original form as a recursive function,
// the recursion having centered on case 'x'.

void SetStacks(void) { SP = Stack - 1; }

void PurgeStacks(void) { while (SP >= Stack) Pop(); }

void Execute(State Head, State Tail) {
   Start = Head, End = Tail;
CALL:
   Q = Start + 1;
NEXT_STATE:
   if (Q == NULL) exit(0);
   PC = Q->Continue;
   if (PC == NULL) goto RETURN;
OPERATION:
      if (*PC == '\0') {
         Q = Q->TB == Q->FB || PopFlag()? Q->TB: Q->FB;
         goto NEXT_STATE;
      }
      switch (*PC++) {
/*[NUM]*/ case '[': {
             number N;
             UnGetNP = UnGet1, GetNP = Get1;
             N = GetNum();
             if (N == NULL) Fatal("Internal number reading error.");
             Push(NumberT, N);
             if (*PC == ']') PC++;
          }
          break;
/*"STR"*/ case '"': Push(StringT, ReadStr()); break;
/*$GAL$*/ case '$': {
             galois G;
             --PC, UnGetGP = UnGet1, GetGP = Get1;
             if (!GetGal(G)) Fatal("Internal reading error.");
             Push(GaloisT, G);
          }
          break;
/* 0 */   case '0': Push(ZeroT); break;
/* 1 */   case '1': PushFlag(1); break;
/* ;a */  case ';': PushArray(GetAddr()); break;
/* &v */  case '&': PushVariable(GetAddr()); break;
/* SI */  case 'I': IncludeFile(); break;
/* SL */  case 'L': LogFile(); break;
/* PN */  case 'N': if (!Memory(1)) goto UNWIND; break;
/* PF */  case 'F': if (!Memory(0)) goto UNWIND; break;
/* AI: */ case ':': if (!ArrayIndex()) goto UNWIND; break;
/*..Axf*/ case 'x': switch (Call(GetAddr())) {
             case 0: goto UNWIND;
             case 1: break; // Built-in function, value returned.
             case 2: goto CALL;
          }
          break;
/* Aw */  case 'w': Write(0); break;
/* AP */  case 'P': Write(1); break;
/* A, */  case ',': CHECK(1); Pop(); break;
/* An */  case 'n': Negate(); break;
/* A! */  case '!': PushFlag(!PopFlag()); break;
/* Lr */  case 'r': if (!Read()) goto UNWIND; break;
/* LAs */ case 's': if (!Store()) goto UNWIND; break;
/* Ld  */ case 'd': Duplicate(); break;
/* Lop */ case 'a': case 'm': case 'A': case 'M': case 'l': if (!Load(PC[-1])) goto UNWIND; break;
/* AB^ */ case '^': if (!Exponent()) goto UNWIND; break;
/* AB% */ case '%': if (!Modulus()) goto UNWIND; break;
/* AB+ */ case '+': if (!Addition()) goto UNWIND; break;
/* AB- */ case '-': if (!Subtraction()) goto UNWIND; break;
/* AB* */ case '*': if (!Multiplication()) goto UNWIND; break;
/* AB/ */ case '/': if (!Division()) goto UNWIND; break;
/* ABop*/ case '=': case '#': Equality(PC[-1]); break;
/* ABop*/ case '<': case '{': case '>': case '}': Relational(PC[-1]); break;
      }
goto OPERATION;
RETURN:
   if (Q == NULL) exit(0);
   if (Frames > 0) { Ret(); goto OPERATION; }
   return;
UNWIND:
   while (Frames > 0) Ret();
   return;
}

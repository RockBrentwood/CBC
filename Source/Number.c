#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <ctype.h>
#include "Number.h"

// Arbitrary precision arithmetic routines, base 1,000,000,000.
#define MIN(A, B) ((A) < (B)? (A): (B))
#define MAX(A, B) ((A) > (B)? (A): (B))

digit OBase = 10;
int Scale = 0, IBase = 10;
int NumError = 0;

// Numbers are restricted to 10^(0x100000L*9).
#define MAXLENGTH 0x100000L // (INT_MAX/9)

// SIZE(x) = ceil(x/9).
#define SIZE(D) (((D) + 8)/9)

// NOTE: All ANSI-C compilers have long integers of at least 32 bits!
// The base, and its 2/3, 1/3 and 1/2 + 0, 1/2 - 0 powers.
#define Billion  1000000000L
#define Million  1000000L
#define Thousand 1000L 
#define Root1    32000L
#define Root2    31250L

static digit Pow10[9] = { 1L, 10L, 100L, 1000L, 10000L, 100000L, 1000000L, 10000000L, 100000000L };

void (*UnGetNP)(int Ch);
int (*GetNP)(void);
void (*PutNP)(char *S, ...);
void (*MemFailNP)(char *Msg);

static void MemFail(char *Msg) {
   fprintf(stderr, Msg), fputc('\n', stderr); exit(1);
}

number Number(int Digits, int Scale) {
   if (Digits < 0) Digits = 0;
   if (Scale < 0) Scale = 0;
   unsigned Length = SIZE(Digits) + SIZE(Scale);
   if (Length == 0) Length = 1;
   else if (Length >= MAXLENGTH) {
      if (MemFailNP == NULL) MemFailNP = MemFail;
      MemFailNP("Number too big."); exit(1);
   }
   number N = malloc(sizeof *N + sizeof(digit)*(Length - 1));
   if (N == NULL) {
      if (MemFailNP == NULL) MemFailNP = MemFail;
      MemFailNP("Out of memory."); exit(1);
   }
   N->Digits = Digits, N->Scale = Scale; N->Copies = 1;
   if (Digits == 0 && Scale == 0) N->D[0] = 0;
   return N;
}

static number DupNumber(number A) {
   number C = Number(A->Digits, A->Scale);
   for (long I = SIZE(A->Digits) + SIZE(A->Scale) - 1; I >= 0; I--)
      C->D[I] = A->D[I];
   C->Sign = A->Sign; C->Copies = 1;
   return C;
}

number CopyNum(number A) {
   if (A == NULL) return NULL;
   if (++A->Copies != 0) return A;
   A->Copies--; // In case of overflow.
   return DupNumber(A);
}

void Delete(number A) {
   if (A == NULL) return;
   if (--A->Copies == 0) free(A);
}

void SetNum(number *AP, number B) { // Assumes B is already a copy.
   Delete(*AP); *AP = B;
}

static void Trim(number A) {
   if (A == NULL || A->Digits == 0) return;
   digit *DP = A->D + SIZE(A->Scale), *AP = DP + SIZE(A->Digits) - 1;
   for (; AP > DP; AP--) if (*AP != 0) break;
   A->Digits = 9*(AP - DP);
   digit First = *AP;
   if (First >= Million) First /= Million, A->Digits += 6; else if (First >= Thousand) First /= Thousand, A->Digits += 3;
   if (First >= 100L) First /= 100L, A->Digits += 2; else if (First >= 10L) A->Digits += 1;
   if (First > 0L) A->Digits++;
}

static digit CY;
static digit Add1(digit A, digit B) {
// CY = (A + B + CY)/Billion; return (A + B + CY)%Billion;
   unsigned long C = A + B + CY;
   if (CY = (C >= Billion? 1: 0))
      if ((C -= Billion) >= Billion) CY++, C -= Billion;
   return (digit)C;
}

static digit Sub1(digit A, digit B) {
// CY = -(A - B - CY)/Billion; return (A - B - CY)%Billion;
   digit C = A - B - CY;
   if (CY = (C < 0? 1: 0))
      if ((C += Billion) < 0) CY++, C += Billion;
   return C;
}

static void Mul1(digit A, digit B, digit *CP, digit *DP) {
// *CP = (A*B)/Billion, *DP = (A*B)%Billion;
   unsigned long aD = A/Root1, aM = A%Root1;
   unsigned long bD = B/Root2, bM = B%Root2;
   unsigned long c = aM*bD, d = aD*bM;
   unsigned long e = Root2*(c%Root1) + Root1*(d%Root2) + aM*bM;
   *CP = (digit)(aD*bD + c/Root1 + d/Root2 + e/Billion), *DP = (digit)(e%Billion);
}

static digit AddMul1(digit A, digit B, digit C) {
// CY = (C + A*B + CY)/Billion; return (C + A*B + CY)%Billion;
   digit U, V; Mul1(A, B, &U, &V);
   C = Add1(C, V); CY += U; return C;
}

static digit SubMul1(digit A, digit B, digit C) {
// CY = -(C - A*B - CY)/Billion; return (C - A*B - CY)%Billion;
   digit U, V; Mul1(A, B, &U, &V);
   C = Sub1(C, V); CY += U; return C;
}

static digit Div1(digit A, digit D) {
// A, CY = (CY:A)/D, (CY:A)%D, assuming CY < D.
   if (CY >= D) CY %= D;
   digit X;
   if (D < Root2) A += (Billion%D)*CY, X = (Billion/D)*CY;
   else if (D < Million) {
      digit x = (Thousand*CY + A/Million)/D*Million;
      digit U, V; Mul1(x, D, &U, &V);
      X = x;
      if ((A -= V) < 0) A += Billion, CY--;
      CY -= U;
      X += x = (Million*CY + A/Thousand)/D*Thousand; Mul1(x, D, &U, &V);
      if ((A -= V) < 0) A += Billion, CY--;
      CY -= U;
   } else {
      digit g = 1 + (D - 1)/Thousand, x = CY/g*Million;
      digit U, V; Mul1(x, D, &U, &V);
      X = x;
      if ((A -= V) < 0) A += Billion, CY--;
      CY -= U;
      X += x = (Thousand*CY + A/Million)/g*Thousand; Mul1(x, D, &U, &V);
      if ((A -= V) < 0) A += Billion, CY--;
      CY -= U;
      X += x = (Million*CY + A/Thousand)/g; Mul1(x, D, &U, &V);
      if ((A -= V) < 0) A += Billion, CY--;
      CY -= U;
   }
   X += A/D; CY = A%D;
   return X;
}

static int DiffNum(number A, number B) {
   if (A == NULL) return B == NULL? 0: +1; else if (B == NULL) return -1;
   int Diff = A->Digits - B->Digits; if (Diff != 0) return Diff > 0? +1: -1;
   int Size = SIZE(A->Digits);
   int AS = SIZE(A->Scale); digit *AP = A->D + AS;
   int BS = SIZE(B->Scale); digit *BP = B->D + BS;
   int I = Size - 1;
   for (; I >= -AS && I >= -BS; I--) if ((Diff = AP[I] - BP[I]) != 0) return Diff > 0? +1: -1;
   for (; I >= -AS; I--) if (AP[I] != 0) return +1;
   for (; I >= -BS; I--) if (BP[I] != 0) return -1;
   return 0;
}

static number Add(number A, number B) { // sign(A) (|A| + |B|)
   if (A == NULL || B == NULL) return NULL;
   number C = Number(MAX(A->Digits, B->Digits) + 1, MAX(A->Scale, B->Scale));
   C->Sign = A->Sign;
   int AD = SIZE(A->Digits), AS = SIZE(A->Scale); digit *AP = A->D + AS;
   int BD = SIZE(B->Digits), BS = SIZE(B->Scale); digit *BP = B->D + BS;
   int CD = SIZE(C->Digits), CS = SIZE(C->Scale); digit *CP = C->D + CS;
   int I = -CS;
   for (; I < -BS; I++) CP[I] = AP[I];
   for (; I < -AS; I++) CP[I] = BP[I];
   for (CY = 0; I < AD && I < BD; I++) CP[I] = Add1(AP[I], BP[I]);
   for (; I < AD; I++) CP[I] = Add1(AP[I], 0);
   for (; I < BD; I++) CP[I] = Add1(0, BP[I]);
   if (I < CD) CP[I] = CY;
   Trim(C); return C;
}

static number Sub(number A, number B) { // sign(A) (|A| - |B|)
   if (A == NULL || B == NULL) return NULL;
   number C = Number(MAX(A->Digits, B->Digits), MAX(A->Scale, B->Scale));
   C->Sign = A->Sign;
   int AD = SIZE(A->Digits), AS = SIZE(A->Scale); digit *AP = A->D + AS;
   int BD = SIZE(B->Digits), BS = SIZE(B->Scale); digit *BP = B->D + BS;
   int CD = SIZE(C->Digits), CS = SIZE(C->Scale); digit *CP = C->D + CS;
   int I = -CS;
   for (; I < -BS; I++) CP[I] = AP[I];
   for (CY = 0; I < -AS; I++) CP[I] = Sub1(0, BP[I]);
   for (; I < AD && I < BD; I++) CP[I] = Sub1(AP[I], BP[I]);
   for (; I < AD; I++) CP[I] = Sub1(AP[I], 0);
   for (; I < BD; I++) CP[I] = Sub1(0, BP[I]);
   if (CY) {
      C->Sign = -C->Sign;
      for (CY = 0, I = -CS; I < CD; I++) CP[I] = Sub1(0, CP[I]);
   }
   Trim(C); return C;
}

number NumLong(long L) { // return (number)(L%Billion);
   int Sign = 1;
   if (L < 0) Sign = -1, L = -L;
   if (L >= Billion) L -= Billion;
   number C = Number(9, 0);
   C->Sign = Sign; *C->D = L; Trim(C); return C;
}

number Num0(void) {
   static number N = NULL;
   if (N == NULL) {
      N = Number(9, 0);
      N->Sign = +1; *N->D = 0, N->Digits = 0, N->Scale = 0;
   }
   N->Copies++;
   return N;
}

number Num1(void) {
   static number N = NULL;
   if (N == NULL) {
      N = Number(9, 0);
      N->Sign = +1; *N->D = 1, N->Digits = 1, N->Scale = 0;
   }
   N->Copies++;
   return N;
}

long Long(number N) { // return (long)(N%Billion), or Billion if N == NULL.
   if (N == NULL) return BIG_NUM;
   long L = (long)N->D[SIZE(N->Scale)];
   if (N->Sign < 0) L = -L;
   return L;
}

int CompNum(number A, number B) {
   if (A == NULL) return B == NULL? 0: +1;
   if (B == NULL) return -1;
   if (A->Sign < 0 && 0 < B->Sign) return -1;
   if (B->Sign < 0 && 0 < A->Sign) return +1;
   int Diff = DiffNum(A, B);
   return A->Sign > 0? Diff: -Diff;
}

number AddNum(number A, number B) {
   if (A->Sign == B->Sign) return Add(A, B);
   int Diff = DiffNum(A, B);
   return Diff == 0? NumLong(0): Diff > 0? Sub(A, B): Sub(B, A);
}

number SubNum(number A, number B) {
   if (A->Sign != B->Sign) return Add(A, B);
   int Diff = DiffNum(A, B);
   if (Diff == 0) return NumLong(0);
   else if (Diff > 0) return Sub(A, B);
   else {
      number C = Sub(B, A); C->Sign = -C->Sign; return C;
   }
}

number NegNum(number A) {
   if (A == NULL) return NULL;
   A = DupNumber(A);
   A->Sign = -A->Sign; return A;
}

number IncNum(number A, int Dir) {
   number One = Num1();
   if (A == NULL) return NULL;
   One->Sign = Dir > 0? +1: -1;
   number C = AddNum(A, One);
   One->Sign = +1; Delete(One);
   return C;
}

int IsZero(number B) {
   if (B == NULL) return 0;
   for (int I = SIZE(B->Digits) + SIZE(B->Scale) - 1; I >= 0; I--)
      if (B->D[I] != 0) return 0;
   return 1;
}

number MulNum(number A, number B) {
   if (A == NULL || B == NULL) return NULL;
   if (Scale < 0) Scale = 0;
   int ABS = A->Scale + B->Scale;
   if (Scale < ABS) ABS = Scale;
   if (A->Scale > ABS) ABS = A->Scale;
   if (B->Scale > ABS) ABS = B->Scale;
   number C = Number(A->Digits + B->Digits, ABS);
   C->Sign = A->Sign*B->Sign;
   int AD = SIZE(A->Digits), AS = SIZE(A->Scale); digit *AP = A->D + AS;
   int BD = SIZE(B->Digits), BS = SIZE(B->Scale); digit *BP = B->D + BS;
   int CD = SIZE(C->Digits), CS = SIZE(C->Scale); digit *CP = C->D + CS;
   for (int c = -CS; c < CD; c++) CP[c] = 0;
   digit Last = 0;
   for (int a = -AS; a < AD; a++) {
      digit aD = AP[a];
      CY = 0;
      int b = -BS, c = a + b;
      for (; c < -CS - 1; b++, c++) AddMul1(aD, BP[b], CY);
      if (c < -CS) Last = AddMul1(aD, BP[b++], Last), c++;
      for (; b < BD && c < CD; b++, c++) CP[c] = AddMul1(aD, BP[b], CP[c]);
      for (; c < CD && CY; c++) CP[c] = Add1(CP[c], 0);
   }
   Trim(C);
   if (IsZero(C)) C->Sign = +1;
   return C;
}

#define BUF_SIZE (2*MAXLENGTH)
static digit DD[BUF_SIZE], *DP; static int d, ld;
static digit RR[BUF_SIZE], *RP; static int r, lr;
static digit QQ[BUF_SIZE], *QP; static int q, lq;
// Representations for DivMod.
//    Remainder = 0.{RP..RR} x 10^r, lr significant digits
//    Divisor   = 0.{DP..DD} x 10^d, ld significant digits
//    Quotient  = {QP..QQ}.0 x 10^(-q), lq significant digits
// Representations for RootNum:
//    Remainder = {RP..RR}.0 x 10^(-q)
//    Divisor   = {DP..DD}.0 x 10^(-q), ld significant digits
//    Quotient  = {QP..QQ}.0 x 10^(-q), lq significant digits

static void Left9(digit *End, int Size) {
   int I = -1;
   for (; I > -Size; I--) End[I + 1] = End[I];
   End[I + 1] = 0;
}

static void Left3(digit *End, int Size) {
   *End *= Thousand;
   for (int I = -1; I > -Size; I--)
      End[I + 1] += End[I]/Million, End[I] = Thousand*(End[I]%Million);
}

static void Right3(digit *End, int Size) {
   for (int I = 1 - Size; I < 0; I++)
      End[I] = End[I]/Thousand + End[I + 1]%Thousand*Million;
   *End /= Thousand;
}

static void Left1(digit *End, int Size) {
   *End *= 10L;
   for (int I = -1; I > -Size; I--)
      End[I + 1] += End[I]/100000000L, End[I] = 10L*(End[I]%100000000L);
}

static void Right1(digit *End, int Size) {
   for (int I = 1 - Size; I < 0; I++)
      End[I] = End[I]/10L + End[I + 1]%10L*100000000L;
   *End /= 10L;
}

static int Diff1(digit *AP, digit *BP, int Size) {
   for (int I = 0; I > -Size; I--) {
      long Diff = AP[I] - BP[I];
      if (Diff != 0) return Diff < 0? -1: +1;
   }
   return 0;
}

static int DivMod(number A, number B) {
   if (A == NULL || B == NULL) return 0;
   if (IsZero(B)) { NumError = NUM_INFINITY; return 0; }
// DD <- divisor B.
   d = 9*SIZE(B->Digits), ld = d + B->Scale;
   *DD = 0;
   int I = 0;
   for (DP = DD + 1; I < SIZE(ld); DP++, I++) *DP = B->D[I];
   DP--;
// Adjust DD so that the leading digit is in the thousands.
   if (*DP < Thousand)
      Left3(DP, SIZE(ld)), d -= 3, ld -= 3; // DD *= 1000
   else if (*DP >= Million)
      Right3(DP, SIZE(ld) + 1), d += 3, ld += 3; // DD /= 1000
// RR <- dividend A.
   r = 9*SIZE(A->Digits), lr = A->Scale + r;
   *RR = 0;
   for (RP = RR + 1, I = 0; I < SIZE(ld) - SIZE(lr); RP++, I++) *RP = 0;
   if (lr < ld) lr = ld;
   for (int J = 0; I < SIZE(lr); RP++, I++, J++) *RP = A->D[J];
   RP--;
// Adjust the remainder so that RP..RR < 1000*(DP..DD).
   if (*RP >= Thousand * *DP || d - r > Scale)
      Right3(RP, SIZE(lr) + 1), r += 3, lr += 3; // RR /= 1000
// QQ = 0.
   q = d - r, lq = 0;
   for (I = 0; I <= SIZE(Scale - q); I++) QQ[I] = 0;
// Shift-subtract divide routine:
// * 3/9 digit shifts combined when possible
// * divisor digit underestimated, never off by more than 1
// * estimate is almost always precise.
// * remainder never shorter than divisor: lr >= ld.
   while (1)
      if (*RP == 0 && RP[-1] < *DP && q + 9 <= Scale) {
         if (lq != 0) lq += 9, Left9(QQ + SIZE(lq) - 1, SIZE(lq));
         q += 9;
         Left9(RP, SIZE(lr)), r -= 9, lr -= 9;
         if (lr < ld) lr = ld;
      } else if (*RP < *DP/Thousand && q + 3 <= Scale) {
         if (lq != 0) lq += 3, Left3(QQ + SIZE(lq) - 1, SIZE(lq));
         q += 3;
         Left3(RP, SIZE(lr)), r -= 3, lr -= 3;
         if (lr < ld) lr = ld;
      } else if (Diff1(RP, DP, SIZE(ld)) < 0) {
         if (q >= Scale) break;
         if (lq != 0) lq++, Left1(QQ + SIZE(lq) - 1, SIZE(lq));
         q++;
         Left1(RP, SIZE(lr)), r--, lr--;
         if (lr < ld) lr = ld;
      } else {
         digit g = *RP/(*DP + 1); if (g == 0) g = 1;
         if (lq == 0) lq = 3;
         *QQ += g;
         CY = 0;
         for (int I = 1 - SIZE(ld); I <= 0; I++)
            RP[I] = SubMul1(DP[I], g, RP[I]);
      }
   return 1;
}

number DivNum(number A, number B) {
   if (Scale < 0) Scale = 0;
   if (!DivMod(A, B)) return NULL;
// Quotient = {QP..QQ}.0 x 10^(-q), lq significant digits.
   number C = Number(lq - q, Scale);
   C->Sign = A->Sign*B->Sign;
// Align the QQ left on 10^9 boundary.
   int dQ = 0;
   for (; q%9 != 0; dQ++, q++);
   if (lq > 0) {
      for (; dQ >= 3; dQ -= 3) lq += 3, Left3(QQ + SIZE(lq) - 1, SIZE(lq));
      for (; dQ > 0; dQ--) lq++, Left1(QQ + SIZE(lq) - 1, SIZE(lq));
   }
// Copy C <- QQ.
   int sC = 9*SIZE(Scale);
   digit *QP = QQ;
   for (; q > sC; QP++, q -= 9, lq -= 9);
   digit *CP = C->D;
   for (; lq > 0; QP++, q -= 9, lq -= 9, CP++) *CP = *QP;
   for (; q > 0; q -= 9, CP++) *CP = 0;
   if (C->Scale > 0) {
      int dS = 9*SIZE(C->Scale) - C->Scale;
      C->D[0] = (C->D[0]/Pow10[dS])*Pow10[dS];
   }
   Trim(C);
   return C;
}

number InvNum(number B) {
   number A = Num1(), C = DivNum(A, B);
   Delete(A); return C;
}

number ModNum(number A, number B) {
   if (Scale < 0) Scale = 0;
   if (!DivMod(A, B)) return NULL;
// Remainder = 0.{RP..RR} x 10^(-r), lr significant digits.
   int dC = MAX(r, 0), sC = MAX(lr - r, 0); number C = Number(dC, sC);
   C->Sign = A->Sign;
// Align RR left on 10^9 boundary.
   int dR = 0;
   for (; r%9 != 0; dR++, r--);
   *++RP = 0L, r += 9;
   for (; dR >= 3; dR -= 3) Left3(RP, SIZE(lr) + 1);
   for (; dR > 0; dR--) Left1(RP, SIZE(lr) + 1);
// Copy C <- RR.
   RP -= r/9 + SIZE(sC) - 1;
   for (int I = 0; I < SIZE(dC) + SIZE(sC); I++) C->D[I] = RP[I];
   Trim(C);
   return C;
}

static digit RootX(digit L) {
   double D = (double)L;
   return L <= 0? 0L: (digit)floor(sqrt(D));
}

number RootNum(number A) {
   if (A == NULL) return NULL;
   if (A->Sign < 0) { NumError = NEG_ROOT; return NULL; }
   if (Scale < 0) Scale = 0;
   if (A->Digits + 2*Scale <= 9) {
      digit D = 0, *AP = A->D + SIZE(A->Scale) + SIZE(A->Digits) - 1;
      if (A->Digits > 0) D = *AP--;
      if (Scale == 0) return NumLong(RootX(D));
      D = RootX(D*Pow10[2*Scale] + *AP/Pow10[9 - 2*Scale]);
      number C = Number(A->Digits/2 + 1, Scale);
      C->D[0] = D%Pow10[Scale]*Pow10[9 - Scale]; C->D[1] = D/Pow10[Scale];
      C->Sign = +1;
      Trim(C); return C;
   }
// Remainder <- A.
   RR[0] = 0;
   digit *AP = A->D;
   int I = -SIZE(A->Scale);
   for (; I < -SIZE(2*Scale); AP++, I++);
   for (RP = RR + 1, I = -SIZE(2*Scale); I < -SIZE(A->Scale); I++) *RP++ = 0;
// RR <- radix A.
   for (; I < SIZE(A->Digits); I++) *RP++ = *AP++;
   q = 9 - 9*SIZE(A->Digits);
   if (*--RP == 0) { // Only possible if A == 0.
      number C = Number(0, Scale);
      for (int I = 0; I < SIZE(Scale); I++) C->D[I] = 0;
      C->Sign = +1;
      Trim(C); return C;
   }
// RR adjusted to have even number of digits.
   if (q&1) q--, Right1(RP, RP - RR + 1);
// RR normalized to lie between 250,000 and 24,999,999.
   while (*RP < 250000L) q += 2, Left1(RP, RP - RR + 1), Left1(RP, RP - RR + 1);
   while (*RP >= 25000000L) q -= 2, Right1(RP, RP - RR + 1), Right1(RP, RP - RR + 1);
   q /= 2;
// QQ = DD = 0.
   for (I = SIZE(Scale) + SIZE((A->Digits + 1)/2), QP = QQ; I > 0; I--) *QP++ = 0;
   *QP = 0;
   ld = SIZE(Scale) + SIZE(A->Digits/2) + 1;
   for (I = 0, DP = DD; I < ld; I++) *DP++ = 0;
   DP--;
// Initial digit of "quotient".
   digit g = RootX(*RP); *QP = g, *DP = 2*g, *RP -= g*g; lq = 0;
// Shift and subtract square root algorithm:
// * 3/9 digit shifts combined when possible
// * Only remainder is shifted.
// * lq is the insertion place to the left of DP/QP.
// * divisor digit underestimated, never off by more than 1
// * estimate is almost always precise.
// * DD = 2*QQ
   while (1)
      if (*RP == 0 && RP[-1] < *DP && q + 9 <= Scale) q += 9, lq += 9, Left9(RP, RP - RR + 1);
      else if (*RP < *DP/Thousand && q + 3 <= Scale) q += 3, lq += 3, Left3(RP, RP - RR + 1);
      else {
         I = -(lq + 8)/9;
         digit g1 = Pow10[8 - (lq + 8)%9]; DP[I] += g1;
         int Comp = Diff1(RP, DP, ld); DP[I] -= g1;
         if (Comp < 0) {
            if (q >= Scale) break;
            q++, lq++; Left1(RP, RP - RR + 1);
         } else {
            g = *RP/(*DP + 1); if (g == 0) g = 1;
            g1 *= g; QP[I] += g1; DP[I] += g1;
            for (CY = 0; I <= 0; I++) RP[I] = SubMul1(DP[I], g, RP[I]);
            I = -(lq + 8)/9; CY = 0; DP[I] = Add1(DP[I], g1);
            for (I++; I <= 0 && CY; I++) DP[I] = Add1(DP[I], 0);
         }
      }
// Align QQ left to a 10^9 boundary.
   *++QP = 0L;
   for (lq -= Scale; lq%9 != 0; lq--) Left1(QP, QP - QQ + 1);
   if (*QP == 0L) QP--;
// Copy C <- QQ.
   int CD = (A->Digits + 1)/2, CS = Scale; number C = Number(CD, CS);
   QP -= SIZE(CD) + SIZE(CS);
   for (int I = 0; I < SIZE(CD) + SIZE(CS); I++) C->D[I] = *++QP;
   C->Sign = +1;
   Trim(C);
   return C;
}

number ExpNum(number A, number B) {
// The divide and conquer algorithm.
   if (A == NULL || B == NULL) return NULL;
   if (Scale < 0) Scale = 0;
   if (SIZE(B->Digits) > 1) { NumError = EXP_TOO_BIG; return NULL; }
   digit N = Long(B);
   signed char Sign;
   if (N >= 0) Sign = +1; else Sign = -1, N = -N;
   number C = Num1(), P = CopyNum(A);
   for (; N > 0; N >>= 1) {
      if (N&1) SetNum(&C, MulNum(C, P));
      SetNum(&P, MulNum(P, P));
   }
   Delete(P);
   if (Sign < 0) SetNum(&C, InvNum(C));
   return C;
}

void PutNum(number A) {
   if (A == NULL) { PutNP("infinity"); return; }
   int AD = SIZE(A->Digits);
   if (OBase < 2) OBase = 2; else if (OBase > Billion) OBase = Billion;
   if (IsZero(A)) { PutNP("0"); return; }
   if (A->Sign < 0) PutNP("-");
   digit *AP = A->D + SIZE(A->Scale), *P = AP + AD - 1;
   if (OBase == 10) {
      if (P < AP) PutNP("0");
      else {
         PutNP("%ld", *P);
         for (P--; P >= AP; P--) PutNP("%09ld", *P);
      }
      if (A->Scale > 0) {
         int Extra = 9*SIZE(A->Scale) - A->Scale;
         PutNP(".");
         for (; P > A->D; P--) PutNP("%09ld", *P);
         PutNP("%0*ld", 9 - Extra, *P/Pow10[Extra]);
      }
      return;
   } else if (OBase == Billion) {
      if (P < AP) PutNP("0");
      else {
         PutNP("%9ld", *P);
         for (P--; P >= AP; P--) PutNP(" %09ld", *P);
      }
      if (A->Scale > 0) {
         PutNP(".");
         for (; P >= A->D; P--) PutNP(" %09ld", *P);
      }
      return;
   }
   int Digs = 0;
   int Bits = (int)ceil(log(OBase)/log(2)), Size = 32/Bits;
   int Width = (int)ceil(log(OBase)/log(10));
   if (P >= AP) {
      for (int I = 0; I < AD; I++) RR[I] = AP[I];
      while (1) {
         int NonZero = 0;
         CY = 0;
         for (int I = AD - 1; I >= 0; I--) {
            if (RR[I]) NonZero++;
            RR[I] = Div1(RR[I], OBase);
         }
         if (!NonZero) break;
         if (Digs%Size == 0) DD[Digs/Size] = 0;
         DD[Digs/Size] |= CY << (Digs%Size*Bits);
         Digs++;
      }
   }
   if (Digs <= 0) DD[0] = 0, Digs = 1;
   int Decs = Digs;
   if (A->Scale > 0) {
      AD = SIZE(A->Scale);
      for (int I = 0; I < AD; I++) RR[I] = A->D[I];
      int AS = (int)ceil((double)A->Scale*log(10)/log(OBase));
      for (int I = 0; I < AS; I++) {
         CY = 0;
         for (int J = 0; J < AD; J++) RR[J] = AddMul1(RR[J], OBase, 0);
         if (Decs%Size == 0) DD[Decs/Size] = 0;
         DD[Decs/Size] |= CY << (Decs%Size*Bits);
         Decs++;
      }
      if (RR[AD - 1] >= Billion/2) {
         CY = 1;
         for (int I = Decs - 1; I >= Digs && CY; I--) {
            digit g = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
            DD[I/Size] ^= g << (I%Size*Bits);
            if (++g >= OBase) g = 0, CY = 1; else CY = 0;
            DD[I/Size] |= g << (I%Size*Bits);
         }
         for (int I = 0; I < Digs && CY; I++) {
            digit g = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
            DD[I/Size] ^= g << (I%Size*Bits);
            if (++g >= OBase) g = 0, CY = 1; else CY = 0;
            DD[I/Size] |= g << (I%Size*Bits);
         }
      }
   }
   int I = Digs;
   if (OBase > 0x10) {
      I--;
      digit g = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
      PutNP("%ld", g);
   }
   for (I--; I >= 0; I--) {
      digit g = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
      if (OBase <= 0x10) PutNP("%1x", g);
      else PutNP(" %*ld", Width, g);
   }
   if (A->Scale == 0) return;
   PutNP(".");
   for (int I = Digs; I < Decs; I++) {
      digit g = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
      if (OBase <= 0x10) PutNP("%1x", g);
      else {
         if (I > 0) PutNP(" ");
         PutNP("%*ld", Width, g);
      }
   }
}

static char atox(char Ch) {
   return
      isdigit(Ch)? Ch - '0':
      isxdigit(Ch)? tolower(Ch) - 'a' + 10:
      0;
}

number GetNum(void) {
   if (IBase < 2) IBase = 2; else if (IBase > 0x10) IBase = 0x10;
   int Bits = (int)ceil(log(IBase)/log(2)), Size = 32/Bits, MaxLog = Size*MAXLENGTH;
   int Ch;
   do Ch = GetNP(); while (isspace(Ch));
   int Neg = Ch == '-';
   if (Ch == '+' || Ch == '-') Ch = GetNP();
   int Digs = 0;
   if (isxdigit(Ch)) {
      char First = atox((char)Ch);
      Ch = GetNP();
      if (isxdigit(Ch) && First >= IBase) First = IBase - 1;
      DD[0] = First; Digs = 1;
      while (isxdigit(Ch)) {
         if ((Ch = atox((char)Ch)) >= IBase) Ch = IBase - 1;
         if (Digs < MaxLog) {
            if (Digs%Size == 0) DD[Digs/Size] = 0;
            DD[Digs/Size] |= (digit)Ch << (Digs%Size*Bits);
            Digs++;
         }
         Ch = GetNP();
      }
   }
   int Decs = Digs;
   if (Ch == '.') {
      Ch = GetNP();
      while (isxdigit(Ch)) {
         Ch = atox((char)Ch);
         if (Ch >= IBase) Ch = IBase - 1;
         if (Decs < MaxLog) {
            if (Decs%Size == 0) DD[Decs/Size] = 0;
            DD[Decs/Size] |= (digit)Ch << (Decs%Size*Bits);
            Decs++;
         }
         Ch = GetNP();
      }
   }
   UnGetNP(Ch);
   if (Decs == 0) { NumError = NOT_READ; return NULL; }
   int CD = (int)ceil((double)Digs*log(IBase)/log(10)); if (CD == 0) CD = 1;
   int CS = (int)ceil((double)(Decs - Digs)*log(IBase)/log(10));
   number C = Number(CD, CS);
   C->Sign = Neg? -1: +1;
   digit *DP = C->D + SIZE(CS), *EP = DP + SIZE(CD);
   for (digit *CP = C->D; CP < EP; CP++) *CP = 0;
   for (int I = Decs - 1; I >= Digs; I--) { // Decimal += digit, Decimal /= IBase;
      *DP = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
      CY = 0;
      for (digit *CP = DP; CP >= C->D; CP--) *CP = Div1(*CP, IBase);
   }
   if (Digs == 1 && Decs == 1 && !Neg) CY = 0, *DP = AddMul1(*DP, 0x10, DD[0]); // 1-digit numerals are treated as hexadecimal.
   else for (int I = 0; I < Digs; I++) { // Mantissa *= IBase, Mantissa += digit;
      digit g = (DD[I/Size] >> (I%Size*Bits))&((1 << Bits) - 1);
      CY = 0, *DP = AddMul1(*DP, IBase, g);
      for (digit *CP = DP + 1; CP < EP; CP++) *CP = AddMul1(*CP, IBase, 0);
   }
   Trim(C);
   return C;
}

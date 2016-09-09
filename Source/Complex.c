#include <stdio.h>
#include "Number.h"
#include "Complex.h"

complex Com0(void) {
   complex C; C.X = Num0(), C.Y = Num0();
   return C;
}

number NormC(complex A) {
   number XX = MulNum(A.X, A.X), YY = MulNum(A.Y, A.Y), Norm = AddNum(XX, YY);
   Delete(YY), Delete(XX);
   return Norm;
}

// This assumes A and B are already copies.
complex ComplexC(number A, number B) {
   complex C; C.X = A, C.Y = B;
   return C;
}

complex CopyC(complex C) {
   complex A; A.X = CopyNum(C.X), A.Y = CopyNum(C.Y);
   return A;
}

void DeleteC(complex C) {
   Delete(C.Y), Delete(C.X);
}

// This assumes A is already a copy by this point.
void SetC(complex *CP, complex A) {
   SetNum(&CP->X, A.X), SetNum(&CP->Y, A.Y);
}

int EqualC(complex A, complex B) {
   return CompNum(A.X, B.X) == 0 && CompNum(A.Y, B.Y) == 0;
}

complex AddC(complex A, complex B) {
   complex C; C.X = AddNum(A.X, B.X), C.Y = AddNum(A.Y, B.Y);
   return C;
}

complex SubC(complex A, complex B) {
   complex C; C.X = SubNum(A.X, B.X), C.Y = SubNum(A.Y, B.Y);
   return C;
}

complex NegC(complex A) {
   A.X = NegNum(A.X), A.Y = NegNum(A.Y); return A;
}

int ZeroC(complex A) { return IsZero(A.X) && IsZero(A.Y); }

complex IncC(complex A, int Dir) {
   complex C; C.X = IncNum(A.X, Dir), C.Y = CopyNum(A.Y);
   return C;
}

complex MulC(complex A, complex B) {
   number XX = MulNum(A.X, B.X), XY = MulNum(A.X, B.Y);
   number YX = MulNum(A.Y, B.X), YY = MulNum(A.Y, B.Y);
   complex C; C.X = SubNum(XX, YY), C.Y = AddNum(XY, YX);
   Delete(YY), Delete(YX), Delete(XY), Delete(XX);
   return C;
}

complex DivC(complex A, complex B) {
   number XX = MulNum(A.X, B.X), XY = MulNum(A.X, B.Y);
   number YX = MulNum(A.Y, B.X), YY = MulNum(A.Y, B.Y);
   number X = AddNum(XX, YY), Y = SubNum(YX, XY);
   number Norm = NormC(B);
   complex C; C.X = DivNum(X, Norm), C.Y = DivNum(Y, Norm);
   Delete(Norm), Delete(Y), Delete(X);
   Delete(YY), Delete(YX), Delete(XY), Delete(XX);
   return C;
}

complex InvC(complex A) {
   number Norm = NormC(A);
   complex C; C.X = DivNum(A.X, Norm), C.Y = DivNum(A.Y, Norm);
   C.Y->Sign = -C.Y->Sign;
   Delete(Norm);
   return C;
}

complex ExpC(complex A, number B) {
   complex C; C.X = C.Y = 0;
   if (A.X == 0 || A.Y == 0 || B == 0) return C;
   if (Scale < 0) Scale = 0;
   digit N = Long(B);
   if (N == BIG_NUM) { NumError = EXP_TOO_BIG; return C; }
   signed char Sign;
   if (N >= 0) Sign = +1; else Sign = -1, N = -N;
   complex P = CopyC(A);
   for (C = ComplexC(Num1(), Num0()); N > 0; N >>= 1) {
      if (N&1) SetC(&C, MulC(C, P));
      SetC(&P, MulC(P, P));
   }
   DeleteC(P);
   if (Sign < 0) SetC(&C, InvC(C));
   return C;
}

complex GetC(void) {
   NumError = 0;
   complex C; C.X = GetNum();
   if (C.X == 0) { C.Y = 0; return C; }
   C.Y = GetNum();
// The imaginary part need not be read.
   if (C.Y == 0) C.Y = NumLong(0), NumError = 0;
   return C;
}

void PutC(complex C) {
   PutNum(C.X), PutNP(" + i* "), PutNum(C.Y);
}

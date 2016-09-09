#include <math.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include "Galois.h"

// This implementation assumes that long integers are at least GWID (32) bits.
#define GWID 0x20

int gal_error = 0;

galois Gal0 = { 0, 0, 0, 0, 0, 0, 0, 0 }, Gal1 = { 1, 0, 0, 0, 0, 0, 0, 0 };

// Initially set for GF(2^1), with g(x) = x + 1, leading coefficient always 1.
static unsigned bits = 1, prime = 2, degree = 1, residue[GSIZE] = { 1 };
static unsigned pX[GSIZE + 1], pY[GSIZE], pdX[GSIZE], pdY[GSIZE];

#define WIDTH(Arr) (sizeof (Arr)/sizeof (Arr)[0])
static unsigned char Sieve[] = {
     2,   3,   5,   7,  11,  13,  17,  19,  23,  29,  31,  37,
    41,  43,  47,  53,  59,  61,  67,  71,  73,  79,  83,  89,
    97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151,
   157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223,
   227, 229, 233, 239, 241, 251
};

static unsigned long MASK[GWID + 1] = {
   0x00000000UL, 0x00000001UL, 0x00000003UL, 0x00000007UL,
   0x0000000fUL, 0x0000001fUL, 0x0000003fUL, 0x0000007fUL,
   0x000000ffUL, 0x000001ffUL, 0x000003ffUL, 0x000007ffUL,
   0x00000fffUL, 0x00001fffUL, 0x00003fffUL, 0x00007fffUL,
   0x0000ffffUL, 0x0001ffffUL, 0x0003ffffUL, 0x0007ffffUL,
   0x000fffffUL, 0x001fffffUL, 0x003fffffUL, 0x007fffffUL,
   0x00ffffffUL, 0x01ffffffUL, 0x03ffffffUL, 0x07ffffffUL,
   0x0fffffffUL, 0x1fffffffUL, 0x3fffffffUL, 0x7fffffffUL,
   0xffffffffUL
};

unsigned GetN(galois G, unsigned N) {
   if (N >= degree) return 0;
   if (prime == 2) return (G[N/GWID] >> (N%GWID))&1;
   N *= bits;
   unsigned N1 = GWID - N%GWID, D = G[N/GWID] >> (GWID - N1);
   if (bits <= N1)
      D &= MASK[bits];
   else
      D |= (G[N/GWID + 1]&MASK[bits - N1]) << N1;
   return D%prime;
}

void SetN(galois G, unsigned N, long D) {
   if (N >= degree) return;
   if ((D %= prime) < 0) D += prime;
   if (prime == 2) {
      unsigned long Bit = 1L << (N%GWID);
      if (D) G[N/GWID] |= Bit; else G[N/GWID] &= ~Bit;
      return;
   }
   N *= bits;
   unsigned long *GP = G + N/GWID; N %= GWID;
   unsigned N1 = GWID - N;
   if (bits <= N1) *GP &= ~(MASK[bits] << N), *GP |= D << N;
   else {
      *GP &= MASK[N], *GP |= (D&MASK[N1]) << N;
      GP[1] &= ~MASK[bits - N1], GP[1] |= D >> N1;
   }
}

int EqualG(galois A, galois B) {
   for (int I = 0; I < degree - 1; I++)
      if (GetN(A, I) != GetN(B, I)) return 0;
   return 1;
}

void CopyG(galois A, galois B) {
   for (int I = 0; I < GLEN; I++) A[I] = B[I];
}

void Unit(galois A, unsigned U) {
   A[0] = U%prime;
   for (int I = 1; I < GLEN; I++) A[I] = 0;
}

void AddG(galois A, galois B) {
   if (prime == 2)
      for (int I = 0; I < GLEN; I++) A[I] ^= B[I];
   else
      for (int I = 0; I < degree; I++) SetN(A, I, (long)GetN(A, I) + (long)GetN(B, I));
}

void SubG(galois A, galois B) {
   if (prime == 2)
      for (int I = 0; I < GLEN; I++) A[I] ^= B[I];
   else
      for (int I = 0; I < degree; I++) SetN(A, I, (long)GetN(A, I) - (long)GetN(B, I));
}

void IncG(galois A, int Dir) {
   if (prime == 2) A[0] ^= 1;
   else {
      long D = (A[0]&MASK[bits])%prime; A[0] &= ~MASK[bits];
      if (Dir > 0) {
         if (++D >= prime) D = 0;
      } else {
         if (D <= 0) D = prime; --D;
      }
      A[0] |= D;
   }
}

void NegG(galois A) {
   if (prime == 2) return;
   for (int I = 0; I < degree; I++) SetN(A, I, (long)GetN(A, I));
}

void ShiftG(galois G) {
   int J = degree - 1;
   if (prime == 2) {
      int M = J%GWID; J /= GWID;
      unsigned long D = (G[J] >> M)&1; G[J] &= MASK[M];
      for (; J > 0; J--) G[J] <<= 1, G[J] |= (G[J - 1] >> (GWID - 1))&1;
      G[0] <<= 1;
      if (D) for (J = 0; J < degree; J++) SetN(G, J, GetN(G, J)^residue[J]);
   } else {
      unsigned long D = GetN(G, J);
      for (; J > 0; J--) SetN(G, J, GetN(G, J - 1) + D*residue[J]);
      SetN(G, 0, D*residue[0]);
   }
}

int (*GetGP)(void);
void (*UnGetGP)(int Ch);
void (*PutGP)(char *S, ...);
void (*MemFailGP)(char *Msg);

void PutGal(galois G) {
   PutGP("$");
   int I;
   if (prime <= 0x10)
      for (I = degree - 1; I > 0; I--) PutGP("%x", GetN(G, I));
   else
      for (I = degree - 1; I > 0; I--) PutGP("%d ", GetN(G, I));
   PutGP("%d", GetN(G, I));
}

int GetGal(galois G) {
   int Ch;
   do Ch = GetGP(); while (Ch == ' ' || Ch == '\t');
   if (Ch != '$') { UnGetGP(Ch); return 0; }
   Unit(G, 0);
   if (prime <= 0x10) {
      do {
         Ch = GetGP();
         if (isxdigit(Ch)) {
            long D = isdigit(Ch)? Ch - '0': tolower(Ch) - 'a' + 10;
            ShiftG(G), SetN(G, 0, GetN(G, 0) + D);
         }
      } while (isxdigit(Ch) || Ch == ' ' || Ch == '\t');
   } else {
      long D = -1;
      do {
         Ch = GetGP();
         if (!isxdigit(Ch)) {
            if (D >= 0) ShiftG(G), SetN(G, 0, GetN(G, 0) + D), D = -1;
         } else {
            if (D < 0) D = 0; else D *= 10;
            D += isdigit(Ch)? Ch - '0': tolower(Ch) - 'a' + 10;
            D %= prime;
         }
      } while (isxdigit(Ch) || Ch == ' ' || Ch == '\t');
   }
   if (Ch != '$') UnGetGP(Ch);
   return 1;
}

static void MulG1(galois G, unsigned D) {
   if (prime == 2) {
      if (!(D&1)) for (int I = 0; I < GLEN; I++) G[I] = 0;
   } else {
      D %= prime;
      for (int I = 0; I < degree; I++) SetN(G, I, (long)GetN(G, I)*(long)D);
   }
}

void MulG(galois P, galois A, galois B) {
   unsigned D = 0; int I = degree - 1;
   for (; I >= 0; I--) {
      D = GetN(B, I); if (D != 0) break;
   }
   if (D == 0) { Unit(P, 0); return; }
   CopyG(P, A), MulG1(P, D);
   while (I-- > 0) {
      ShiftG(P), D = GetN(B, I);
      if (D == 0) continue;
      for (int J = 0; J < degree; J++)
         SetN(P, J, GetN(P, J) + (long)D*GetN(A, J));
   }
}

// Find x such that A = Bx + prime y, 0 <= A, B < prime.
static unsigned DivG1(unsigned A, unsigned B) {
   if (B == 0) return 0;
   long P1 = prime, x = A, y = 0;
   for (long B1 = B; B1 > 1; ) {
      y -= x*(P1/B1), P1 %= B1;
      if (P1 == 1) { x = y; break; }
      x -= y*(B1/P1), B1 %= P1;
   }
   if (x < 0) x = prime - (-x)%prime;
   return x%prime;
}

int ZeroG(galois G) {
   for (int I = 0; I < GLEN; I++)
      if (G[I] != 0) return 1;
   return 0;
}

int InvG(galois Q, galois A) { // Q A + P'g = 1
   int dX = 0;
   for (; dX < degree; dX++) {
      pX[dX] = residue[dX] == 0? 0: prime - residue[dX];
      pdX[dX] = 0;
   }
   pX[dX] = 1;
   int dY = -1;
   for (int dD = 0; dD < degree; dD++) {
      long D = GetN(A, dD); if (D != 0) dY = dD;
      pY[dD] = D, pdY[dD] = 0;
   }
   pdY[0] = 1;
   if (dY < 0) return 0;
   while (1) {
      if (dY == 0) {
         long D = DivG1(1, pY[0]);
         for (int I = 0; I < degree; I++) SetN(Q, I, D*pdY[I]);
         break;
      }
      while (dX >= dY) {
         long D = DivG1(pX[dX], pY[dY]);
         if (D > 0) D = prime - D;
         int dD = 0, I = 0;
         for (; I < dX - dY; I++) if (pX[I] != 0) dD = I;
         for (; I <= dX; I++) {
            long D1 = pX[I] = (pX[I] + D*pY[I + dY - dX])%prime;
            if (D1 != 0) dD = I;
         }
         for (I = dX - dY; I < degree; I++) pdX[I] = (pdX[I] + D*pdY[I + dY - dX])%prime;
         dX = dD;
      }
      if (dX == 0) {
         long D = DivG1(1, pX[0]);
         for (int I = 0; I < degree; I++) SetN(Q, I, D*pdX[I]);
         break;
      }
      while (dY >= dX) {
         long D = DivG1(pY[dY], pX[dX]);
         if (D > 0) D = prime - D;
         int dD = 0, I = 0;
         for (; I < dY - dX; I++) if (pY[I] != 0) dD = I;
         for (; I <= dY; I++) {
            long D1 = pY[I] = (pY[I] + D*pX[I + dX - dY])%prime;
            if (D1 != 0) dD = I;
         }
         for (I = dY - dX; I < degree; I++) pdY[I] = (pdY[I] + D*pdX[I + dX - dY])%prime;
         dY = dD;
      }
   }
   return 1;
}

int DivG(galois Q, galois A, galois B) {
   galois C; if (!InvG(C, B)) return 0;
   MulG(Q, A, C); return 1;
}

int ExpG(galois A, int N) {
   galois E; Unit(E, 1);
   if (N == 0) { CopyG(A, Gal1); return 1; }
   char Neg;
   if (N < 0) {
      if (ZeroG(A)) return 0;
      Neg = 1, N = -N;
   } else Neg = 0;
   galois P; CopyG(P, A);
   for (; N > 0; N >>= 1) {
      galois M;
      if (N&1) MulG(M, E, P), CopyG(E, M);
      MulG(M, P, P), CopyG(P, M);
   }
   if (Neg) Unit(P, 1), DivG(A, P, E);
   else CopyG(A, E);
   return 1;
}

unsigned PrimeG(void) { return prime; }
unsigned DegreeG(void) { return degree; }
unsigned ResidueG(unsigned *Res) {
   for (unsigned I = 0; I < degree; I++) Res[I] = residue[I];
   return degree;
}

void SetField(unsigned P, unsigned M, unsigned *Res) {
// Constraints: P < 0x10000, P^M <= 2^GWID.
   unsigned OldP = prime, OldD = degree, OldB = bits;
   gal_error = 0;
   if (Res == 0) { gal_error = INVALID_GX; return; }
   if (M == 0) { gal_error = IS_UNIT; return; }
   if (P < 2) { gal_error = NOT_PRIME; return; }
   if (P > 0xffff) { gal_error = PRIME_TOO_BIG; return; }
   for (int I = 0; I < WIDTH(Sieve); I++)
      if (P == Sieve[I]) break;
      else if (P%Sieve[I] == 0) { gal_error = NOT_PRIME; return; }
   bits = 0;
   for (int I = P - 1; I != 0; I >>= 1, bits++);
   if (M > GSIZE/bits) { gal_error = POLY_TOO_BIG; goto FAILED1; }
// Test x^M - Res for irreducibility.
// Form the set { (x^(pi) - x^i)%g(x): 0 <= i < m }.
   galois *GP = malloc(M*sizeof *GP);
   if (GP == 0) {
      if (MemFailGP != 0) MemFailGP("Out of memory."); else fprintf(stderr, "Out of memory.");
      exit(1);
   }
   prime = P, degree = M;
   for (int I = 0; I < M; I++) {
      long D = residue[I]; residue[I] = Res[I]%prime, Res[I] = D;
   }
   galois A; Unit(A, 1);
   galois H; Unit(H, 1), ShiftG(H), ExpG(H, prime);
   for (int I = 0; I < M; I++) {
      CopyG(GP[I], A);
      galois G; MulG(G, A, H); CopyG(A, G);
      SetN(GP[I], I, GetN(GP[I], I) - 1L);
   }
// Find all linear dependencies of the set by row reduction.
   int I = 1;
   for (; I < M; I++) {
      int J = 0;
      for (; J < M; J++) {
         long D = GetN(GP[I], J);
         if (D != 0) { MulG1(GP[I], DivG1(1, (unsigned)D)); break; }
      }
      if (J == M) break;
      for (int K = I + 1; K < M; K++) {
         long D = GetN(GP[K], J); if (D == 0) continue;
         CopyG(H, GP[I]), MulG1(H, (unsigned)D);
         SubG(GP[K], H);
      }
   }
   free(GP);
   if (I < M) goto FAILED; // Rows 0 and I are both 0. x^M - Res factors.
   int dX = 0;
   for (; dX < M; dX++) pX[dX] = residue[dX] == 0? 0: P - residue[dX];
   pX[M] = 1;
   int dY = -1;
   for (int I = 1; I <= M; I++) {
      long D = pY[I - 1] = (I*pX[I])%prime;
      if (D != 0) dY = I - 1;
   }
   while (1) {
      if (dY == -1) goto FAILED; else if (dY == 0) return;
      while (dX >= dY) {
         long D = DivG1(pX[dX], pY[dY]);
         if (D > 0) D = prime - D;
         int dD = -1, I = 0;
         for (; I < dX - dY; I++) if (pX[I] != 0) dD = I;
         for (; I <= dX; I++) {
            long D1 = pX[I] = (pX[I] + D*pY[I + dY - dX])%prime;
            if (D1 != 0) dD = I;
         }
         dX = dD;
      }
      if (dX == -1) goto FAILED; else if (dX == 0) return;
      while (dY >= dX) {
         long D = DivG1(pY[dY], pX[dX]);
         if (D > 0) D = prime - D;
         int dD = -1, I = 0;
         for (; I < dY - dX; I++) if (pY[I] != 0) dD = I;
         for (; I <= dY; I++) {
            long D1 = pY[I] = (pY[I] + D*pX[I + dX - dY])%prime;
            if (D1 != 0) dD = I;
         }
         dY = dD;
      }
   }
FAILED:
   prime = OldP, degree = OldD;
   for (int I = 0; I < M; I++) {
      long D = residue[I]; residue[I] = Res[I], Res[I] = D;
   }
   gal_error = NOT_IRREDUCIBLE;
FAILED1:
   bits = OldB; return;
}

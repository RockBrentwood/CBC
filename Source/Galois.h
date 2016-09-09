// This implementation assumes that long integers are at least GWID (32) bits.
#define GLEN  8
#define GSIZE 0x100
typedef unsigned long galois[GLEN];

extern int gal_error;
#define NUM_INFINITY    1
#define NOT_READ        2
#define NOT_PRIME       3
#define PRIME_TOO_BIG   4
#define NOT_IRREDUCIBLE 5
#define INVALID_GX      6
#define POLY_TOO_BIG    7
#define IS_UNIT         8

extern int (*GetGP)(void);
extern void (*UnGetGP)(int Ch);
extern void (*PutGP)(char *S, ...);
extern void (*MemFailGP)(char *Msg);

extern galois Gal0, Gal1;
extern unsigned GetN(galois G, unsigned N); 	// G[N]
extern void SetN(galois G, unsigned N, long D);	// G[N] = D
extern void CopyG(galois A, galois B);		// A = B
extern void AddG(galois A, galois B);		// A += B
extern void SubG(galois A, galois B);		// A -= B
extern void IncG(galois A, int Dir);		// A++/A--
extern void NegG(galois A);			// A = -A
extern void ShiftG(galois G);			// A *= x
extern void MulG(galois P, galois A, galois B);	// P = A*B
extern void PutGal(galois G);			// << G
extern int GetGal(galois G);			// >> G
extern void Unit(galois A, unsigned U);		// G = (galois)U;
extern int ZeroG(galois A);			// A == 0
extern int EqualG(galois A, galois B);		// A == B
extern int InvG(galois Q, galois A);		// Q = 1/A
extern int DivG(galois Q, galois A, galois B);	// Q = A/B
extern int ExpG(galois A, int N);		// A ^= N

// Setting and obtaining the field components.
// Initialize the field GF(P^M) over polynomial x^M - Res.
extern unsigned PrimeG(void);
extern unsigned DegreeG(void);
extern unsigned ResidueG(unsigned *Res);
extern void SetField(unsigned P, unsigned M, unsigned *Res);

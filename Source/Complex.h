typedef struct { number X, Y; } complex;
extern complex Com0(void);			// (complex)0
extern number NormC(complex A);			// |A|
extern complex ComplexC(number A, number B);	// A + iB
extern complex CopyC(complex C);
extern void DeleteC(complex C);
extern void SetC(complex *CP, complex A);	// *CP = A;
extern int EqualC(complex A, complex B);	// A == B
extern complex AddC(complex A, complex B);	// A + B
extern complex SubC(complex A, complex B);	// A - B
extern complex NegC(complex A);			// -A
extern int ZeroC(complex A);			// A == 0
extern complex IncC(complex A, int Dir);	// A + Dir
extern complex MulC(complex A, complex B);	// A*B
extern complex DivC(complex A, complex B);	// A/B
extern complex InvC(complex A);			// conjugate of A
extern complex ExpC(complex A, number B);	// A^B
extern void PutC(complex A);
extern complex GetC(void);

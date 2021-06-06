#if !defined(OnceOnly)
#define OnceOnly

#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>

#define CBC_VERSION "cbc version 1.4"

// Used for the local version of C-BC. Already defined in the makefile.
#define MATH_LIB "/usr/local/lib/math.b"
// #define MATH_LIB "."

typedef enum { false = 0, true = 1 } bool;
typedef unsigned char byte;
typedef unsigned short word;

// Number.h:
typedef struct number *number;
typedef long digit;
struct number {
   signed char Sign; int Digits, Scale; unsigned Copies; digit D[1];
};

extern void (*UnGetNP)(int Ch);
extern int (*GetNP)(void);
extern void (*PutNP)(char *S, ...);
extern void (*MemFailNP)(char *Msg);

extern digit OBase;
extern int Scale, IBase;

extern int NumError;
#define NUM_INFINITY 1
#define NOT_READ     2
#define EXP_TOO_BIG  4
#define NEG_ROOT     6

#define BIG_NUM 1000000000L

number Number(int Digits, int Scale);
number NumLong(long L);
number Num0(void);
number Num1(void);
long Long(number A);
int CompNum(number A, number B);
number CopyNum(number A);
void Delete(number A);
void SetNum(number *AP, number B);
number AddNum(number A, number B);
number SubNum(number A, number B);
number NegNum(number A);
number IncNum(number A, int Dir);
void PutNum(number A);
number GetNum(void);
bool IsZero(number B);
number MulNum(number A, number B);
number DivNum(number A, number B);
number InvNum(number B);
number ModNum(number A, number B);
number RootNum(number A);
number ExpNum(number A, number B);

// Complex.c:
typedef struct { number X, Y; } complex;
complex Com0(void);			// (complex)0
number NormC(complex A);		// |A|
complex ComplexC(number A, number B);	// A + iB
complex CopyC(complex C);
void DeleteC(complex C);
void SetC(complex *CP, complex A);	// *CP = A;
bool EqualC(complex A, complex B);	// A == B
complex AddC(complex A, complex B);	// A + B
complex SubC(complex A, complex B);	// A - B
complex NegC(complex A);		// -A
bool ZeroC(complex A);			// A == 0
complex IncC(complex A, int Dir);	// A + Dir
complex MulC(complex A, complex B);	// A*B
complex DivC(complex A, complex B);	// A/B
complex InvC(complex A);		// conjugate of A
complex ExpC(complex A, number B);	// A^B
void PutC(complex A);
complex GetC(void);

// Galois.h:
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
unsigned GetN(galois G, unsigned N); 		// G[N]
void SetN(galois G, unsigned N, long D);	// G[N] = D
void CopyG(galois A, galois B);			// A = B
void AddG(galois A, galois B);			// A += B
void SubG(galois A, galois B);			// A -= B
void IncG(galois A, int Dir);			// A++/A--
void NegG(galois A);				// A = -A
void ShiftG(galois G);				// A *= x
void MulG(galois P, galois A, galois B);	// P = A*B
void PutGal(galois G);				// << G
bool GetGal(galois G);				// >> G
void Unit(galois A, unsigned U);		// G = (galois)U;
bool ZeroG(galois A);				// A == 0
bool EqualG(galois A, galois B);		// A == B
bool InvG(galois Q, galois A);			// Q = 1/A
bool DivG(galois Q, galois A, galois B);	// Q = A/B
bool ExpG(galois A, int N);			// A ^= N

// Setting and obtaining the field components.
// Initialize the field GF(P^M) over polynomial x^M - Res.
unsigned PrimeG(void);
unsigned DegreeG(void);
unsigned ResidueG(unsigned *Res);
void SetField(unsigned P, unsigned M, unsigned *Res);

// Scan.c:
typedef enum {
   Dump = 1, Include, Log, Define, Auto,
   Quit, If, Else, While, Do, For, Switch, Case, Default, Goto, Continue, Break, Halt, Return,
   INPUT, OUTPUT, COMMA, SEMI, LBR, RBR, LPAR, RPAR, LCURL, RCURL,
   COLON, QUEST, OR, AND, NOT, REL_OP, ADD_OP, MUL_OP, EXP_OP,
   SIGN_OP, INC_OP, EQ_OP, ADDR, NEW, FREE,
   TYPE, NAME, STRING, NUMBER, GALOIS, ZERO
} Lexical;

typedef unsigned long SType;
typedef enum { ZeroT, NumberT, ComplexT, GaloisT, StringT } Scalar;
#define PointerOf(T) (2*(T) + 3)
#define ArrayOf(T)   (2*(T) + 4)
#define Deref(T)     (((T) - 3) >> 1)
#define IsPointer(T) ((T) > StringT && ((T)&1))
#define IsArray(T)   ((T) > StringT && !((T)&1))
#define IsScalar(T)  ((T) <= StringT)

extern FILE *LogF;
extern char Text[];
extern int Value, Line;
extern bool FakeSemi;

extern int Errors;
void Error(const char *Format, ...);
void Fatal(const char *Format, ...);
void *Allocate(unsigned N);
void *Reallocate(void *X, unsigned N);
char *CopyS(char *S);
void OpenF(char *Name);
extern Lexical LastL;
Lexical Scan(void);

// Load.c:
#define NO_LABEL 0 // Actually, this points to the return statement.
typedef struct State *State;
struct State { State TB, FB; char *Continue; };

int Label(void);
void Generate(char *Format, ...);
void Interpret(void);
void EndLoad(void);
void StartLoad(void);

void PurgeStates(void);
void StoreStates(State *Head, State *Tail);
void FreeStates(State Head, State Tail);

// Symbol.c:
typedef enum { GlobalS, DefineS, ParamS, AutoS } Scope;
typedef enum { FUNCTION, ARRAY, VARIABLE, LABEL } SymTag;

// Predefined functions.
#define SqrtA     0
#define ScaleA    1
#define LengthA   2
#define ShellA    3
#define IFileA    4
#define OFileA    5
#define AFileA    6
#define CompA     7
#define ReA       8
#define ImA       9
#define FieldA   10
#define PrimeA   11
#define DegreeA  12
#define GxA      13
#define GalSetA  14
#define GalGetA  15

// Predefined variables.
#define IBaseAddr 0
#define OBaseAddr 1
#define ScaleAddr 2
#define LastAddr  3
#define LastCAddr 4
#define LastGAddr 5
#define LastSAddr 6
void BuiltIns(void);

// Declaration routines.
void SetAutos(void);
void ResetLocals(void);
void FreeLabels(void);
void DeclareVar(char *Name, Scope Mode, SType Type);
void DeclareFunct(char *Name, Scope Mode, SType Type);
int LookUp(char *Name, SymTag Tag, SType *TypeP);

// Function attributes.
typedef struct Arg *Arg;
struct Arg { SType Type; unsigned Addr; };

typedef struct Function *Function;
struct Function {
   SType Type; bool Declared; int Defined; char *Name;
   Arg Params, PP, Autos, AP;
   State Start, End;
};

// Function type checking and definition routines.
extern Function FTab;
extern int Fs;
int Arity(unsigned Addr);
SType ParamType(unsigned Addr, int N);
SType ReturnType(void);
void DefineFunction(void);

#define MAX_STORE 0x10000L
typedef struct variable *variable;
typedef struct array *array;
struct variable {
   array Base; unsigned Offset; variable Next;
   SType Type; char *Name; long Addr;
   union { char *S; galois G; number N; complex C; variable V; array A; } Val;
};

typedef union Tree *Tree;
union Tree {
   variable Leaf[16]; Tree Branch[16];
};

struct array {
// Ref: Used to return array parameters.
   array Ref; array Next;
   SType Type; char *Name; long Addr;
   Tree Root;
};

void NewVar(Arg A, ...);
void FreeVar(Arg A);

variable GetVar(unsigned Addr);
array GetArr(unsigned Addr);
variable GetPointer(array A, unsigned N);
array NewArray(SType Type);
void FreeArray(array A);
void CheckLabel(char *Name, int Addr);

// Expression.c:
void Exp(void);
extern bool HaveName, HaveParen;
extern int Reference;
extern SType Type;
extern char *Name;

// Statement.c:
void Parse(char *Path);

// Execute.c:
void SetStacks(void);
void PurgeStacks(void);
void Execute(State Start, State End);
void InitIOFiles(void);
void Put1(char *Format, ...);

#endif // OnceOnly

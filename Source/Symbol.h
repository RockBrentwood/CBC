#include "Galois.h"
#include "Number.h"
#include "Complex.h"

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
extern void BuiltIns(void);

// Declaration routines.
extern void SetAutos(void);
extern void ResetLocals(void);
extern void FreeLabels(void);
extern void DeclareVar(char *Name, Scope Mode, SType Type);
extern void DeclareFunct(char *Name, Scope Mode, SType Type);
extern int LookUp(char *Name, SymTag Tag, SType *TypeP);

// Function attributes.
typedef struct Arg *Arg;
struct Arg { SType Type; unsigned Addr; };

typedef struct Function *Function;
struct Function {
   SType Type; char Declared, Defined; char *Name;
   Arg Params, PP, Autos, AP;
   State Start, End;
};

// Function type checking and definition routines.
extern Function FTab;
extern int Fs;
extern int Arity(unsigned Addr);
extern SType ParamType(unsigned Addr, int N);
extern SType ReturnType(void);
extern void DefineFunction(void);

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

extern void NewVar(Arg A, ...);
extern void FreeVar(Arg A);

extern variable GetVar(unsigned Addr);
extern array GetArr(unsigned Addr);
extern variable GetPointer(array A, unsigned N);
extern array NewArray(SType Type);
extern void FreeArray(array A);
extern void CheckLabel(char *Name, int Addr);

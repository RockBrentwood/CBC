#include <stdarg.h>
#include <stdio.h>
typedef unsigned char byte;
typedef unsigned short word;

typedef enum {
   Dump = 1, Include, Log, Define, Auto,
   Quit, If, Else, While, Do, For, Goto, Continue, Break, Halt, Return,
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

extern int Errors;
extern void Error(const char *Format, ...);
extern void Fatal(const char *Format, ...);
extern void *Allocate(unsigned N);
extern void *Reallocate(void *X, unsigned N);
extern char *CopyS(char *S);
extern void OpenF(char *Name);
extern Lexical LastL;
extern Lexical Scan(void);

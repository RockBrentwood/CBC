#include <limits.h>

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

extern number Number(int Digits, int Scale);
extern number NumLong(long L);
extern number Num0(void);
extern number Num1(void);
extern long Long(number A);
extern int CompNum(number A, number B);
extern number CopyNum(number A);
extern void Delete(number A);
extern void SetNum(number *AP, number B);
extern number AddNum(number A, number B);
extern number SubNum(number A, number B);
extern number NegNum(number A);
extern number IncNum(number A, int Dir);
extern void PutNum(number A);
extern number GetNum(void);
extern int IsZero(number B);
extern number MulNum(number A, number B);
extern number DivNum(number A, number B);
extern number InvNum(number B);
extern number ModNum(number A, number B);
extern number RootNum(number A);
extern number ExpNum(number A, number B);

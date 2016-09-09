#define NO_LABEL 0 // Actually, this points to the return statement.
typedef struct State *State;
struct State { State TB, FB; char *Continue; };

extern int Label(void);
extern void Generate(char *Format, ...);
extern void Interpret(void);
extern void EndLoad(void);
extern void StartLoad(void);

extern void PurgeStates(void);
extern void StoreStates(State *Head, State *Tail);
extern void FreeStates(State Head, State Tail);

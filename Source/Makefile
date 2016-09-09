#LIBDIR: where to put math.b
#LIBDIR=.
LIBDIR=/usr/local/lib

#BINDIR: where to put the executable
#BINDIR=.
BINDIR=/usr/local/bin

## Discontinued and replaced by C_BC.pdf and CBC.1.htm.
## #MANDIR: where to put C_BC.1
## #MANDIR=.
## MANDIR=/usr/local/man/man1

#The remove-file command
#RM=del
RM=rm

#The copy command
#CP=copy
CP=cp

#The compiler and linker to use
#CC=lcc
CC=gcc
#LN=lcclnk
LN =gcc

#Extra compiler flags (to make large memory model program on DOS)
#CFLAGS=
CFLAGS=-std=gnu99 -O2
#Extra linker flags (to link in the math library on UNIX)
#LINK_FLAGS=
LINK_FLAGS=-lm

#Object and executable file suffices.
#O=.obj
O=.o
#X=.exe
X =
### End of user definitions

CBC_OBJS=C_BC$O Statement$O Expression$O Symbol$O Scan$O Load$O Execute$O Galois$O Number$O Complex$O

all:	cbc$X
cbc$X:	$(CBC_OBJS)
	$(LN) -o cbc$X $(CBC_OBJS) $(LINK_FLAGS)
C_BC$O:		C_BC.c Scan.h Load.h Symbol.h Version.h
	$(CC) -c $(CFLAGS) C_BC.c
Galois$O:	Galois.c Galois.h
	$(CC) -c $(CFLAGS) Galois.c
Number$O:	Number.c Number.h
	$(CC) -c $(CFLAGS) Number.c
Complex$O:	Complex.c Number.h Complex.h
	$(CC) -c $(CFLAGS) Complex.c
Symbol.h:	Galois.h Number.h Complex.h
Symbol$O:	Symbol.c Scan.h Load.h Symbol.h
	$(CC) -c $(CFLAGS) Symbol.c
Scan$O:		Scan.c Scan.h
	$(CC) -c $(CFLAGS) Scan.c
Expression$O:	Expression.c Scan.h Load.h Symbol.h
	$(CC) -c $(CFLAGS) Expression.c
Statement$O:	Statement.c Scan.h Load.h Symbol.h
	$(CC) -c $(CFLAGS) Statement.c
Load$O:		Load.c Scan.h Load.h Symbol.h Execute.h
	$(CC) -c $(CFLAGS) Load.c
Execute$O:	Execute.c Scan.h Load.h Symbol.h Execute.h
	$(CC) -c $(CFLAGS) Execute.c
clean:
	$(RM) *$O
install: cbc$x
	install -s cbc$X $(BINDIR)
	$(CP) math.b $(LIBDIR)
##	$(CP) C_BC.1 $(MANDIR)

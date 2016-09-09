# CBC
A typed version of POSIX BC enhanced with a large number of features from C.

This is the legacy distribution from 1993 originally contained in the comp.compilers archive and re-released in 2001.

It is undergoing upward revision to expand its type system,
to remove the incompatibilities with POSIX BC entailed by having a type system,
to speed up its multiplication routine to bring it to parity with GNU-BC,
to include support for multithreaded programming, and
to both improve its math.b routines and add in more of the functionality of "calc" and of LAPACK and ALGLIB.

Currently it compiles under any platform with GCC (which the Makefile has been configured for).
With minor changes it will compile under Windows with LCC-WIN or LCC.

There are no other library or utility dependencies. Neither bison/yacc nor flex/lex are required.

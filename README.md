# CBC
C-BC is a typed version of POSIX BC enhanced with a large number of features from C.

This is the legacy distribution from 1993 originally contained in the comp.compilers archive and re-released in 2001.

It is undergoing upward revision to expand its type system,
- to remove the incompatibilities with POSIX BC entailed by having a type system,
- to speed up its multiplication routine
- to bring it to parity with GNU-BC,
- to include support for multithreaded programming, and
- to both improve its math.b routines and add in more of the functionality of "calc" and of LAPACK and ALGLIB.

Currently it compiles under GCC (which the Makefile has been configured for). With minor changes it will compile under Windows with LCC-WIN or LCC; and probably also VC.

There are no other library or utility dependencies. Neither bison/yacc nor flex/lex are required.

To install this software package, go into the Source directory, make the appropriate modifications to the first several lines of the Makefile, and then run: "make".

The following files have been included in this version of C-BC:
	C-BC Source Code
		README Makefile Version.h
		Number.c Complex.c Execute.c Galois.c Scan.c Symbol.c Load.c Expression.c C_BC.c Statement.c
		Number.h Complex.h Execute.h Galois.h Scan.h Symbol.h Load.h
		math.b
	C-BC Auxiliary Directories
		Test -- Test programs for C-BC.
		Examples -- Samples from the GNU-BC archive of sample programs.

There may also be C-BC source files already present or later included that are not listed here. Primarily intended to test and demonstrate C-BC's functionality, they may be later consolidated into an expansion of the POSIX-mandated math library (math.b)

This software has been developed using my own personal resources and time, and is being released into the public domain free of licensing and copyright restrictions. If you'd like to try your hand at hacking it I encourage you to do so and to distribute and substantial improvements you may come up with in the same spirit that this is being distributed: free of restrictions. In fact, I've made available a specification of the desired extensions along with the rest of the documentation.

This implementation was originally generated over a several month period in late 1992, with numerous revisions in the early part of 1993, and in early summer of 1993. It's actually come in handy for me on the most unexpected occasions (e.g.: the generation of editing and production command-line scripts for music and video). Minor upgrades have been made in 2001 and more recently in 2015-onward with a major expansion now in the works to include support for multi-threaded programming; particularly geared toward making this suitable as a language for multi-media scripting.

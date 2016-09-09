#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include "Version.h"
#include "Scan.h"
#include "Load.h"
#include "Symbol.h"
#include "Execute.h"

extern void Parse(char *Path);

int main(int AC, char *AV[]) {
   BuiltIns(); InitIOFiles();
   int DoV = 0, DoH = 0, DoL = 0;
   int A = 1;
   for (; A < AC; A++) {
      char *AP = AV[A];
      if (*AP++ != '-') break;
      for (; *AP != '\0'; AP++) switch (*AP) {
         case 'l': DoL++; break;
         case 'v': DoV++; break;
         default: DoH++; break;
      }
   }
   if (DoH) {
      printf(
         "Usage: cbc -lvh? Files...\n"
         "    -l ...... include math library\n"
         "    -v ...... print out version\n"
         "    -h/-? ... print this list\n"
      );
      return EXIT_FAILURE;
   }
   if (DoV) { puts(CBC_VERSION); return EXIT_SUCCESS; }
   if (DoL) Parse(MATH_LIB);
   for (; A < AC; A++) Parse(AV[A]);
   Parse(0);
   return EXIT_SUCCESS;
}

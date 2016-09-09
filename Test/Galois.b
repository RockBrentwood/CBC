"
   *** Galois test for fields GF(2^n), n = 1, 2, 3, 4 ***
"
define test1(u) {
   a[0] = u, s = field(2, 1, a[])
   if (s) return 0
   b[0] = 0, d = gal_gx(b[])
   <- "Residue: (", d, "), ", b[0],\
      "... x^1 = ", $10^1, "... p: ", gal_p(), ", m: ", gal_m(), "\n"
   return 1
}

define test2(u, v) {
   a[0] = u, a[1] = v, s = field(2, 2, a[])
   if (s) return 0
   b[0] = 0, b[1] = 0, d = gal_gx(b[])
   <- "Residue: (", d, "), ", b[0], ", ", b[1],\
      "... x^2 = ", $10^2, "... p: ", gal_p(), ", m: ", gal_m(), "\n"
   return 1
}

define test3(u, v, w) {
   a[0] = u, a[1] = v, a[2] = w, s = field(2, 3, a[])
   if (s) return 0
   b[0] = 0, b[1] = 0, b[2] = 0, d = gal_gx(b[])
   <- "Residue: (", d, "), ", b[0], ", ", b[1], ", ", b[2],\
      "... x^3 = ", $10^3, "... p: ", gal_p(), ", m: ", gal_m(), "\n"
   return 1
}

define test4(u, v, w, x) {
   a[0] = u, a[1] = v, a[2] = w, a[3] = x, s = field(2, 4, a[])
   if (s) return 0
   b[0] = 0, b[1] = 0, b[2] = 0, b[3] = 0, d = gal_gx(b[])
   <- "Residue: (", d, "), ", b[0], ", ", b[1], ", ", b[2], ", ", b[3],\
      "... x^4 = ", $10^4, "... p: ", gal_p(), ", m: ", gal_m(), "\n"
   return 1
}

n = test1(0) + test1(1);
<- "Degree 1: ", n, " field(s) exist\n\n"

n = test2(0, 0) + test2(0, 1) + test2(1, 0) + test2(1, 1);
<- "Degree 2: ", n, " field(s) exist\n\n"

n = test3(0, 0, 0) + test3(0, 0, 1) + test3(0, 1, 0) + test3(0, 1, 1)\
  + test3(1, 0, 0) + test3(1, 0, 1) + test3(1, 1, 0) + test3(1, 1, 1);
<- "Degree 3: ", n, " field(s) exist\n\n"

n = test4(0, 0, 0, 0) + test4(0, 0, 0, 1)\
  + test4(0, 0, 1, 0) + test4(0, 0, 1, 1)\
  + test4(0, 1, 0, 0) + test4(0, 1, 0, 1)\
  + test4(0, 1, 1, 0) + test4(0, 1, 1, 1)\
  + test4(1, 0, 0, 0) + test4(1, 0, 0, 1)\
  + test4(1, 0, 1, 0) + test4(1, 0, 1, 1)\
  + test4(1, 1, 0, 0) + test4(1, 1, 0, 1)\
  + test4(1, 1, 1, 0) + test4(1, 1, 1, 1)
<- "Degree 4: ", n, " field(s) exist\n"

galois g; number d

a[0] = 0, a[1] = 0, a[2] = 0, a[3] = 1, g = gal_set(3, a[])
<- "Set x^3: ", g, "\n"

g = $101, a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = 0, d = gal_get(g, a[])
<- "Get $0101: (", d, "): ", a[5], a[4], a[3], a[2], a[1], a[0], "\n"


"
   *** Galois test for fields GF(3^n), n = 1, 2 ***
"
// Note the reuse of the functions test1() and test2().
define test1(u) {
   a[0] = u, s = field(3, 1, a[])
   if (s) return 0
   b[0] = 0, d = gal_gx(b[])
   <- "Residue: (", d, "), ", b[0],\
      "... x^1 = ", $10^1, "... p: ", gal_p(), ", m: ", gal_m(), "\n"
   return 1
}

define test2(u, v) {
   a[0] = u, a[1] = v, s = field(3, 2, a[])
   if (s) return 0
   b[0] = 0, b[1] = 0, d = gal_gx(b[])
   <- "Residue: (", d, "), ", b[0], ", ", b[1],\
      "... x^2 = ", $10^2, "... p: ", gal_p(), ", m: ", gal_m(), "\n"
   return 1
}

n = test1(0) + test1(1) + test1(2);
<- "Degree 1: ", n, " field(s) exist\n\n"

n = test2(0, 0) + test2(0, 1) + test2(0, 2)\
  + test2(1, 0) + test2(1, 1) + test2(1, 2)\
  + test2(2, 0) + test2(2, 1) + test2(2, 2);
<- "Degree 2: ", n, " field(s) exist\n\n"

galois g; number d

a[0] = 0, a[1] = 1, g = gal_set(1, a[])
<- "Set x^1: ", g, "\n"

g = $11, a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = 0, d = gal_get(g, a[])
<- "Get $11: (", d, "): ", a[5], a[4], a[3], a[2], a[1], a[0], "\n"
quit

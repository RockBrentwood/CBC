number f(number x);
define test(x0, x1, dx, sc0, sc1) {
   auto sc, x, tries, fail, y0, y1
   if (sc0 >= sc1) sc = sc0, sc0 = sc1, sc1 = sc;
   sc = scale
   for (x = x0, fail = tries = 0; x < x1; x += dx, tries++) {
      scale = sc0, y0 = f(x);
      scale = sc1, y1 = f(x);
      scale = sc0; if (y0 != y1/1) fail++;
   }
   <- "Tests: ", tries, ", Failures: ", fail, ": ",\
      (scale = 2, fail*100/tries), "%\n";
   scale = sc
}

define f(x) { return e(x); }
<- "Exponential:\n"
<- "scale = 10: "; j = test(-50, 50, 5, 10, 14)
<- "scale = 20: "; j = test(-50, 50, 5, 20, 24)

define f(x) { return l(x); }
<- "Logarithm:\n"
<- "scale = 10: "; j = test(1, 10000, 500, 10, 14)
<- "scale = 20: "; j = test(1, 10000, 500, 20, 24)

define f(x) { return s(x); }
<- "Sine:\n"
<- "scale = 10: "; j = test(0, 6.29, .1, 10, 14)
<- "scale = 20: "; j = test(1, 6.29, .1, 20, 24)

define f(x) { return c(x); }
<- "Cosine:\n"
<- "scale = 10: "; j = test(0, 6.29, .1, 10, 14)
<- "scale = 20: "; j = test(1, 6.29, .1, 20, 24)

define f(x) { return a(x); }
<- "Arctangent:\n"
<- "scale = 10: "; j = test(-100, 100, 5, 10, 14)
<- "scale = 20: "; j = test(-100, 100, 5, 20, 24)

define f(x) { return j(n, x); }
<- "Bessel functions\n"
<- "n = 0, scale = 10: "; n = 0, j = test(0, 30, .5, 10, 14)
<- "n = 1, scale = 10: "; n = 1, j = test(0, 30, .5, 10, 14)
<- "n = 0, scale = 20: "; n = 0, j = test(0, 30, .5, 20, 24)
<- "n = 1, scale = 20: "; n = 1, j = test(0, 30, .5, 20, 24)
quit

// Inverse testing of the hyperbolic functions e(x), l(x).
for (t = 0, m = 0, a = 0; a < 150; a += 5) {
   x = l(e(a)) - a; if (x < 0) x = -x
   t += x; if (x > m) m = x
}
<- "l(e(x)): Error: ", t, ", Max: ", m, "\n"

h = sqrt(sqrt(10))
for (t = 0, m = 0, a = 1; a < 100000; a *= h) {
   x = e(l(a)) - a; if (x < 0) x = -x
   t += x; if (x > m) m = x
}
<- "e(l(x)): Error: ", t, ", Max: ", m, "\n"
quit

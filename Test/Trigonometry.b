// Inverse-Testing of the trig functions s(x), c(x), and a(x)
define tan(x) { return s(x)/c(x) }

for (t = 0, m = 0, a = 0; a < 100; a += 5) {
   x = tan(a(a)) - a; if (x < 0) x = -x
   t += x; if (x > m) m = x
}
<- "tan(a(x)): Error: ", t, ", Max: ", m, "\n"
for (t = 0, m = 0, a = 0; a < 1; a += 0.1) {
   x = a(tan(a)) - a; if (x < 0) x = -x
   t += x; if (x > m) m = x
}
<- "a(tan(x)): Error: ", t, ", Max: ", m, "\n"
quit

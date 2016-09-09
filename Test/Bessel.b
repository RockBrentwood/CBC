scale = 3
for (n = 0; n < 5; n++) {
   for (t = m = 0, x = 0; x < 100; x += 5) {
      e = x/2*(j(n + 1, x) + j(n - 1, x)) - n*j(n, x); if (e < 0) e = -e
      t += e; if (e > m) m = e
   }
   <- "j(", n-1, ", x)/j(", n, ", x)//j(", n+1, ", x):"\
       "Error: ", t, ", Max: ", m, "\n"
}
quit

define number show(number base, number power) {
   number i, j, a[], k;
   <- "GF ", base, "^", power, ":\n"
   for (i = 0; i < power; i++) a[i] = 0;
   k = 0;
   while (k < 10) {
      for (j = 0; j < power; j++) {
         if (++a[j] < base) break;
         a[j] = 0;
      }
      if (j >= power) break;
      if (!field(base, power, a[])) {
         k++;
         <- "x^", power
         for (j = power - 1; j >= 0; j--) {
            if (a[j] == 0) continue;
            <- " + ";
            if (a[j] != 1 || j == 0) <- a[j];
            if (j == 0) continue;
            if (j == 1) <- "x"; else <- "x^", j
         }
         <- "\n"
      }
   }
   return k;
}

for (i = 1; i <= 5; i++) show(3, i);
halt;

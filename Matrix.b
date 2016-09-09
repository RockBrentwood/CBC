// Matrix and vector routines.
define flip(number a[][], number b[][], number m, number n) {
   number i, j;
   for (i = 0; i < m; i++) for (j = 0; j < n; j++) b[j][i] = a[i][j];
   return 1;
}

define readV(number a[], number m) {
   number i;
   for (i = 0; i < m; i++) if ((->a[i]) == 0) return 0;
   return 1;
}

define readM(number a[][], number m, number n) {
   number i, j;
   for (i = 0; i < m; i++) for (j = 0; j < n; j++) if ((->a[i][j]) == 0) return 0;
   return 1;
}

define writeV(number a[], number n) {
   number j;
   for (j = 0; j < n; j++) <- "\t", a[j];
   <- "\n";
}

define writeM(number a[][], number m, number n) {
   number i, j;
   for (i = 0; i < m; i++) {
      for (j = 0; j < n; j++) <- "\t", a[i][j];
      <- "\n";
   }
}

define addV(number a[], number b[], number c[], number m) {
   number i, j;
   for (i = 0; i < m; i++) c[i] = a[i] + b[i];
   return 1;
}

define addM(number a[][], number b[][], number c[][], number m, number n) {
   number i, j;
   for (i = 0; i < m; i++) for (j = 0; j < n; j++) c[i][j] = a[i][j] + b[i][j];
   return 1;
}

define mulMV(number a[][], number b[], number c[], number m, number n) {
   number y;
   number i, j;
   for (i = 0; i < m; i++) {
      for (y = 0, j = 0; j < n; j++) y += a[i][j]*b[j];
      c[i] = y;
   }
   return 1;
}

define mulMM(number a[][], number b[][], number c[][], number m, number n, number p) {
   number y;
   number i, j, k;
   for (i = 0; i < m; i++) for (k = 0; k < p; k++) {
      for (y = 0, j = 0; j < n; j++) y += a[i][j]*b[j][k];
      c[i][k] = y;
   }
   return 1;
}

define mulVM(number a[], number b[][], number c[], number n, number p) {
   number y;
   number j, k;
   for (k = 0; k < p; k++) {
      for (y = 0, j = 0; j < n; j++) y += a[j]*b[j][k];
      c[k] = y;
   }
   return 1;
}

define dotVV(number a[], number b[], number n) {
   number c;
   number j;
   for (c = 0, j = 0; j < n; j++) c += a[j]*b[j];
   return c;
}

define mulVV(number a[], number b[], number c[][], number m, number p) {
   number i, k;
   for (i = 0; i < m; i++) for (k = 0; k < p; k++) c[i][k] = a[i]*b[k];
   return 1;
}

define invert(number a[][], number b[][], number n) {
   number buf[][], m, d;
   number i, j, k;
   for (i = 0; i < n; i++) for (j = 0; j < n; j++) buf[i][j] = a[i][j], b[i][j] = (i == j? 1: 0);
   for (i = 0; i < n; i++) {
      if ((m = buf[i][i]) == 0) break;
      for (j = 0; j < n; j++) if (i != j) {
         for (d = buf[j][i]/m, k = 0; k < n; k++) buf[j][k] -= d*buf[i][k], b[j][k] -= d*b[i][k];
      }
      for (k = 0; k < n; k++) buf[i][k] /= m, b[i][k] /= m;
   }
   return i;
}

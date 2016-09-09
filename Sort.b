// Derived from ALGLIB.

number a[], ab[];

define sort(number *aP, number *abP, number n) {
   number aL, aM, aH, a, lts, eqs, gts, les, n0, n1;
   while (n > 16) {
   // Quicksort: choose pivot.
      aL = aP[0], aM = aP[(n - 1)/2], aH = aP[n - 1], a = aM;
      if (aL > aM) aM = aL, aL = a, a = aM;
      if (aM > aH) aM = aH, aH = a, a = aM;
      if (aL > aM) aM = aL, aL = a, a = aM;
   // Pass through aP:
   // *	everything < a goes to the left of aP,
   // *	everything = a goes to the right of abP in reverse order,
   // *	everything > a goes to the left of abP,
   // *	everything from the right of abP to the middle goes to the right of aP back in normal order,
   // *	everything from the left of abP to the middle goes to the right of aP.
      lts = 0, eqs = 0, gts = 0;
      for (n0 = 0; n0 < n; n0++) {
         a = aP[n0];
         if (a < aM) { n1 = lts++; if (n0 != n1) aP[n1] = a; }
         else if (a > aM) { n1 = gts++; abP[n1] = a; }
         else { n1 = n - 1 - eqs++; abP[n1] = a; }
      }
      les = lts + eqs;
      for (n0 = qs, n1 = les - 1; n0 < n; n0++, n1--) aP[n1] = abP[n0];
      for (n0 = 0, n1 = les; n0 < gts; n0++, n1++) aP[n1] = abP[n0];
   // Sort left and right parts of the array (ignoring middle part).
      void=sort(aP, abP, lts);
      aP += les, abP += les, n -= les;
   }
// Non-recursive sort for small arrays.
   for (nH = 1; nH < n; nH++) {
   // Find a place, if any in [0, nH) to insert aP[nH] at.
   // Skip if aP[nH] can be left intact; i.e. if all elements have same value of aP[nH] larger than any of them.
      a = aP[nH]; nL = nH;
      while (--nL >= 0 && aP[nL] > a);
      if (++nL >= nH) continue;
   // Move element nH down to position nL.
      for (n = nH; n > nL; n--) aP[n] = aP[n - 1];
      aP[nL] = a;
   }
}

n = 15;
for (i = 0; i < n; i++) a[i] = i*(n - i) + 3*i + 2;
number *aP, *abP; aP = &a[0], abP = &ab[0];
<-"Beg a={"; for (i = 0; i < n; i++) { if (i > 0) <- ", "; <- a[i]; } <- "}\n";
void=sort(aP, abP, n);
<-"End a={"; for (i = 0; i < n; i++) { if (i > 0) <- ", "; <- a[i]; } <- "}\n";
halt;

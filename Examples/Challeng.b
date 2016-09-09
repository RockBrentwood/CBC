// Derived from the "challenge" program in the GNU-BC distribution.

<- "The generalized 3x + 1 conjecture:\n";
<- "t(x) = x, if x%3 == 0\n"
<- "t(x) = (7x+2)/3, if x%3 == 1\n"
<- "t(x) = (x-2)/3, if x%3 == 2\n"
<- "\nCalling s(y) iterates y, t(y), t(t(y)), ... until reaching 0, -1 or -2.\n"
<- "The number of steps required is recoded.\n"
<- "The 3n+1 conjecture by Keith Matthews is that all numbers lead to 0, -1 or -2\n"
<- "There is a $100 reward for a proof.\n";

// The least remainder >= 0 when a is divided by a b > 0.
/* a%b=m(a,b) if a>=0 or a<0 and b divides a */
/* a%b=m(a,b)-b if a<0, b>0, a not divisible by b */
define mod(a, b) {
   number c; c = a%b;
   return a >= 0? c: c == 0? 0: c + b;
}

define t(x) {
   number r; r = mod(x, 3);
   return r == 0? x: r == 1? (7*x + 2)/3: (x - 2)/3;
}

define s(y) {
   number i, r, x;
   for (x = y, i = 0; i >= 0; i++) {
      r = mod(x, 3);
      if (r == 0) {
         <- "Start: ", y, ", at 0, number of steps: "; return i;
      } else if ((x == -1) || (x == -2)) {
         <- "Start: ", y, ", at ", x, ", number of steps: "; return i;
      }
      <- x = t(x), "\n";
   }
}

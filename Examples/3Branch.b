/* gnubc program: 3branch */
"        A GENERALIZED 3x+1 CONJECTURE:
"
"Let t(x)=x/3 if 3|x, [2x/3] if 3|x-1, [13x/3] if 3|x-2.
"
"If s(y) is typed in, the iterates y, t(y), t(t(y)),... of the 
"
"generalized 3x+1 function t(x) are printed and the number of steps
"
"taken to reach one of 2, 47, 0, -2, -10, -22 is recorded.
"
"(Keith Matthews conjectures that every trajectory will end in one
"
"of these numbers.)
"

/*  the least non-negative remainder when an integer a is divided by a positive integer b */
/* a%b=m(a,b) if a>=0 or a<0 and b divides a */
/* a%b=m(a,b)-b if a<0, b>0, a not divisible by b */
define mod(a, b) {
   auto c
   c = a%b
   if (a >= 0) return(c)
   if (c == 0) return(0)
   return(c + b)	
}

/* int(a,b)=integer part of a/b, a, b integers, b != 0 */
define int(a, b) {
   if (b < 0) {
      a = -a
      b = -b
   }
   return((a - mod(a, b))/b)
}

/* the t(x) function */
define t(x) {
   auto r
   r = mod(x,3)
   if (r == 0) return(x/3)
   if (r == 1) return(int(2*x, 3))
   return (int(13*x, 3))
}

define s(y) {
   auto i, x
   x = y
   for (i = 0; i >= 0; i++) {
      if (x == 2) {
         "starting number = "; y;
         "the number of iterations taken to reach 2 is "
         return(i)
      }
      if (x == 47) {
         "starting number = "; y
         "the number of iterations taken to reach 47 is "
         return(i)
      }
      if (x == 0) {
         "starting number = "; y
         "the number of iterations taken to reach 0 is "
         return(i)
      }
      if (x == -2) {
         "starting number = "; y
         "the number of iterations taken to reach -2 is "
         return(i)
      }
      if (x == -10) {
         "starting number = "; y
         "the number of iterations taken to reach -10 is "
         return(i)
      }
      if (x == -22) {
         "starting number = "; y
         "the number of iterations taken to reach -22 is "
         return(i)
      }
      (x = t(x)) /* this prints t(x) */
   }
}

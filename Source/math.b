scale = 20

// Exponential.
// e(2x) = e(x)^2,
// e(h) = 1 + h + h^2/2! + ..., if h is small
define e(x) {
   auto dy, exp, i, neg, y, oldS
   if (neg = (x < 0)) x = -x;
   oldS = scale, scale += 0.434*x + 4; // scale += log_10(e^x)
   for (exp = 0; x > 1; exp++, x /= 2);
   for (y = 1 + x, dy = x, i = 1; dy > 0; y += dy *= x/++i);
   scale = oldS
   y ^= 2^exp
   return neg? 1/y: y/1;
}

// Logarithm.
// l(x^2) = 2 l(x)
// l((1 + h)/(1 - h)) = 2(h + h^3/3 + h^5/5 + ...), if h is small.
// If x < 0, a "negative square root" error results.
// If x == 0, a "divide by zero" error results.
define l(x) {
   auto dy, n, h, h2, exp, y, oldS
   if (x == 0) return 1/0;
   else if (x < 0) return sqrt(x);
   oldS = scale; scale += 3
   for (exp = 1; x >= 2; exp++, x = sqrt(x));
   for (;  x <= 0.5 ; exp++, x = sqrt(x));
   scale += 1 + .434*exp
   h = (x - 1)/(x + 1); h2 = h*h
   for (y = 0, n = 1; (dy = h/n) != 0; h *= h2, y += dy, n += 2);
   y *= 2^exp;
   scale = oldS; return y/1
}

// Arctangent.
// a(x) = 2 a((sqrt(1 + x^2) - 1)/x)
// a(h) = h - h^3/3 + h^5/5 - ..., if |h| < 0.2
define a(x) {
   auto exp, oldS, x2, y, n, i, dy
   oldS = scale, scale += 4
   for (exp = 0; x > 0.2; x = (sqrt(1 + x*x) - 1)/x, exp++);
   for (; x < -0.2; x = (sqrt(1 + x*x) - 1)/x, exp++);
   scale += exp;
   x2 = -x*x;
   for (y = 0, n = x, i = 1; (dy = n/i) != 0; y += dy, i += 2, n *= x2);
   scale = oldS;
   y *= 2^exp;
   return y/1
}

// Sine.
// s(-x) = -s(x)
// s(2 pi + x) = s(x)
// s(pi + x)   = -s(x) = s(-x)
// s(h) = h - h^3/3! + h^5/5! - h^7/7! + ..., if -pi < h < pi.
define s(x) {
   auto dy, i, neg, n, s, y, oldS, pi
   oldS = scale, scale += 2;
   pi = 3.141592653589793238462643383279502884197169399375105820974944/1
   if (x < 0) neg = 1, x = -x;
   scale = 0; n = x/pi; x -= pi*n
   if (n%2) x = -x
   scale = oldS + 6;
   s = -x*x
   for (y = dy = x, i = 3; ; y += dy, i += 2)
      if ((dy *= s/(i*(i - 1))) == 0) break;
   if (neg) y = -y;
   scale = oldS
   return y/1;
}

// Cosine.
// c(-x) = c(x)
// c(2 pi + x) = c(x)
// c(pi + x)   = -c(x)
// c(h) = 1 - h^2/2! + h^4/4! - h^6/6! + h^8/8! - ..., if -pi < h < pi.
define c(x) {
   auto dy, i, neg, n, s, y, oldS, pi
   oldS = scale, scale += 2;
   pi = 3.141592653589793238462643383279502884197169399375105820974944/1
   if (x < 0) x = -x;
   scale = 0; n = x/pi; x -= pi*n
   scale = oldS + 6;
   s = -x*x
   for (y = dy = 1, i = 2; ; y += dy, i += 2)
      if ((dy *= s/(i*(i - 1))) == 0) break;
   scale = 0
   if (n%2) y = -y
   scale = oldS
   return y/1;
}

// Bessel function, for integer orders n.
// j(-n, x) = (-1)^n*j(n, x)
// j(n, 2x) = x^n/n! - x^(n+2)/1!/(n+1)! + x^(n+4)/2!/(n+2)! - ...
// Factoring x^n/n! increases the precision of computation if x is large.
define j(n, x) {
   auto oldS, neg, oldI, lead, i, x2, dy, y;
   oldS = scale, scale = 0, n /= 1;
   if (n < 0) n = -n, neg = (n%2);
   oldI = ibase, ibase = A;
   for (lead = 1, i = 2; i <= n; i++) lead *= i;
   scale = 1.5*oldS;
   x /= 2, x2 = -x*x, lead = x^n/lead;
   scale = 1.5*oldS + length(lead) - scale(lead);
   for (y = 0, dy = 1, i = 1; dy != 0; y += dy, dy = dy*x2/i/(n + i), i++);
   ibase = oldI, scale = oldS;
   if (neg) y = -y;
   return lead*y/1;
}

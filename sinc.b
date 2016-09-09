scale = 20
pi = 3.141592653589793238462643383279502884197169399375105820974944/1

// sinc(-x) = sinc(x)
// sinc(x + n) = (-1)^n sinc(x) x/(x + n);
// sinc(h) = 1 - (pi h)^2/3! + (pi h)^4/5! - (pi h)^6/7! + ..., if -1 < h < +1.
define sinc(x) {
   auto oldS, n, factor, s, y, dy, i;
   if (x == 0) return 1; else if (x < 0) x = -x;
   oldS = scale, scale = 0; n = x/1; x -= n;
   if (n%2) factor = -1; else factor = +1;
   scale = oldS + 6;
   factor *= x/(x + n);
   s = -((pi*x)^2)
   for (y = dy = 1, i = 3; ; y += dy, i += 2) if ((dy *= s/(i*(i - 1))) == 0) break;
   y *= factor;
   scale = oldS
   return y/1;
}

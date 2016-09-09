"period(num, den, base) with 0 < num < den; 1 < base, gcd(den, base) == 1
yields the period digits of num/den in the given base; and the period length.
"
define gcd(a, b) { // The greatest common divisor of a, b >= 0.
   auto c;
   if (b == 0) return a;
   for (; (c = a%b) > 0; a = b, b = c);
   return b;
}

define period(num, den, base) {
   auto digits, p;
   p = gcd(num, den), num /= p, den /= p; // Reduce the fraction.
   if (gcd(den, base) != 1) {
      "Non repeating fraction: gcd(den, base) != "; return 1;
   }
   if (base <= 1) { "base <= 1: "; return 0; }
   if (num >= den) <- "Integer part: ", num/den, "\n";
   num %= den;
   digits = 0, p = num;
   do {
      p *= base;
      <- " ", p/den; digits++;
      p %= den;
   } while (p != num);
   <- ": the periodic expansion of ", num, "/", den, ", in base ", base, "\n";
   <- "Period length: "; return digits;
}

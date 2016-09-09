// Prime sieve, also demonstrates the goto and pointers
define sieve(n) {
   number prime[], *pp, *ip, p, root
   pp = prime[]
   if (n >= 2) <- *pp++ = 2;
   if (n >= 3) <- ", ", *pp++ = 3;
   if (n >= 5) <- ", ", *pp++ = 5;
   if (n >= 7) <- ", ", *pp++ = 7;
   scale = 0;
   for (p = 11; p <= n; p += 2) {
      root = sqrt(p);
      for (ip = prime[]; ip < pp && *ip <= root; ip++)
         if (p%*ip == 0) goto contin;
      <- ", ", *pp++ = p
      contin:
   }
   <- "\n"
}

limit = 100
<- "Primes up to ", limit, ":\n"; s = sieve(limit)
quit

// Derived from the GNU-BC program Euclid

// Euclid's Algorithm
<- "Call euclid(m, n) with m, n > 0.\n"
<- "The quotients q_k, r_k for the Euclidean algorithm applied to m/n are displayed\n"
<- "This starts with r_0 = r_1 q_1 + r_2\n"

<- "The values s_k, t_k are displayed where\n"
<- "s_0 = 1, s_1 = 0, s_{j+2} = s_j - q_{j+1} s_{j+1}\n"
<- "t_0 = 0, t_1 = 1, t_{j+2} = t_j - q_{j+1} t_{j+1}\n"
<- "for j = 0, 1, ..., n - 1\n"

<- "The length of the algorithm is printed. Type 'quit' to quit.\n";

define euclid(m, n) {
   auto a, b, r, q, i, s0, s1, s2, t0, t1, t2;
   s0 = 1, s1 = 0, t0 = 0, t1 = 1;
   a = m, b = n, r = a%b, q = (a - r)/b;
   <- "   r_0 = ", m, ", s_0 = 1, t_0 = 0\n"
   <- a, " = ", b, " ", q," + ", r, ", q_1 = ", q ,", r_1 = ", n, ", s_1 = 0, t_1 = 1\n"
   for (i = 2; r > 0; i++) {
      s2 = (-q)*s1 + s0, t2 = (-q)*t1 + t0;
      a = b, b = r, r = a%b, q = (a - r)/b;
      <- a, " = ", b, " ", q, " + ", r,", q_", i ," = ", q, ", r_", i, " = ", b, ", s_", i, " = ", s2, ", t_", i, " = ", t2, "\n"
      s0 = s1, s1 = s2, t0 = t1, t1 = t2;
   }
   s2= ( -q)*s1 + s0, t2 = (-q)*t1 + t0
   <- "   r_", i, " = 0, s_", i, " = ", s2, ", t_",i," = ", t2,"\n"
   <- "The Euclidean algorithm for ", m, "/", n, " has length "; return i;
}

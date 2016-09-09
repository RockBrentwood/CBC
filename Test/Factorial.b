define f(x) {
   if (x <= 1) return(1)
   return (f(x - 1)*x)
}

obase = 16
n = 20
z = f(n);
for (a = 0, y = 0; a <= n; a++) y += z/(f(a)*f(n - a))

y
2^n
quit

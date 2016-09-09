/* filename: fraction */
"		THE CONTINUED FRACTION OF A RATIONAL NUMBER:
"
"Let m and n be positive integers.  If cfrac(m,n) is typed,
"
"the partial quotients a[0],...,a[t] of the continued fraction
"
"expansion of m/n, m/n=a[0]+1/a[1]+...+1/a[t], 
"
"are printed. t is also printed. (Type qu to quit)
"
define cfrac(m,n){
   auto a,b,r,q,i
   a=m
   b=n
   r=m%n
   q=(a-r)/b
   <- "a[0]=",q,"\n"
   i=1
   while(r > 0) {
      i=i+1
      a=b
      b=r
      r=a%b
      q=(a-r)/b
      <- "a[",i,"]=",q,"\n"
   }
   <- "the continued fraction of ",m,"/",n," has length ";
   return(i)
}   

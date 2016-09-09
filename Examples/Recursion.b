/* a recursive way of calculating F_n */
define fib(n){
if(n==0)return(0)
if(n==1)return(1)
if(n%2)return((fib((n+1)/2))^2+(fib((n-1)/2))^2)
if(n%2==0)return((fib(n/2))^2+2*fib(n/2)*fib(n/2-1))
}

/* a recursive way of calculating L_n */
define luc(n){
if(n==0)return(2)
if(n==1)return(1)
if(n%2)return((luc((n+1)/2))*(luc((n-1)/2))+(-1)^((n-3)/2))
if(n%2==0)return((luc(n/2))^2+2*(-1)^(n/2-1))
}
/* a recursive way of calculating factorial(n) */
define fac(n){
if(n==1)return(1)
return(n*fac(n-1))
}

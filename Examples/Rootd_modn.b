/* bc program rootd_modn */
<- "This is a crude bc program for producing the solutions\n"
<- " of x^2=d (mod n), with 0<=x<=n/2.\n"
<- "enter d and n and type f(d,n):"
define f(d,n){
auto i,m,t
t=0
m=n/2
for(i=0;i<=m;i++){
if((i^2-d)%n==0){t=t+1;<- i,"\n"}
}
<- "The number of solutions x in 0<=x<=",m," is "
return(t)
}

number int(number a, number b);
number abs(number a);

/* gnubc program: lra */

"





""			LEAST REMAINDER  ALGORITHM







""If lra(m,n) is typed in, the quotients and remainders for the

""least remainder algorithm for m/n are printed, starting with 

""m=n*q+r. 

""The length of the algorithm is printed. (Type quit to quit)

"
/* lnearint(m,n) returns z, the nearest integer to m/n,  
 * z=t if m/n=t+1/2
 */
define lnearint(m,n){
	auto x,y,z
	y=int(m,n)
	x=n*y
	z=2*(m-x)
	if (abs(z)>abs(n)){y=y+1}
	return(y)
}

/* rnearint(m,n) returns z, the nearest integer to m/n,  
 * z=t+1 if m/n=t+1/2
 */
define rnearint(m,n){
	auto x,y,z
	y=int(m,n)
	x=n*y
	z=2*(m-x)
	if (abs(z)>= abs(n)){y=y+1}
	return(y)
}

/* lmodd(m,n) returns r, m=q*n+r, -n/2 < r <= n/2 */
define lmodd(m,n){
	return(m-n*lnearint(m,n))
}

/* rmodd(m,n) returns r, m=q*n+r, -n/2 <= r < n/2 */
define rmodd(m,n){
	return(m-n*rnearint(m,n))
}

define lra(m,n){
	auto a,b,r,q,i
	a=m
	b=n
	q=lnearint(a,b)
	r=a-b*q
	<- "\n"
	<- a," = ",b,"*",q,"+",r,"\n"
	i=1
        while(r!=0){
		i=i+1
                a=b
                b=r
		q=lnearint(a,b)
		r=a-b*q
		<- a," = ",b,"*",q,"+",r,"\n"
        }
	<- "the least remainder algorithm for m/n with m = ",m, " n = ",n
        <- " has length "; return(i)
}   


/* Calculates a[0]=a,a[1]=b,...,a[n], where 
 * a[n+1]=rnearint(a[]*a[n]/a[n-1]), a,b positive integers.
 * Mentioned by Edward Brisse, 19/12/97, in an email.
 */
define rbrisse(a,b,n){
auto i,t
<- "a[0]=",a,"\n"
if(n==0)return
<- "a[1]=",b,"\n"
scale=5
<- "a[1]/a[0]=",b/a,"\n"
scale=0
if(n==1)return
for(i=2;i<=n;i++){
	t=rnearint(b^2,a)
	<- "a[",i,"]=",t,"\n"
	scale=5
	<- "a[",i,"]/a[",i-1,"]=",t/b,"\n"
	scale=0
	a=b
	b=t
}
return
}
/* Calculates a[0]=a,a[1]=b,...,a[n], where 
 * a[n+1]=lnearint(a[]*a[n]/a[n-1]), a,b positive integers.
 * Mentioned by Edward Brisse, 19/12/97, in an email.
 */
define lbrisse(a,b,n){
auto i,t
<- "a[0]=",a,"\n"
if(n==0)return
<- "a[1]=",b,"\n"
scale=5
<- "a[1]/a[0]=",b/a,"\n"
scale=0
if(n==1)return
for(i=2;i<=n;i++){
	t=lnearint(b^2,a)
	<- "a[",i,"]=",t,"\n"
	scale=5
	<- "a[",i,"]/a[",i-1,"]=",t/b,"\n"
	scale=0
	a=b
	b=t
}
return
}

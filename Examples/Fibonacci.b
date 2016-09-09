"If 0 <= m <= n, typing f(m,n) prints the Fibonacci numbers F(i),
""i =m,...,n (Here F(1)=F(2)=1 and 
""F(n) = (({1+sqrt(5)}/2)^n-({1-sqrt(5)}/2)^n)/sqrt(5).

""Typing l(m,n) prints the Lucas numbers L(i), i =m,...,n
""(Here L(1)=1, L(2)=3 and L(n) = ({1+sqrt(5)}/2)^n+({1-sqrt(5)}/2)^n.
"
define f(m,n){
auto i,x,y,z
if (m>n){"m>n: TRY AGAIN: ";return(0)}
x=0
y=1
if(m==1){if(n==1)return(1)}
if(m==1){if(n==2){1;return(1)}}
if(m==1){if(n>=3)1}
i=2
while(i<n){
z=y+x /* z=f(i) */
x=y
y=z
if(i>=m)z
i=i+1
}
return(y+x)
}

define l(m,n){
auto i,x,y,z
if (m>n){"m>n: TRY AGAIN: ";return(0)}
x=2
y=1
if(m==1){if(n==1)return(1)}
if(m==1){if(n==2){1;return(3)}}
if(m==1){if(n>=3)1}
i=2
while(i<n){
z=y+x /* z=l(i) */
x=y
y=z
if(i>=m)z
i=i+1
}
return(y+x)
}

/* a(1)=a,a(2)=b,a(n+2)=c*a(n+1)+d*a(n) if n >= 1 */
define r(n,a,b,c,d){
auto x,y,z,i
if (n == 1)return(a)
if (n == 2)return(b)
x=a;y=b
for(i = 3;i<=n;i++){
	z=c*x+d*y
	x=y
	y=z
}
return(z)
}

/* fi(n)=F_n */
define fi(n){
auto a,b,c,i
if (n == 1)return(1)
if (n == 2)return(1)
a=1;b=1
for(i = 3;i<=n;i++){
	c=a+b
	a=b
	b=c
}
return(c)
}

/* lu(n) = L_n */
define lu(n){
auto a,b,c,i
if (n == 1)return(1)
if (n == 2)return(3)
a=1;b=3
for(i = 3;i<=n;i++){
	c=a+b
	a=b
	b=c
}
return(c)
}

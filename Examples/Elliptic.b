/*
 * These functions are based on the account of the elliptic curve 
 * factorization algorithm of H. Lenstra. in D. Bressoud's book
 * Factorization and primality testing, Springer Undergraduate Text, 1989,
 * 195-217.  We also draw on the account in Niven, Zuckerman and Montgomery
 * An introduction to the theory of numbers, Wiley, 1991, 261-287.
 */

define russm(a,b,c,p){
	auto t
/*
 *  input: unsigned long ints a, b, c, p, with p > 0.
 * output: a + b * c (mod p).
 * Russian Peasant multiplication algorithm. Uses the identities
 * RUSSm(a, b, 2 * c, p) = RUSSm(a, 2 * b, c, p),
 * RUSSm(a, b, c + 1, p) = RUSSm(a + b, b, c, p).
 * If a, b, c and p are less than 2^32, * so is RUSSm(a, b, c, p).
 * From H. Luneburg, "On the Rational Normal Form of * Endomorphisms",
 * B.I. WissenSchaftsverlag, Mannheim/Wien/Zurich, 1987, pp 18-19.
 * Luneburg's restriction to 2*p<2^32 removed by krm on 18/4/94.
 */
	a = a % p
	b = b % p
	c = c % p
	while (c){
		while (c%2 == 0){
			c = c/2
			t = p - b
			if (b < t){b = (2*b)%p}\
			else {b = (b - t) % p}
		}
		c=c-1
		t = p - b
		if(a < t){a=a+b}\
		else {a=a-t}
	}
	return (a)
}

define random(x){
	auto a, c, m
/*
 * input: unsigned int x, output:a "random number" a * x + c (mod m).
 * a = 1001, m = 65536*65536, c = 65;
 * From H. Luneburg, "On the Rational Normal Form of Endomorphisms",
 * B.I. WissenSchaftsverlag, Mannheim/Wien/Zurich, 1987.
 * See Knuth Vol 2, Theorem A, p. 16.
 */
	m = 2^(32)
	a = 1001
	c = 65
	return (russm(c, a, x, m))
}

define m(r,b){
	if(r>=0) return(r%b)
	if(r%b==0) return(0)
        return(r%b+b)	
}

/* absolute value of an integer n */

define t(n){
	if(n>=0) return(n)
	return(-n)
}

/*  gcd(m,n) for any integers m and n */
/* Euclid's division algorithm is used. */

define g(m,n){
	auto r,b,d
	r=t(m)
	if(n==0) return(r)
        b=t(n)
        d=r%b
        while(d>0){
		r=b
                b=d
                d=r%b
        }
	return(b)
}   

/*
 * algorithm X_SUB_2I(r,s), page 213, Bressoud.
 */
define a(r,s,p,q,n){
auto t,g,h,i
g=r*r;h=p*s*s;i=q*s*s*s
if(m(r*(g+h)+i,n)==0){return(0)}
t=m(g-h,n)
return(m(t*t-8*r*i,n))
}

/*
 * algorithm Z_SUB_2I(r,s), page 213, Bressoud.
 */
define c(r,s,p,q,n){
auto t
t=m(r*r*r+p*r*s*s+q*(s^3),n)
if(t==0){return(0)}
return(m(4*s*t,n))
}

/*
 * algorithm X_SUB_2I_PLUS(r,s,u,v), page 213, Bressoud.
 */
define b(x,z,r,s,u,v,p,q,n){
auto f,g
f=m(r*u-p*s*v,n)
g=m(q*s*v*(r*v+s*u),n)
if(x){return(m(z*(f*f-4*g),n))}
f=m(4*q*s*v*s*v,n)
g=m(2*(p*s*v+r*u)*(u*s+r*v),n)
return(m(f+g,n))
}

/*
 * algorithm Z_SUB_2I_PLUS(r,s,u,v), page 214, Bressoud.
 */
define d(x,r,s,u,v,n){
auto t
t=m(u*s-r*v,n)
if(x){return(m(x*t*t,n))}
return(m(t*t,n))
}

/*
 * Algorithm 14.4 , page 214, Bressoud.
 * ecfaglobal and ecfcglobal are global variables.
 */
define o(x,z,k,p,q,n){
auto i,w,c[],b,d,l,u,v,t
for(i=0;i<=20;i++)c[i]=0
i=0
w=k
while(w){
	i=i+1
	c[i]=w%2
	w=w/2
}
l=i;
ecfaglobal=x
ecfcglobal=z
b=a(x,z,p,q,n)
d=c(x,z,p,q,n)
for(i=l-1;i>=1;i--){
	u=b(x,z,ecfaglobal,ecfcglobal,b,d,p,q,n)
	v=d(x,ecfaglobal,ecfcglobal,b,d,n)
	if(c[i]==0){
	t=a(ecfaglobal,ecfcglobal,p,q,n)
	ecfcglobal=c(ecfaglobal,ecfcglobal,p,q,n)
	ecfaglobal=t
	b=u
	d=v
	}
	if(c[i]){
		t=a(b,d,p,q,n)
		d=c(b,d,p,q,n)
		b=t
		ecfaglobal=u
		ecfcglobal=v
	}
}
return(k)
}

/*
 * calculating the order of (x,y,z) on the elliptic curve y^2=x^3+p*x+q,
 * mod n, a prime.
 * 4*p^3+27*q^2 nonzero mod n.
 * See page 205 Bressoud.
 */

define r(x,z,p,q,n){
auto d,k
k=1
ecfcglobal=1
d=4*p^3+27*q^2 
if(d%n==0){<- "discriminant=";return(0)}
while (1){
	o(x,z,k,p,q,n)
	if(ecfcglobal==0)break
	k=k+1
	}
	"order = ";return(k--)
}

/*
 * modified algorithm 14.5, page 216, Bressoud.
 * This program uses the elliptic curve y^2=x^3-Ax+A, as in Niven,
 * Zuckerman, Montgomery, page 285.
 * It is assumed that m <= 588 here.
 * n is the composite number, m is the number of prime powers used in
 * exponentiation on the elliptic curve, p is the starting seed for the
 * random curve y^2=x^3-A*x+A mod n.
 */

define ecf(n,m,p){
auto g,p[],k,t,i,l,w
w=m-10
if(m>588){
"m > ";return(588)
}
l=1
ifile("Elliptic.txt");
for (i = 0; i < 589; i++) ->p[i];
ifile(0);
while(p){
	"elliptic curve ";p
	g=g(4*p*p*p-27,n)
	if(g!=1){
		"discriminant not relatively prime to n
		"
		if(g!=n){
			"found a factor:\n"
			return(g)
		}
	}
	if(g==1){
		ecfaglobal=1;ecfcglobal=1
		k=1
		while(k<=m){
			"k = ";k
			if (k <= w){
				for (i=1;i<=10;i++){
					t=o(ecfaglobal,ecfcglobal,p[k],-p,p,n)
					k=k+1
				}
			}\
			else{
				t=o(ecfaglobal,ecfcglobal,p[k],-p,p,n)
				k=k+1
			}
			g=g(ecfcglobal,n)
			if(g!=1){
				if(g!=n){
				"elliptic curve number ";p
				<- "found a factor:\n"
				l=0
				break
				}
			}
		}
	}
	if(l==0)break
	if(p<0)p= -p
	p=random(p)
}
return(g)
}

/* starting with a seed x, we generate n random numbers */
define randomm(x,n){
auto i,j
j=n-1
for(i=0;i<j;i++){
	(x=random(x))
}
return(random(x))
}

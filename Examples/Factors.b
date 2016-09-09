/* gnubc program: factors */

"
typing factor(n) attempts to factors n using Brent-Pollard.
Consequently In general not very effective on numbers of more
than say 20 digits.
"
ifile("primes.txt");
for (i = 0; i < 168; i++) ->pglobal[i];
ifile(0);

define abs(n) { return (n >= 0)? n: -n; }

/*  the least non-negative remainder when an integer a is divided by a positive
integer b */
/* a%b=m(a,b) if a<=0 or a<0 and b divides a */
/* a%b=m(a,b)-b if a<0, b>0, a not divisible by b */
define m(a,b) {
   auto c; c = a%b;
   if ((a < 0) && (c != 0)) c += b;
   return c;
}

/* min(x,y) */

define n(x,y){
	if(y<x)return(y)
	return(x)
}

/* returns a raised to the power b, where a is an integer
and b is a non-negative integer. */

define z(a,b){
	auto x,y,z
	x=a
	y=b
	z=1
	while(y>0){
		while(y%2==0){
			y=y/2
			x=x*x
		}
		y=y-1
		z=z*x
	}
	return(z)
}

/*  gcd(m,n) for any integers m and n */
/* Euclid's division algorithm is used. */

define g(m,n){
	auto a,b,c
	a=abs(m)
	if(n==0)return(a)
	b=abs(n)
	c=a%b
	while(c>0){
		a=b
		b=c
		c=a%b
	}
	return(b)
}   

/* the Brent-Pollard method for returning a proper factor of a composite n 
see R. Brent, Bit 20, 176-184 */

define b(n){
	auto a,y,r,g,x,i,k,f,z
	"BRENT-POLLARD: SEARCHING FOR A PROPER FACTOR OF ";n
	a=1;y=0;r=1;g=1;prod=1
	while(g==1){
		x=y
		for(i=1;i<=r;i++)y=(y*y+a)%n
		k=0
		f=0
		while(f==0){
			y=(y*y+a)%n
			k=k+1
			z=abs(x-y)
			prod=prod*z
			if(k%10==0){
				g=g(prod,n)
				prod=1
				if (g>1)f=1
			}
			if(k>=r)f=1
		}
		r=2*r;<- "r=",r,"\n"
		if(g==n || r == 16384){
			g=1
			r=1
			y=0
			a=a+1
			<- "increasing a\n"
			if(a==3){
				<- "Brent-Pollard failed to find a factor\n"	
				<- "Try Keith Matthews' CALC program which uses the MPQS algorithm\n"	
				halt
			}
		}
	}
	"--
"
	"FINISHED ";g
	"is a proper factor of ";n
	"--
"
	return(g)
}

/* returns n/m, where m is the part of n composed of primes 
 qglobal[i],...,qglobal[jglobal-1] < 1000, where i is the value of the global
 variable jglobal before d(n) is called.  qglobal[] and exponent array
 kglobal[] are global variables. */

define d(n){
auto a,u,x,k,i
	a=167
	x=n
	i=0
	while (i<= a){
	k=0
	if(x<pglobal[i])break
	if(x%pglobal[i]==0){
		while(x%pglobal[i]==0){
			k=k+1
			x=x/pglobal[i]
		}
		pglobal[i]
		"is a prime factor of ";n
		qglobal[jglobal]=pglobal[i]
		"exponent ";k
		kglobal[jglobal]=k
		jglobal=jglobal+1
		"--
"
	}
	i=i+1
}
return(x)
}

/* a^b (mod c) */
/* a,b,c integers, a,b>=0,c>=1 */

define e(a,b,c){
	auto x,y,z
	x=a
	y=b
	z=1
	while(y>0){
		while(y%2==0){
			y=y/2
			x=(x*x)%c
		}
		y=y-1
		z=(z*x)%c
	}
	return(z)
}

/*
 n>1 and odd and n does not divide b, b > 0, n-1=2^s*t, t odd.
 If r(n,b)=1, then n passes Miller's test for base b and n is either
 a prime or a strong pseudoprime to base b.
 If r(n,b)=0, then n is composite.
 */

define r(n,b){
	auto a,q,i,j
	if(n%2==0){
	"n is even
";return
}
	if(b%n==0){
	"b divides n
";return
	}
	q=(n-1)/2
	a=q
	i=0
	while(a%2==0){a=a/2;i=i+1}
	/* a = t, i=s-1 */
	b=e(b,a,n) /* "b" = b^t(mod n) */
	if(b==1)return(1)
	/* b^t != 1 (mod n) */
	j=0
	while(1){
		/* "b=b^{(2^j)*t}(mod n) */
		if(b==n-1)return(1)
		j=j+1
		if(i < j)return(0)/* j = s */
		b=(b*b)%n
	}
}

/* n>1 is distinct from pglobal[0],...,pglobal[4]. */
/* if q(n)=1, then n passes Miller's test for bases pglobal[0],...,pglobal[4]
   and is likely to be prime. If q(n)=0, then n is composite. */

define q(n){
	auto i
	"MILLER'S TEST IN PROGRESS FOR ";n
	"--
"
	for(i=0;i<=4;i++){
		if(r(n,pglobal[i])==0){
		"FINISHED: ";n
		"is composite
"
		"--
"
		return(0)
		}
	}
	"FINISHED: ";n
	"passes Miller's test 
"
	"--
"
	return(1)
}

/* n>1 is not divisible by pglobal[0],...,pglobal[167]. */
/* f(n) returns a factor of n which is < 1,000,000 (and hence prime)
 or which passes Miller's test for bases pglobal[0],...,pglobal[4] 
 and is therefore likely to be prime. */

define f(n){
	auto f,x,y,b
	b=1000
	if(n<b*b){
		return(n)
	}
	if(q(n)==1)return(n)
	f=1
	x=n
	while(f!=0){
		y=b(x)
		x=n(x/y,y)
		if(x<b*b)return(x)
		if(q(x)==1)f=0
	}
	return(x)
}

/* A quasi-prime (q-prime) factor of n is > 1,000,000, passes Miller's test 
and is not divisible by pglobal[0],...,pglobal[167]. It is likely to be prime.
h(n) returns the number lglobal-t of q-prime factors of n, (rglobal[] and
lglobal are global variables.
The prime and q-prime factors of n are qglobal[i],...,qglobal[jglobal-1]
with exponents kglobal[i],...,kglobal[jglobal-1], where i is the value of the
global variable jglobal before h(n) is called.
 */

define h(n){
	auto b,p,x,k,t
	b=1000 
	"FACTORIZING ";n
	"--
"
	x=d(n)
	t=lglobal
	while(x!=1){
		k=0
		p=f(x)
		while(x%p==0){
			k=k+1
			x=x/p
		}
		if(p<b*b){
			p
			"is a prime factor of ";n
		}
		if(p>b*b){
			p
			"is a q-prime factor of ";n
			rglobal[lglobal]=p
			lglobal=lglobal+1
		}
		qglobal[jglobal]=p
		"exponent ";k
		kglobal[jglobal]=k
		jglobal=jglobal+1
		"--
"
	}
	"FINISHED FACTORIZATION INTO PRIMES AND Q-PRIMES FOR ";n
	"--
"
	return(lglobal-t)
}

/* Selfridge's test for primality - see "Prime Numbers and Computer
Methods for Factorization" by H. Riesel, Theorem 4.4, p.106. */

/* input: n (q-prime) */
/* first finds the prime and q-prime factors of n-1. If no q-prime factor is
present and 1 is returned, then n is prime. However if at least one q-prime is
present and 1 is returned, then n retains "q-prime" status.
If 0 is returned, then either n or one of the q-prime factors of n-1 is 
composite. */

define s(n){
	auto i,x,s,t,u
	"SELFRIDGE'S TEST FOR PRIMALITY OF QUASI-PRIME ";n
	"--
"
	i=jglobal
	u=h(n-1)
	cglobal=u+cglobal
	/* cglobal,jglobal,lglobal are global variables. */
/* h(n) returns jglobal-i primes and q-primes 
qglobal[i],...,qglobal[jglobal-1] */
/* and q-primes rglobal[lglobal-u],...,rglobal[lglobal-1], where u>=0. */
	"SELFRIDGE'S EXPONENT TEST IN PROGRESS FOR Q-PRIME ";n
	"--
"
	while(i<=jglobal-1){
		x=2
		while(x<n){
			s=e(x,n-1,n)
			if(s!=1){
				"SELFRIDGE'S TEST FINISHED: q-prime ";n
				"is composite
"
				return(0)
			}
			t=e(x,(n-1)/qglobal[i],n)
			if(t!=1){
				i=i+1
				break
			}
		x=x+1
		}
		if(x==n){ /* unlikely to be tested */
			"SELFRIDGE'S TEST INCONCLUSIVE
"
				return(0)
		}
	}
	if(u==0){
		"SELFRIDGE' TEST FINISHED: q-prime ";n
		"is prime
"
		"--
"
	return(1)
	}
	if(u>0){
		"FINISHED: q-prime n = ";n
		"retains its q-prime status.
"
		"--
"
	return(1)
	}
}

/* a factorization of n into prime and q-prime factors is first obtained.
Selfridge's primality test is then applied to any q-prime factors; the test 
is applied repeatedly until either a q-prime is found to be composite
(in which case the initial factorization is doubtful and an extra base should be
used in Miller's test) or we run out of q-primes, in which case every q-prime 
factor of n is certified as prime.*/
/* the number of distinct prime factors of n is returned. */

define factor(n){
	auto i,s,t
	"--
"
	jglobal=lglobal=0
	cglobal=h(n)
	/* cglobal gives a progress count of the number of q-prime factors */
	/* yet to be tested by Selfridges' method */
	s=jglobal
	/* s is the number of prime and q-prime factors of n */
	if(cglobal==0){
		"NO Q-PRIMES, FACTORIZATION VALID:
"
		"
"
		"prime factors: 
"
		for(i=0;i<s;i++) qglobal[i]
		"
"
		"exponents:
"
		for(i=0;i<s;i++) kglobal[i]
		"
"
		<- "number of prime factors of ",n, " is ";return(s)
	}
	"TESTING Q-PRIMES 
"
	"--
"
	while(cglobal>0){
		t=s(rglobal[i])
		if(t==0){
			"do factor(n) again  with an extra base in q(n) 
"
			return(0)
		}
		i=i+1
		cglobal=cglobal-1
	}
		"ALL Q-PRIMES ARE PRIMES: FACTORIZATION VALID: 
"
		"
"
		"prime factors: 
"
		for(i=0;i<s;i++) qglobal[i]
		"
"
		"exponents:
"
		for(i=0;i<s;i++) kglobal[i]
		"
"
		<- "number of prime factors of ",n," is ";return(s)
}

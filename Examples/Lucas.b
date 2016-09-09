number jacobi(number a, number b);

/* gnubc program: lucas */
/* needs jacobi */
"
"" Here n is odd and > 1. Type (say) lucas(187).
"" If lucas(n) returns 1, then n is a strong
"" base 2 pseudoprime and a Lucas probable prime;
"" if lucas(n) returns 0, then n is composite.
"" See 'The Pseudoprimes to 25.10^9',
"" Mathematics of computation, 35 (1980) 1003-1026.
"" At the end of this paper it is conjectured that
"" if n is a strong base 2 pseudoprime and a Lucas
"" probable prime, then n is in fact a prime.
"" A prize is offered for a counterexample.
"


/*NOTE: in bc we have */
/* a%b=m(a,b) if a>=0 or a<0 and b divides a */
/* a%b=m(a,b)-b if a<0, b>0, a not divisible by b */
/* a/b=[a/b] if a>=0 or a<0 and b divides a */
/* a/b=[a/b]+1 if a<0, b>0, a not divisible by b */
/* a=b(a/b)+a%b */

/* mod(a,b)=the least non-negative remainder when an integer
   a is divided by a  positive integer b */

define mod(a,b){
	auto c
	c=a%b
	if(a>=0) return(c)
	if(c==0) return(0)
        return(c+b)	
}


/*
 * a^b (mod c), a,b,c integers, a,b>=0,c>=1
 */

define mpower(a,b,c){
	auto x,y,z
	x=a
	y=b
	z=1
/*	<- z," ",x," ",y,"\n"*/
	while(y>0){
		while(y%2==0){
			y=y/2
			x=(x*x)%c
			/*<- z," ",x," ",y,"\n"*/
		}
		y=y-1
		z=(z*x)%c
		/*<- z," ",x," ",y,"\n"*/
	}
	return(z)
}

/*
 * n > 1 and odd, gcd(n,b)=1, or more generally, n does not divide b.
 * If miller(n,b)=1, then n passes Miller's test for base b and n is
 * either a prime or a strong pseudoprime to base b.
 * if miller(n,b)=0, then n is composite.
 */

define miller(n,b){
	auto a,s
	s=(n-1)/2
	a=s
	while(a%2==0)a=a/2
	b=mpower(b,a,n)
	if(b==1)return(1)
	while(a<=s){
		if(b==n-1)return(1)
		b=mod(b*b,n)
		a=2*a
	}
	return(0)
}

/*
 * returns U_n (mod m), where U_{k+1}=U_k-qU_{k-1}, U_0=0,U_1=1.
 * D=1-4q != 0.
 * We use the recurrence relations:
 * U_{k+1}=U_k-qU_{k-1},
 * U_{2k}=-2qU_{k-1}U_k+U_kU_k,
 * U_{2k-1}=U_kU_k-qU_{k-1}U_{k-1}
 * See Niven, Zuckermann and Montgomery, p.202.
 * Also D. Bressoud, Factorization and Primality Testing, p.179-191 and 
 * C. Pomerance, Kent State Lecture Notes, 19-22.
 */
define lucas1(n,q,m){
	auto b[],h,i,y,r,s,t,u,v

	h=0
	y=n
	while (y){
		b[h]=y%2
		y=y/2
		h=h+1
	}
	r=0
	s=1
	y=n
	t=mod(-q,m)
	v=(2*t)%m
	i=h-1
	while(1){
		u=s
		s= ((v*r+s)*s)%m
		r=(u*u+t*r*r)%m
		i=i-1
if(i==-1)break
		if(b[i]){
			u=r
			r=s
			s=(s+t*u)%m
		}
	}
	return (s)
}
/*
 * Let n > 1 be odd. Then lucas2(n) determines an integer d(!=-3) of the form 
 * 4m+1, 
 * such that the Jacobi symbol jacobi(d,n)= -1. Then with q=(1-d)/4, the Lucas 
 * pseudoprime test examines l=U_{(n+1)/2}mod n. If l=0, n is a Lucas probable 
 * prime, otherwise n is composite. See 'The Pseudoprimes to 25.10^9', 
 * Mathematics of computation, 35 (1980) 1003-1026. At the end of this paper 
 * it is conjectured that if n is a strong base 2 pseudoprime and a Lucas 
 * probable prime, then n is in fact a prime. A $30 prize is offered for a  
 * counterexample.
 * if lucas2(n) returns 1, then n is a Lucas probable prime, else n is 
 * composite.
 */
define lucas2(n){
	auto s,t,h,x,q,d,l

	s=5
	t=-7
	x=sqrt(n)
	if(x*x==n){
		<- "n is a perfect square\n"
		return(0)
	}
	for(h=0;1;h++){
		if(jacobi(s,n)== -1){
			d=s
			break
		}
		s=s+4
		if(jacobi(t,n)== -1){
			d=t
			break
		}
		t=t-4
	}
	q=(1-d)/4
	l=lucas1((n+1)/2,q,n)
	if(l==0){ /* Lucas probable prime */
		return (1)
	}
	if(l){/* composite */
		return (0)
	}
}

/*
 * Here n is odd and > 1.
 * If lucas(n) returns 1, then n is a strong base 2 pseudoprime and a Lucas
 * probable prime; if lucas(n) returns 0, then n is composite.
 * See 'The Pseudoprimes to 25.10^9', Mathematics of computation, 35 (1980)
 * 1003-1026. At the end of this paper it is conjectured that if n is a
 * strong base 2 pseudoprime and a Lucas probable prime, then n is in fact
 * a prime.  A $30 prize is offered for a counterexample.
 */

define lucas(n){
	auto l

	l=miller(n,2)
	if(l==0){
		<- n," is composite by the base 2 strong pseudoprime test\n"
		return (0)
	}
	l=lucas2(n)
	if (l){
		<- n," is a Lucas probable prime\n"
                return (1)
	}
	if (l==0){
		<- n," is composite by the Lucas pseudoprime test\n"
                return (0)
	}
}

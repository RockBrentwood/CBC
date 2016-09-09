/* gnubc program: phi */
"
"" omega(n) returns the number of distinct prime factors of n   
"" phi(n) returns the value of Euler's function
"" tau(n) returns the number of divisors of n  
"" sigma(n) returns the sum of the divisors of n  
"" mu(n) returns the value of the Mobius Function
"" lprimroot(p) returns the least primitive root mod p
"" orderp(a,p) returns the order of a mod p
"" orderpn(a,p,n) returns the order of a mod p^n, p a prime
"" orderm(a,m) returns the order of a mod m. 
"
pglobal[0]=2
pglobal[1]=3
pglobal[2]=5
pglobal[3]=7
pglobal[4]=11
pglobal[5]=13
pglobal[6]=17
pglobal[7]=19
pglobal[8]=23
pglobal[9]=29
pglobal[10]=31
pglobal[11]=37
pglobal[12]=41
pglobal[13]=43
pglobal[14]=47
pglobal[15]=53
pglobal[16]=59
pglobal[17]=61
pglobal[18]=67
pglobal[19]=71
pglobal[20]=73
pglobal[21]=79
pglobal[22]=83
pglobal[23]=89
pglobal[24]=97
pglobal[25]=101
pglobal[26]=103
pglobal[27]=107
pglobal[28]=109
pglobal[29]=113
pglobal[30]=127
pglobal[31]=131
pglobal[32]=137
pglobal[33]=139
pglobal[34]=149
pglobal[35]=151
pglobal[36]=157
pglobal[37]=163
pglobal[38]=167
pglobal[39]=173
pglobal[40]=179
pglobal[41]=181
pglobal[42]=191
pglobal[43]=193
pglobal[44]=197
pglobal[45]=199
pglobal[46]=211
pglobal[47]=223
pglobal[48]=227
pglobal[49]=229
pglobal[50]=233
pglobal[51]=239
pglobal[52]=241
pglobal[53]=251
pglobal[54]=257
pglobal[55]=263
pglobal[56]=269
pglobal[57]=271
pglobal[58]=277
pglobal[59]=281
pglobal[60]=283
pglobal[61]=293
pglobal[62]=307
pglobal[63]=311
pglobal[64]=313
pglobal[65]=317
pglobal[66]=331
pglobal[67]=337
pglobal[68]=347
pglobal[69]=349
pglobal[70]=353
pglobal[71]=359
pglobal[72]=367
pglobal[73]=373
pglobal[74]=379
pglobal[75]=383
pglobal[76]=389
pglobal[77]=397
pglobal[78]=401
pglobal[79]=409
pglobal[80]=419
pglobal[81]=421
pglobal[82]=431
pglobal[83]=433
pglobal[84]=439
pglobal[85]=443
pglobal[86]=449
pglobal[87]=457
pglobal[88]=461
pglobal[89]=463
pglobal[90]=467
pglobal[91]=479
pglobal[92]=487
pglobal[93]=491
pglobal[94]=499
pglobal[95]=503
pglobal[96]=509
pglobal[97]=521
pglobal[98]=523
pglobal[99]=541
pglobal[100]=547
pglobal[101]=557
pglobal[102]=563
pglobal[103]=569
pglobal[104]=571
pglobal[105]=577
pglobal[106]=587
pglobal[107]=593
pglobal[108]=599
pglobal[109]=601
pglobal[110]=607
pglobal[111]=613
pglobal[112]=617
pglobal[113]=619
pglobal[114]=631
pglobal[115]=641
pglobal[116]=643
pglobal[117]=647
pglobal[118]=653
pglobal[119]=659
pglobal[120]=661
pglobal[121]=673
pglobal[122]=677
pglobal[123]=683
pglobal[124]=691
pglobal[125]=701
pglobal[126]=709
pglobal[127]=719
pglobal[128]=727
pglobal[129]=733
pglobal[130]=739
pglobal[131]=743
pglobal[132]=751
pglobal[133]=757
pglobal[134]=761
pglobal[135]=769
pglobal[136]=773
pglobal[137]=787
pglobal[138]=797
pglobal[139]=809
pglobal[140]=811
pglobal[141]=821
pglobal[142]=823
pglobal[143]=827
pglobal[144]=829
pglobal[145]=839
pglobal[146]=853
pglobal[147]=857
pglobal[148]=859
pglobal[149]=863
pglobal[150]=877
pglobal[151]=881
pglobal[152]=883
pglobal[153]=887
pglobal[154]=907
pglobal[155]=911
pglobal[156]=919
pglobal[157]=929
pglobal[158]=937
pglobal[159]=941
pglobal[160]=947
pglobal[161]=953
pglobal[162]=967
pglobal[163]=971
pglobal[164]=977
pglobal[165]=983
pglobal[166]=991
pglobal[167]=997


/* mod(a,b)=the least non-negative remainder when an integer
   a is divided by a  positive integer b */

define mod(a,b){
	auto c
	c=a%b
	if(a>=0) return(c)
	if(c==0) return(0)
        return(c+b)	
}

number gcd(number m, number n);
number abs(number n);

/* lcm(a,b) for any integers a and b */

define lcm(a,b){
	auto g
	g=gcd(a,b)
	if(g==0) return(0)
	return(abs(a*b)/g)
}


/*	
 * the bth power of a, where a is an integer, b a positive integer.
 *
 */
define exp(a,b){
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


/*
 * a^b (mod c), a,b,c integers, a,b>=0,c>=1
 */

define mpower(a,b,c){
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


/* absolute value of an integer n */

define abs(n){
	if(n>=0) return(n)
	return(-n)
}

/*NOTE: in bc we have */

/*  gcd(m,n) for any integers m and n */
/* Euclid's division algorithm is used. */
/* We use gcd(m,n)=gcd(m,|n|) */

define gcd(m,n){
	auto a,b,c
	a=abs(m)         /* a=r[0] */ 
	if(n==0) return(a)
        b=abs(n)         /* b=r[1] */ 
        c=a%b            /* c=r[2]=r[0] mod(r[1]) */ 
        while(c>0){
		a=b
                b=c
                c=a%b    /* c=r[j]=r[j-2] mod(r[j-1]) */
        }
	return(b)
}   

/* min(x,y) */

define min(x,y){
	if(y<x)return(y)
	return(x)
}

/*
 * the Brent-Pollard method for returning a proper factor of a composite n.
 * See R. Brent, Bit 20, 176-184
 */

define brent(n){
	auto a,y,r,g,x,i,k,f
	a=3;y=0;r=1;g=1
	while(g==1){
		x=y
		for(i=1;i<=r;i++)y=(y*y+a)%n
		k=0
		f=0
		while(f==0){
			y=(y*y+a)%n
			g=gcd((abs(x-y))%n,n)
			k=k+1
			if(k>=r)f=1
			if(g>1)f=1
		}
		r=2*r
		if(g==n){
			g=1
			r=1
			y=0
			a=a+1
		}
	}
	return(g)
}

/*
 * babydivide(n) returns n/m, where m is the part of n composed of primes 
 * qglobal[i],...,qglobal[jglobal-1] < 1000, where i is the value of global
 * variable jglobal before babydivide(n) is called. 
 * qglobal[] and exponent array kglobal[] are global variables.
 */

define babydivide(n){
	auto a,u,x,k,i
	a=167
	x=n
	for(i=0;i<=a;i++){
		k=0
		if(x<pglobal[i])break
		if(x%pglobal[i]==0){
			while(x%pglobal[i]==0){
				k=k+1
				x=x/pglobal[i]
			}
			qglobal[jglobal]=pglobal[i]
			kglobal[jglobal]=k
			jglobal=jglobal+1
		}
	}
return(x)
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
 * n > 1 is distinct from pglobal[0],...,pglobal[4].
 * if q(n)=1, then n passes Miller's test for bases pglobal[0],...,pglobal[4]
 * and is likely to be prime.
 * if q(n)=0, then n is composite.
 */

define q(n){
	auto i
	for(i=0;i<=4;i++){
		if(miller(n,pglobal[i])==0){
		return(0)
		}
	}
	return(1)
}

/*
 * n>1 is not divisible by pglobal[0],...,pglobal[167].
 * v(n) returns a factor of n which is < 1,000,000 (and hence prime)
 * or which passes Miller's test for bases pglobal[0],...,pglobal[4] and is 
 * therefore likely to be prime.
 */

define v(n){
	auto f,x,y,b
	b=1000
	if(n<b*b){
		return(n)
	}
	if(q(n)==1)return(n)
	f=1
	x=n
	while(f!=0){
		y=brent(x)
		x=min(x/y,y)
		if(x<b*b)return(x)
		if(q(x)==1)f=0
	}
	return(x)
}

/* A quasi-prime (q-prime) factor of n is > 1,000,000, passes Miller's test 
 * and is not divisible by pglobal[0],...,pglobal[167]. It is likely to be 
 * prime.
 * primefactors(n) returns the number lglobal-t of q-prime factors of n.
 * rglobal[] and lglobal are global variables.
 * The prime and q-prime factors of n are qglobal[i],...,qglobal[jglobal-1] 
 * with exponents 
 * kglobal[i],...,kglobal[jglobal-1] where i is the value of the global 
 * variable jglobal before primefactors(n) is called.
 */

define primefactors(n){
	auto b,p,x,k,t
	b=1000 
	x=babydivide(n)
	t=lglobal
	while(x!=1){
		k=0
		p=v(x)
		while(x%p==0){
			k=k+1
			x=x/p
		}
		if(p>b*b){
			rglobal[lglobal]=p
			lglobal=lglobal+1
		}
		qglobal[jglobal]=p
		kglobal[jglobal]=k
		jglobal=jglobal+1
	}
	return(lglobal-t)
}

/*
 * Selfridge's test for primality - see "Prime Numbers and Computer
 * Methods for Factorization" by H. Riesel, Theorem 4.4, p.106.
 * input: n (q-prime)
 * first finds the prime and q-prime factors of n-1. If no q-prime factor
 * is present and 1 is returned, then n is prime. However if at least one
 * q-prime is present and 1 is returned, then n retains "q-prime" status.
 * If 0 is returned, then either n or one of the q-prime factors of n-1 is 
 * composite.
 */

define selfridge(n){
	auto i,x,s,t,u
	i=jglobal
	u=primefactors(n-1)
	cglobal=u+cglobal
	/* cglobal,jglobal,lglobal are global variables. */
	/* primefactors(n-1) returns jglobal-i primes and q-primes 
           qglobal[i],...,qglobal[jglobal-1] */
	/* and q-primes rglobal[l-u],...,rglobal[lglobal-1], where u>=0. */
	while(i<=jglobal-1){
		for(x=2;x<n;x++){
			s=mpower(x,n-1,n)
			if(s!=1){
				return(0)
			}
			t=mpower(x,(n-1)/qglobal[i],n)
			if(t!=1){
				i=i+1
				break
			}
		}
		if(x==n){ /* unlikely to be tested */
				return(0)
		}
	}
	return(1)
}

/*
 * a factorization of n into prime and q-prime factors is first obtained.
 * Selfridge's primality test is then applied to any q-prime factors;
 * the test is applied repeatedly until either a q-prime is found to be 
 * composite (in which case the initial factorization is doubtful and 
 * an extra base should be used in Miller's test) or we run out of q-primes,
 * in which case every q-prime factor of n is certified as prime. 
 * omega(n) returns the number of distinct prime factors of n. 
 */

define omega(n){
	auto i,s,t
	jglobal=lglobal=0
	cglobal=primefactors(n)
	/* cglobal gives a progress count of the number of q-prime factors */
	/* yet to be tested by Selfridges' method */
	s=jglobal
	/* s is the number of prime and q-prime factors of n */
	if(cglobal==0){
		return(s)
	}
	while(cglobal>0){
		t=selfridge(rglobal[i])
		if(t==0){
			return(0)
		}
		i=i+1
		cglobal=cglobal-1
	}
		return(s)
}

/*
 * phi(n) returns the value of Euler's function.
 */
define phi(n){
	auto i,u,d,m
	u = 1
	d = omega(n)
	for (i=0;i<d;i++) u = (qglobal[i]^(kglobal[i]-1))*(qglobal[i]-1)*u
	return(u)
}
/*
 * tau(n) returns the number of divisors of n 
 */
define tau(n){
	auto i,u,d,m
	u = 1
	d = omega(n)
	for (i=0;i<d;i++) u = (1+kglobal[i])*u
	return(u)
}

/* 
 * sigma(n) returns the sum of the divisors of n 
*/
define sigma(n){
	auto i,u,d,m
	u = 1
	d = omega(n)
	for (i=0;i<d;i++) u = ((qglobal[i]^(1+kglobal[i])-1)/(qglobal[i]-1))*u
	return(u)
}

/* 
 * mu(n) returns the value of the Mobius Function 
 */
define mu(n){
	auto i,d,m
	if (n==1) return(1) 
	d = omega(n)
	for (i=0;i<d;i++){ if (kglobal[i]>=2) return(0)}
	return((-1)^(d)) 
}

define lprimroot(p){
	auto d,i,r,q,f,m,u,w

	if(p%2==0){<- p," is even\n";return(0)}
	w=phi(p)
	if(w<p-1){<- p," is not a prime\n";return(0)}
	f = 1
	q = (p-1)/2
	d=omega(p-1)	
	for (i = 2; i >= 2; i++){
		"i=";i;
		r = mpower(i,q,p)
		if (r-p == -1){
			for (u=0;u<d;u++){
				m = mpower(i,(p-1)/qglobal[u],p)
				if (m == 1){f=0;break}
			}	
			if (f)return(i)
			f=1
		}
	}
}

/*
 * orderp(a,p) returns the order of a mod p, a prime.
 */
define orderp(a,p){
	auto d,i,q,m,t,u

	if ((a-1)%p==0)return(1)
	if ((a+1)%p==0)return(2)
	d=omega(p-1)	
	q=p-1
	for (u=0;u<d;u++){
		for(i=1;i<=kglobal[u];i++){
			t = q/qglobal[u]
			m = mpower(a,t,p)
			if(m!=1)break
			q = t
		}
	}
	return(q)
}

/*
 * orderpn(a,p,n) returns the order of a mod p^n, p a prime.
 * An exercise in "Elementary Theory of Numbers", by H. Griffin, p.111.
 */
define orderpn(a,p,n){
	auto h,b,d,q,e

	if (a==1)return(1)
	if (a== -1)return(2)
	if(n==1)return(orderp(a,p))
	if(p>2){d=orderp(a,p)}
	if(p==2){
		if((a-1)%4==0)d=1
		if((a+1)%4==0)d=2
	}
	q=p
	e=0
	h=0
	while(e==0){
		q=q*p
		e=mpower(a,d,q)-1
		h=h+1
	}
	if(n<=h)return(d)
	return(exp(p,n-h)*d)
}

/*
 * orderm(a,m) returns the order of a mod m. This is the lcm of the orders of
 * a modulo the prime powers exactly dividing m.
 */
define orderm(a,n){
	auto x[],y[],i,s,o

	if(gcd(a,n)!=1){"a is not relatively prime to n: returning "; return(0)}
	if(a==1)return(1)
	if (a== -1){
		if(n==2)return(1)
		return(2)
	}
	s=omega(n)
	for(i=0;i<s;i++){x[i]=kglobal[i];y[i]=qglobal[i]}
	o=orderpn(a,y[0],x[0])
	for(i=1;i<s;i++){o=lcm(o,orderpn(a,y[i],x[i]))}
	return(o)
}

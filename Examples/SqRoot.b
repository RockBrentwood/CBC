number min(number a, number b);

/* bc file sqroot */

define sign(a){
	if(a>0) return(1)
	if(a<0) return(-1)
	return(0)
}

define abs(n){
	if(n>=0) return(n)
	return(-n)
}

define mod(a,b){
	auto c
	c=a%b
	if(a>=0) return(c)
	if(c==0) return(0)
        return(c+b)	
}

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
		z=mod(z*x,c)
	}
	return(z)
}

/* Shanks-Tonelli algorithm. 
 * See "Square roots from 1; 24, 51, 10 to Dan Shanks",
 * Ezra Brown, The College Mathematics Journal, 30, No. 2, 82-95, 1999
 */
define tonelli(a,p){
	auto b,e,g,h,i,m,n,q,r,s,t,x,y,z
	q=p-1
	t=mpower(a,q/2,p)
	if(t==q)return(0)/* a is a quadratic non-residue mod p */

	s=q
	e=0
	while(s%2==0){s=s/2;e=e+1}
	/* p-1=s*2^e */
	x=mpower(a,(s+1)/2,p)
	b=mpower(a,s,p)
	if(b==1)return(x)
	for(n=2;n>=2;n++){
		t=mpower(n,q/2,p)
		if(t==q) break
	}
	/* n is the least quadratic non-residue mod p */
	g=mpower(n,s,p)
	r=e
	while(1){
  	  y=b
	  for(m=0;m<=r-1;m++){
	    if(y==1)break
	    y=(y*y)%p
	  }
	/*<- "(m,x,b,g,r)=(",m,",",x,",",b,",",g,",",r,")\n"*/
	/* ord_p(b)=2^m, m <= r-1, so m has decreased */
	  if(m==0)return(x)
	  z=r-m-1
	  h=g
	  for(i=0;i<z;i++) h=(h*h)%p
	  x=(x*h)%p
	  b=(b*h*h)%p
	  g=(h*h)%p
	  r=m 
	}
}

define gcd1(m,n){
	auto a,b,c,h,k,l,q,t
	if(n==0) return(sign(m))
        a=m                
        b=abs(n)          
        c=mod(a,b)      
	if(c==0) return(0)
        l=1           
        k=0                
	j=2
        while(c>0){
                q=(a-c)/b 
                a=b
                b=c
                c=mod(a,b)
                h=l-q*k  
              	l=k 
              	k=h
        }         
	return(k)     
}   

define gcd2(m,n){
        auto a,b,c,h,k,l,q,t,j
	if(n==0) return(0)
        a=m             
        b=abs(n)       
        c=mod(a,b)    
	if(c==0) return(sign(n))
	l=0          
	k=1         
        j=2
        while(c>0){
                q=(a-c)/b 
                a=b
                b=c
                c=mod(a,b)
                h=l-q*k  
		j=j+1
               	l=k
               	k=h
        }
		q=(a-c)/b
	if(n<0)	return(-k)
	return(k)       
}  

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


/* the congruence mx=p(mod n) */
define cong1(m,p,n){
        auto a,b,x,y
	a=gcd(m,n)
	if(mod(p,a)>0){ "not soluble "; return(-1) }
	b=gcd1(m,n)
	y=n/a
	p=p/a
	x=mod(b*p,y)
	return(x)
}

/* the bth power of a, where a is an integer, b a positive integer.*/
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

/* the Chinese remainder theorem for the congruences x=a(mod m)
 * and x=b(mod n), m>0, n>0, a and b arbitrary integers.
 * The construction of O. Ore, American Mathematical Monthly,
 * vol.59,pp.365-370,1952, is implemented.
 * Same as chinese() in gcd, but with printing suppressed, except that -1
 * is returned if there is no solution.
 */

define chinese(a,b,m,n) {
	auto c,d,x,y,z
	d = gcd(m,n)
	if(mod(a-b,d)!=0){
		return(-1)
	}
	x= m/d;y=n/d
	z=(m*n)/d
	c = mod(b*gcd1(x,y)*x + a*gcd2(x,y)*y,z)
	return(c)
}


/* lcm(a,b) for any integers a and b */

define lcm(a,b){
	auto g
	g=gcd(a,b)
	if(g==0) return(0)
	return(abs(a*b)/g)
}

define chinesea(a[],m[],n){
	auto i,m,x
	
	m=m[0]
	x=a[0]
	for(i=1;i<n;i++){
		x=chinese(a[i],x,m[i],m)
		if(x==-1)return(-1)
		m=lcm(m[i],m)
	}
	return(x)
}

/* Solving x^2=a (mod p^n), p an odd prime not dividing a. */
define sqroot1(a,p,n){
	auto i,k,t,u,v
	t=mpower(a,(p-1)/2,p)
	if (t!=1){
		return (-1)
	}
	if (n==1){return(tonelli(a,p))}\
	else{
		u=sqroot1(a,p,n-1)
		v=u^2-a
		for(i=0;i< n-1;i++)v=v/p
		k=cong1(2*u,-v,p)
		return(u+k*exp(p,n-1))
	}
}

/* Solving x^2=a (mod 2^n), a odd. */
define sqroot2(a,n){
	auto i, u, v

	if (n==1){num=1;return(1)}
	if (n==2){
		if(mod(a,4)!=1){
		     return(-1)
		}\
		else{
			num=2
			return (1)
		}
        }
	if(mod(a,8)!=1){
		return (-1)
	}
	if (n==3){num=4;return(1)}\
	else{
		u=sqroot2(a,n-1)
		v=u^2-a
		for(i=0;i< n-1;i++)v=v/2
		if ((v+1)%2 == 0){
			u=u+2^(n-2)
		}
		return(u)
	}
}
/* Solving x^2=a (mod p^n), p a prime possibly dividing a. 
 * If p does not divide a, the story is well-known.
 * If p divides a, there are two cases: 
 * (i) p^n divides a,
 * (ii) p^n does not divide a.
 * In case (i) there are two cases:
 * (a) n=2m+1, (b) n=2m.
 * In case (a), the solution is x=0 (mod p^(m+1)).
 * In case (b), the solution is x=0 (mod p^m).
 * (These are called reduced moduli.)
 * In case (i) gcd(a,p^n)=p^r, r<n. If r is odd, no solution.
 * If r=2m, write x=(p^m)*X, d=(p^2m)*D, p not dividing D. Then x^2=d (mod p^n)
 * becomes X^2=A (mod p^(n-2m)).
 * If p is odd, this has 2 solutions X mod p^(n-2m) and we get two solutions
 * x (mod p^(n-m)). If p=2, we get
 *                            1 solution mod (2^(n-m)) if n-2m=1,
 *                            2 solutions mod (2^(n-m) if n-2m=2,
 *                            4 solutions mod (2^(n-m)) if n-2m>2.
 */
define sqroot3(a,p,n){
	auto aa,d,m,r,s,u,v
	if(p==2)
		num=0
	d=a%p
	if(d){
		exponentm=p^n
		if(p==2){
			return(sqroot2(a,n))
		}\
		else
			return(sqroot1(a,p,n))
			
	}\
	else{
		u=p^n
		v=a%u
		if(v==0){
			if(n%2==0){
				exponentm=p^(n/2)
			}\
			else{
				exponentm=p^(1+n/2)
			}
			return(0)
		}
		r=0
		aa=a
		v=aa%p
		while(v==0 && r<=n){
			aa=aa/p
			v=aa%p
			r=r+1
			
		}
		if(r%2){
			return(-1)
		}\
		else{
			m=r/2
			s=n-r
			/*u=p^s*/
			exponentm=p^(n-m)
			if(p==2){
				t=sqroot2(aa,s)
				if(t==-1){
					return(-1)
				}\
				else
					return(p^m*sqroot2(aa,s))
			}\
			else{
				t=sqroot1(aa,p,s)
				if(t==-1){
					return(-1)
				}\
				else
				return(p^m*sqroot1(aa,p,s))
			}
		}
			
	}
}

/*
 * r=sqroot(d,n) returns the solutions of x^2=d (mod n).
 * r is the number of solutions.
 * The algorithm uses the Chinese remainder theorem after solving mod 
 * qglobal[i]^kglobal[i], i=1,...,e=omega(n). Note n is even if and only if
 * qglobal[0]=2.
 * Finally we join all solutions together using the CRT.
 * Some care is needed to exhibit all solutions. We operate on the d[]
 * array below, as follows:
 * l= number of primes qglobal[i] dividing n, for which
 * p^a=qglobal[i]^kglobal[i] does not divide n, while jj is the remaining 
 * number.
 * d[] is the array formed by a single solution each of x^2=d mod p^a
 * s is the product of the reduced moduli for these l primes.
 * om is the product of the reduced moduli for the jj primes.
 * s[] is the array formed by the moduli p^a.
 * If l>1, we produce all 2^l l-tuples (e[0]*d[0],...,e[l-1]*d[l-1]),
 * where e[i]=1 or -1, if s is odd or d[0]=2 and "number">1, but only 2^(l-1) 
 * (l-1)-tuples (e[0]*d[0],...,e[l-2]*d[l-2]), if s is even and "number"=1.
 * It is convenient to use the CRT with d[l]=om, s[l]=0, even when om=1,
 * so as to produce all solutions.
 * If s is even, we place d[0] at the end of the d[] array, making it d[l-1].
 * This is done so as to conveniently operate on the initial part of the d[]
 * array, where the initial s[i] are only odd prime powers.
 * The final sqroot(d,n) function took me two days to get right and was
 * really quite challenging. (Keith Matthews 7th April 2000.)
 * Improved and fixed more bugs on 11th April 2000.
 */
define sqroot(d,n){
	auto a,b,i,e,c,d[],d1[],s[],x,k,r,s,sg,t,j,om,l,jj
	e=omega(n)
	l=0
	jj=0
	om=1
	s=1
	for (i=0;i<e;i++){
		c=sqroot3(d,qglobal[i],kglobal[i])
		if(c==-1){
			<- "x^2=",d," mod(",n,") has no solution\n" 
			return(-1)
		}
		if(c==0){
			om=om*exponentm
			jj=jj+1
		}\
		else{
			d[l]=c
			s[l]=exponentm
			s=s*s[l]
			l=l+1
		}
	}
	if(l==0){
		<- "The solution of x^2=",d," mod(",n,") is ",0," mod(",om,")\n" 
		return(n/om)
	}
	if(l==1){
		if(om>1){
			x=chinese(d[0],0,s[0],om)
		}\
		else
			x=d[0]
		if(s[0]%2){
			<- "The solutions of x^2=",d," mod(",n,") are ",x,",",-x," mod(",s[0]*om,")\n" 
			return(2*n/(s[0]*om))
		}\
		else{
			t=num
			if(t>1){
				<- "The solutions of x^2=",d," mod(",n,") are ",x,",",-x," mod(",s[0]*om,")\n" 
			}\
			else{
				<- "The solution of x^2=",d," mod(",n,") is ",x," mod(",s[0]*om,")\n" 
			}
			if(t==4){
				y=mod(d[0]+s[0]/2,s[0])
				if(om>1){
					x=chinese(y,0,s[0],om)
				}\
				else
					x=y
				<- x,",",-x," mod(",s[0]*om,")\n" 
				return(4*n/(s[0]*om))
			}
			if(t==2)
				return(2*n/(s[0]*om))
			return(n/(s[0]*om))
		}
	}
	s[l]=om
	k=exp(2,l)
	d1[l]=0
	if(num==4)
		dd1[l]=0
	<- "The solutions of x^2=",d," mod(",n,") are: \n" 

	if(n%2){
		for(i=0;i<k;i++){
			j=i
			for(r=0;r<l;r++){
				t=j%2
				if(t){
					sg=-1
				}\
				else{
					sg=1
				}
				j=j/2
				d1[r]=sg*d[r]
			}
			x=chinesea(d1[],s[],l+1)
			<- x," mod(",s*om,")\n" 
		}
		return((2^l)*n/(s*om))
	}\
	else{
		a=d[0]
		b=s[0]
		for(r=1;r<l;r++){
			d[r-1]=d[r]
			s[r-1]=s[r]
		}
		d[l-1]=a
		s[l-1]=b
		if(num==4){
			for(r=0;r<l-1;r++)
				dd[r]=d[r]
			dd[l-1]=mod(d[l-1]+s[l-1]/2,s[l-1])
			/*for(r=0;r<=l-1;r++){
				<-  "dd[",r,"]=",dd[r],"\n"
			}*/
		}
		/*for(r=0;r<=l-1;r++){
			<-  "d[",r,"]=",d[r],"\n"
		}*/
		if(num==1)
			k=k/2
		for(i=0;i<k;i++){
			j=i
			for(r=0;r<l;r++){
				t=j%2
				if(t){
					sg=-1
				}\
				else{
					sg=1
				}
				j=j/2
				d1[r]=sg*d[r]
				if(num==4)
					dd1[r]=sg*dd[r]
			}
			x=chinesea(d1[],s[],l+1)
			<- x," mod(",s*om,")\n" 
			if(num==4){
				x=chinesea(dd1[],s[],l+1)
				<- x," mod(",s*om,")\n" 
			}
		}
		if(num==4){
			return(2*k*n/(s*om))
		}\
		else
			return(k*n/(s*om))
	}
}

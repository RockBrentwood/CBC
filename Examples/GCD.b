/* gnubc program: gcd */
/*
		NUMBER THEORY ALGORITHMS
1.  sign(n)
2.  abs(n)
3.  mod(a,b), (b > 0): returns a(mod b)
4.  int(a,b):  returns the integer part of a/b, b nonzero
5.  gcd(m,n)
6.  gcd1(m,n): gcd(m,n)=gcd1(m,n)m+gcd2(m,n)n
7.  gcd2(m,n)
8.  lcm(m,n)
9.  inv(a,n): returns the inverse of a mod m
10. cong(a,b,m): solves ax=b (mod m)
11. chinese(a,b,m,n): solves x=a(mod m),x=b(mod n)
12. gcda(m[],n): finds gcd(m[0],...,m[n-1]) and expresses it
    as a linear combination of m[0],...,m[n-1]
13. lcma(m[],n): finds lcm(m[0],...,m[n-1])
14. chinesea(a[],m[],n): solves x=a[i](mod m[i]), i=1,...,n-1
15. chineseab(a[],b[],m[],n): solves b[i]*x=a[i](mod m[i]),
    i=1,...,n-1
16. mpower(a,b,c): returns a^b (mod c)
17. exp(a,b): returns a^b
18. mthroot(a,b,m): returns the integer part of the mth-root of a/b. 
    Here a,b and m are positive integers, m > 1. 
19. mthrootr(a,b,m,r): this gives the mth-root of a/b truncated
20. min(x,y): this returns x if x<=y, y if x>y.
    to r decimal places, r>=0.
*/
/* sign of an integer a */
/* s(a)=1,-1,0, according as a>0,a<0,a=0 */

define sign(a){
	if(a>0) return(1)
	if(a<0) return(-1)
	return(0)
}

/* absolute value of an integer n */

define abs(n){
	if(n>=0) return(n)
	return(-n)
}

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

/* int(a,b)=integer part of a/b, a, b integers, b != 0 */

define int(a,b){
	if(b<0){
	a= -a
	b= -b
	}
	return((a-mod(a,b))/b)
}

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

/* gcd(a,b)=a*h(a,b)+b*k(a,b) for any integers a and b,
 * where h(a,b) and k(a,b) are calculated as follows:
 * Let q[1],...,q[n] be the quotients in Euclid's algorithm.
 * Then the recurrence relation 
 * s[0]=1, s[1]=0, s[j]=s[j-2]-q[j-1]*s[j-1] for j=2,...,n
 * is implemented. Then h(a,b)=s[n].
 * The recurrence relation 
 * t[0]=0, t[1]=1, t[j]=t[j-2]-q[j-1]*t[j-1] for j=2,...,n
 * is implemented. Then k(a,b)=t[n]. 
 */

/* gcd1(m,n)=h(m,n).
 * gcd2(m,n)=k(m,n).
 */

define gcd1(m,n){
	auto a,b,c,h,k,l,q,t
	if(n==0) return(sign(m))
        a=m                /* a=r[0] */ 
        b=abs(n)           /* b=r[1] */ 
        c=mod(a,b)         /* c=r[2] */ 
	if(c==0) return(0)
        l=1                /* l=s[0] */ 
        k=0                /* k=s[1] */ 
	j=2
        while(c>0){
                q=(a-c)/b  /* q=q[j-1]=[r[j-2]/r[j-1]] */
                a=b
                b=c
                c=mod(a,b) /* c=r[j],r[j-2]=q[j-1]*r[j-1]+r[j]*/
                h=l-q*k    /* h=s[j],k=s[j-1], l=s[j-2] */ 
              	l=k 
              	k=h
        }         
	return(k)          /* k=s[j] */
}   


define gcd2(m,n){
        auto a,b,c,h,k,l,q,t,j
	if(n==0) return(0)
        a=m                /* a=r[0] */ 
        b=abs(n)           /* b=r[1] */ 
        c=mod(a,b)         /* c=r[2] */ 
	if(c==0) return(sign(n))
	l=0                /* l=t[0] */ 
	k=1                /* k=t[1] */ 
/*	<- "     ","   r[0]=",a," t[0]=",0,"\n"
	<- "q[1]=",(a-c)/b,"  r[1]=",b," t[1]=",1,"\n" */
j=2
        while(c>0){
                q=(a-c)/b  /* q=q[j-1]=[r[j-2]/r[j-1]] */
                a=b
                b=c
                c=mod(a,b) /* c=r[j],r[j-2]=q[j-1]*r[j-1]+r[j]*/
                h=l-q*k    /* h=t[j],k=t[j-1], l=t[j-2] */ 
		j=j+1
/*		<- "q[",j-1,"]=",(a-c)/b,"  r[",j-1,"]=",b," t[",j-1,"]=",h,"\n" */
               	l=k
               	k=h
        }
		q=(a-c)/b
/*		<- "        r[",j,"]=",c," t[",j,"]=",l-q*k,"\n" */
	if(n<0)	return(-k)
	return(k)          /* k=t[j] */
}  

/* inv(a,n) returns the inverse of a (mod n), n>0 if gcd(a,n)=1.
 * uses the fact that |s[j]|<n in general.
 */
define inv(a,n){
auto s
if(gcd(a,n)>1){<- "gcd(a,n)>1\n";return(0)}
s=gcd1(a,n)
if(s<0)return(s+n)
return(s)
}
/*  the congruence mx=p(mod n) */

define cong(m,p,n){
        auto a,b,t,x,y,z
	a=gcd(m,n)
	if(mod(p,a)>0){
 "the number of solutions is "; return(0)
}
	b=gcd1(m,n)
	y=n/a
	p=p/a
	z=mod(b*p,y)
	<- "The solution is x ="
	for(t=0;t<a;t++){<- " ",z+t*y,","}
	<- " mod ",n,"\n"
	<- "or equivalently, x = ",z," mod "; return(y)
}

/* the congruence mx=p(mod n)
 * with printout suppressed-used in general form of the Chinese
 * remainder  theorem .
 */
define cong1(m,p,n){
        auto a,b,x,y
	a=gcd(m,n)
	if(mod(p,a)>0){return(-1)}
	b=gcd1(m,n)
	y=n/a
	p=p/a
	x=mod(b*p,y)
	return(x)
}

/* the Chinese remainder theorem for the congruences x=a(mod m)
 * and x=b(mod n), m>0, n>0, a and b arbitrary integers.
 * The construction of O. Ore, American Mathematical Monthly,
 * vol.59,pp.365-370,1952, is implemented.
 */

define chinese(a,b,m,n) {
	auto c,d,x,y,z
	d = gcd(m,n)
	if(mod(a-b,d)!=0){
		"the number of solutions is "
		return(0)
	}
	x= m/d;y=n/d
	z=(m*n)/d
	c = mod(b*gcd1(x,y)*x + a*gcd2(x,y)*y,z)
	<- "the solution mod(",z,") is "; return(c)
}

/* gcd(m[0],m[1],...,m[n-1])=b[0]*m[0]+...+b[n-1]*m[n-1] */

define gcda(m[],n){
	auto a,i,c,d,k,b[],t
	t=n
	n=n-1
	for(i=0;i<=n;i++) b[i]=m[i]
	for(i=1;i<=n;i++) b[i]=gcd(b[i],b[i-1])
	a=b[n]
	b[n]=m[n]
	k=1
	for(i=n;i>=1;i--) {
		c=b[i];d=b[i-1]
		b[i]=gcd1(c,d)*k
		if(i==1) break
		k=k*gcd2(c,d)
		b[i-1]=m[i-1]
	}
	b[0]=k*gcd2(c,d)
	for(i=0;i<n;i++){<- "(",b[i],")*",m[i],"+"}
	<- "(",b[n],")*",m[n]
	<- " = "; return(a)
}

/* lcm(a,b) for any integers a and b */

define lcm(a,b){
	auto g
	g=gcd(a,b)
	if(g==0) return(0)
	return(abs(a*b)/g)
}

/* lcm(m[0],m[1],...,m[n-1]) */

define lcma(m[],n){
	auto i,b[]
	for(i=0;i<n;i++) b[i]=m[i]
	for(i=1;i<n;i++) b[i]=lcm(b[i],b[i-1])
	return(b[n-1])
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
		}
		y=y-1
		z=mod(z*x,c)
	}
	return(z)
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

define mthrootr(a,b,m,r){
	auto s,x,y,i,z,d,f
	f=exp(10,r)
	a=a*exp(f,m)
	a=a/b
	if(a==0){
		if(r==0){
			"answer = ";return(0)
		}
		"answer = 0."
		for(i=1;i<=r;i++)"0"
		return(0)
	}
	s=a
	while(s>1){
		s=s/2
		i=i+1
	}
	x=exp(2,1+(i/m))
	while(1==1){
		y=x
		z=exp(x,m-1)
		x=x+int(a-x*z,m*z)
		if(y<=x)break
	}
	if(r==0){
		 "answer = ";return(y)
	}
	d=y%f
	"answer = ";y/f
	"."
	for(i=1;i<=r-length(d);i++)"0"
	return(d)
}

define mthroot(a,b,m){
/*
 * See K.R. Matthews, Computing mth roots,
 * College Mathematics Journal 19 (1988) 174-176.
 */
	auto s,x,y,i,z,d,j
	a=a/b
	if(a==0)return(0)
	s=a
	while(s>1){
		s=s/2
		i=i+1
	}
	x=exp(2,1+(i/m))
/*	<- "x[0]=",x,"\n"*/
	j=1
	while(1==1){
		y=x
		z=exp(x,m-1)
		x=x+int(a-x*z,m*z)
		/*<- "x[",j,"]=",x,"\n"*/
		j=j+1
		if(y<=x) break
	}
	return(y)
}

/* From the bc manual. */
/*
 * b(n,m) returns the binomial coefficient, the number of subsets each 
 * containing m elements from a set containing n elements.
 */

define binomial(n,m){
auto x,j
if(n<m)return(0)
if(m==0)return(1)
x=1
for(j=1;j<=m;j=j+1) x=x*(n-j+1)/j
return(x)
}

/* min(x,y) */

define min(x,y){
        if(y<x)return(y)
        return(x)
}


/* the Chinese remainder theorem for n simultaneous congruences
 * x=a[i] (mod m[i]), i=0,1,...,n-1, where m[i]>0 for all i and
 * a[0],...,a[n-1] are arbitrary integers.
 * the construction of O. Ore, American Mathematical Monthly,
 * vol.59,pp.365-370,1952, is implemented.
 */

/* the Chinese remainder theorem for the congruences x=a(mod m)
 * and x=b(mod n), m>0, n>0, a and b arbitrary integers.
 * The construction of O. Ore, American Mathematical Monthly,
 * vol.59,pp.365-370,1952, is implemented.
 * Same as chinese(), but with printing suppressed, except that -1
 * is returned if here is no solution.
 */

define chinese1(a,b,m,n) {
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


define chinesea(a[],m[],n){
	auto i,m,x
	m=m[0]
	x=a[0]
	for(i=1;i<n;i++){
		x=chinese1(a[i],x,m[i],m)
		if(x==-1)break
		m=lcm(m[i],m)
	}
	if(x==-1){
		<- "there is no solution\n"
	}\
	else{
		<- "the solution mod(",m,") is "; return(x)
	}
}

/* the Chinese remainder theorem for n simultaneous congruences
 * a[i]x=b[i] (mod m[i]), i=0,1,...,n-1, where m[i]>0 for all i.
 * a[0],...,a[n-1] and b[0],...,b[n-1] are arbitrary integers.
 */

define chineseb(a[],b[],m[],n){
        auto c[],i,m,s,x
	m=m[0]
	x=cong1(a[0],b[0],m[0])
	for(i=1;i<n;i++){
		s=cong1(a[i],b[i],m[i])
		if(s==-1){x=-1;break}
		c[i]=s
                x=chinese1(c[i],x,m[i],m)
                if(x==-1)break
                m=lcm(m[i],m)
        }
        return(x)

}

/* gnubc program : surd */
"
This program finds the continued fraction expansion of a
quadratic irrational (u+tsqrt(d))/v, where d is not a square,
t,u,v integers, v>0.
To run this program: type surd(d,t,u,v) (return)      
"
/* sign of an integer a */
/* sign(a)=1,-1,0, according as a>0,a<0,a=0 */

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

/*  mod(a,b)=the least non-negative remainder when an integer a is divided by a
 positive integer b */

define mod(a,b){
	auto c
	c=a%b
	if(a>=0) return(c)
	if(c==0) return(0)
        return(c+b)	
}

/* int(a,b)=integer part of a/b, a, b integers, b != 0 */

define int(a,b){
	auto c
	c=sign(b)
	a=a*c
	b=b*c
	return((a-mod(a,b))/b)
}

/*
 * This is a function for finding the period of the continued fraction
 * expansion of reduced quadratic irrational a=(u+sqrt(d))/v.
 * Here d is non-square, 1<(u+sqrt(d))/v, -1<(u-sqrt(d))/v<0.
 * The algorithm also assumes that v divides d-u*u and is based on K. Rosen,
 * Elementary Number theory and its applications, p.379-381 and Knuth's The art
 * of computer programming, Vol. 2, p. 359.  0 is returned if a is not reduced.
 */

define period(d,u,v){
	auto a,r,s,t,f,j,k
	f=sqrt(d)
	if(u<=0){"a is not reduced: u<=0:";return(0)}
	if(v<=0){"a is not reduced: v<=0:";return(0)}
	if(u+f<v){"a is not reduced: a<1:";return(0)}
	if(u+v<= f){"a is not reduced: a'<=-1:";return(0)}
	if(f<u){"a is not reduced: a'>0:";return(0)}
	k=d-u*u
	if(k%v!=0){"v does not divide d - u*u:";return(0)}
	s=v
	r=u
/* global variable i is created by r(d,t,u,v) below and indexes the ith 
convergent of (u+t*sqrt(d))/v */
	for(j=i;1;j++){
		a=(f+u)/v
                <- "a[",j,"]=",a, ", period\n"
		u=a*v-u
		v=(d-u*u)/v
		<- "        u[",j+1,"]=",u, ", v[",j+1,"]=", v,"\n" 
		if(u==r){if(v==s)return(j+1-i)}
/* the continued fraction has period length j+1-i */
	}
}

/*
 * This function uses the continued fraction algorithm expansion in K. Rosen,
 * Elementary Number theory and its applications,p.379-381 and Knuth's
 * The art of computer programming, Vol. 2, p. 359. It locates the first 
 * complete quotient that is reduced and then uses the function c(d,u,v)
 *  to locate the period of the continued fraction expansion.
 */

define surd(d,t,u,v){
	auto a,c,e,g,f,j,w,z
	c=d;g=u;e=v
	if(v==0){"v=";return(0)}
	f=sqrt(d)
	if(f*f==d){"d is the square of ";return(f)}
	if(t==0){"t = ";return(0)}
	z=sign(t)
	u=u*z
	v=v*z
	d=d*t*t
	w=abs(v)
	if((d-u*u)%w!=0){
		d=d*v*v
		u=u*w
		v=v*w
	}
	f=sqrt(d)
	for(j=0;1;j++){
	<- "        u[",j,"]=",u, ", v[",j,"]=", v,"\n"
		if(v>0){
			if(u>0){
				if(u<= f){
					if(f<u+v){
						if(v-u <=f){
				 /* (u+sqrt(d))/v is reduced */
							i=j
							l=period(d,u,v)
<- "\nThe continued fraction for (",g,"+",t,"*sqrt(",c,"))/";e
<- "has period length ";return(l)
						}
					}
				}
			}
		}
		if(v>0)a=int(f+u,v)
		if(v<0)a=int(f+u+1,v)
		<- "a[",j,"]=";a
		u=a*v-u
		v=int(d-u*u,v)
	}
}

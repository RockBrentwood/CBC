/* jacobi */

/*
 * jacobi(n,m), m > 1, m odd, returns the Jacobi symbol (n/m).
 * peralta(x,p) returns sqrt(x) (mod p).
*/


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
		}
		y=y-1
		z=mod(z*x,c)
	}
	return(z)
}

define jacobi(n,m){
auto s,p,t,i
s=1
n=mod(n,m)
if(n==0)return(0)
while(1){
	p=0
	while(n%2 == 0){
		n = n/2
		p = 1-p
	}
	if(p){
		t = m%8
		if(t==3){s = -s}
		if(t==5){s = -s}
	}
	if(n==1)break
	if(m%4==3){
		if(n%4==3){s = -s}
	}
	i = n
	n = m%n
	if(n==0)return(0)
	m = i
}
	return(s)
}

/*
 * x[0]+x[1]*sqrt(x)=(a+b*sqrt(x))(c+d*sqrt(x)) (mod p).
 * Used in R.C. Peralta's * probabilistic method for
 * finding sqrt(x) (mod p).
 */
define first(a,b,c,d,x,p){
	auto u,v

	u = (b*d)%p
	v = (a*c)%p
	u = (u*x)%p
	x[0] = (v+u)%p
	u = (b*c)%p
	v = (a*d)%p
	x[1] = (v+u)%p
}

/*
 * x[2]+x[3]*sqrt(x)=(a+bsqrt(x))^n (mod p).
 * Used in R.C. Peralta's * probabilistic method for
 * finding sqrt(x) (mod p).
 */
define second(a,b,n,x,p){
	auto g,h,i,j,y

	g = a
	h = b
	i = 1
	j = 0
	while(n){
		while (n%2 == 0){
			n = n/2
			y=first(g,h,g,h,x,p)
			g = x[0]
			h = x[1]
		}
		n = n-1
		y=first(i,j,g,h,x,p)
		i = x[0]
		j = x[1]
	}
	x[2] = i	
	x[3] = j	
}

/*
 * peralta(x,p) returns sqrt(x) (mod p).
 * See 'A simple and fast probabilistic algorithm for computing
 * square roots modulo a prime number', I.E.E.E. Trans.
 * Inform. Theory, IT-32, 1986, 846-847, R. Peralta.
 */
define peralta(x,p){
	auto r,z,y

	if (jacobi(x,p)!=1){
	<- x, " is not a quadratic residue mod "; return(p)
	}
	x=mod(x,p)
	z = (p-1)/2
	if(p%4==3)return(mpower(x,(z+1)/2,p))
	for(r=1;r<=z;r++){
		if(x==(r*r)%p)return(r)
		y=second(r,1,z,x,p)
		if(x[2]==0)return(mpower(x[3],p-2,p))
	}	
}

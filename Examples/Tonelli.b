/* bc program for the Shanks-Tonelli algorithm.
   "Square roots from 1; 24, 51, 10 to Dan Shanks",
   Ezra Brown, The College Mathematics Journal, 30, No. 2, 82-95, 1999
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
			/*<- z," ",x," ",y,"\n"*/
		}
		y=y-1
		z=mod(z*x,c)
		/*<- z," ",x," ",y,"\n"*/
	}
	return(z)
}


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

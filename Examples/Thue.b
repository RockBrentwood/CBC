/* gnubc program: thue */

"





SOLVING x^2-Dy^2=N or -N using	THUE'S ALGORITHM:
where N does not divide D-1, 



Type thue(d,u,p) to find small values k where x^2-dy^2=kp.
Here p is an odd prime, d!=1 (mod p), d>1 and not a perfect square
and u^2=d (mod p), 1<u<p.

"

/* Here u^2=d(mod p), 1<u<p. We use Thue's algorithm to
 * find small values k, of x^2-d*y^2=kp, p>1.
 * The first remainder r[k] <= sqrt(p) for the
 * Euclidean algorithm for p/u is found. 
 * Here r[0]=r[1]*q[1]+r[2]. 
 * Also the s[k] and t[k] are printed where 
 * s[0]=1,s[1]=0, s[j]=s[j-2]-q[j-1]*s[j-1],
 * t[0]=0,t[1]=1, t[j]=t[j-2]-q[j-1]*t[j-1], j=2,...,n+1
 * The length of the algorithm is also found. 
 * r[k],t[k],r[k-1],t[k-1],r[k-2],t[k-2], are printed.
 * All intermediate r[i],t[i] are printed as well, if e=1.
 */
define thue(d,u,p){
auto a,b,e,r,q,i,s0,s1,s2,t0,t1,t2,x,y,z
	if ((d-1)%p==0){
		<- d, "=1"," mod",p, "\n"
		return
	}
/*	if (jacobi(d,p)==-1){
		<- d," is not a quadratic residue mod ",p,"\n"
		return
	}*/
        s0=1;s1=0
	t0=0;t1=1
        a=p
        b=u
        r=p%u
        q=(a-r)/b
	/*if(e){
		<- "                      r[0]=",p,", s[0]=1,t[0]=0\n"
		<- a," = ",b,"*",q,"+",r,", q[1]=",q,", r[1]=",u, ", s[1]=0, t[1]=1\n"
	}*/
	i=1
        while(r>0){
	   if(r*r<=p){
              break
           }
           i=i+1
           s2=(-q)*s1+s0
           t2=(-q)*t1+t0
           a=b
           b=r
           r=a%b
           q=(a-r)/b
          /* if(e){
	       <- a," = ",b,"*",q,"+",r,", q[",i,"]=",q,", r[",i,"]=",b, ", s[",i,"]=", s2,", t[",i,"]=", t2,"\n"
	   }*/
           s0=s1;s1=s2
           t0=t1;t1=t2
        }
        s2=(-q)*s1+s0
        t2=(-q)*t1+t0
	i=i+1
	<- "r[",i-2,"]=",a, ", s[",i-2,"]=", s0,", t[",i-2,"]=", t0,"\n"
	<- "r[",i-1,"]=",b, ", s[",i-1,"]=", s1,", t[",i-1,"]=", t1,"\n"
	<- "r[",i,"]=",r, ", s[",i,"]=", s2,", t[",i,"]=", t2,"\n"
	x=(a^2-d*t0^2)/p
	y=(b^2-d*t1^2)/p
	z=(r^2-d*t2^2)/p
	if(x==1)
	<- "r[",i-2,"]^2-",d,"*t[",i-2,"]^2=", p,"\n"
	if(x==-1)
	<- "r[",i-2,"]^2-",d,"*t[",i-2,"]^2=", "-",p,"\n"
	if(x!=1 && x!=-1)
	<- "r[",i-2,"]^2-",d,"*t[",i-2,"]^2=", x,"*",p,"\n"
	if(y==1)
	<- "r[",i-1,"]^2-",d,"*t[",i-1,"]^2=", p,"\n"
	if(y==-1)
	<- "r[",i-1,"]^2-",d,"*t[",i-1,"]^2=", "-",p,"\n"
	if(y!=1 && y!=-1)
	<- "r[",i-1,"]^2-",d,"*t[",i-1,"]^2=", y,"*",p,"\n"
	if(z==1)
	<- "r[",i,"]^2-",d,"*t[",i,"]^2=", p,"\n"
	if(z==-1)
	<- "r[",i,"]^2-",d,"*t[",i,"]^2=", "-",p,"\n"
	if(z!=1 && z!=-1)
	<- "r[",i,"]^2-",d,"*t[",i,"]^2=", z,"*",p,"\n"
/*        <- "the Euclidean algorithm for p/u with p = ",p, " u = ",u
        <- " has length ";  return(i)*/
}
/*define lagrange(d,e){
	auto i,p,r
	for(i=0;i<=2047;i++){
		p=pglobal[i]
		r=p%28
		if(r==1 || r==9 || r==25 || r==3 || r==19 || r== 27){
			<- "p=",p,"\n"
			thue(d,p)
		}
	}
}
*/

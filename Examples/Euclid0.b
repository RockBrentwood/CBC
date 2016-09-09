/* gnubc program: Euclid */

"





			EUCLID'S ALGORITHM:







""If euclid(m,n) is typed in (m>0,n>0), 

""the quotients q[k], remainders r[k] for the

""Euclidean algorithm for m/n are printed, 

""starting with r[0]=r[1]*q[1]+r[2]. 

""Also the s[k] and t[k] are printed where 

 ""s[0]=1,s[1]=0, s[j]=s[j-2]-q[j-1]*s[j-1],
 ""t[0]=0,t[1]=1, t[j]=t[j-2]-q[j-1]*t[j-1], j=2,...,n+1

""The length of the algorithm is printed. (Type quit to quit)

"

define euclid(m,n){
auto a,b,r,q,i,s0,s1,s2,t0,t1,t2
        s0=1;s1=0
	t0=0;t1=1
        a=m
        b=n
        r=m%n
        q=(a-r)/b
	<- "                      r[0]=",m,", s[0]=1,t[0]=0\n"
	<- a," = ",b,"*",q,"+",r,", q[1]=",q,", r[1]=",n, ", s[1]=0, t[1]=1\n"
	i=1
        while(r>0){
           i=i+1
           s2=(-q)*s1+s0
           t2=(-q)*t1+t0
           a=b
           b=r
           r=a%b
           q=(a-r)/b
<- a," = ",b,"*",q,"+",r,", q[",i,"]=",q,", r[",i,"]=",b, ", s[",i,"]=", s2,", t[",i,"]=", t2,"\n"
           s0=s1;s1=s2
           t0=t1;t1=t2
        }
           s2=(-q)*s1+s0
           t2=(-q)*t1+t0
	i=i+1
	<- "                      r[",i,"]=0", ", s[",i,"]=", s2,", t[",i,"]=", t2,"\n"
        <- "the Euclidean algorithm for m/n with m = ",m, " n = ",n
        <- " has length "; return(i)
}   

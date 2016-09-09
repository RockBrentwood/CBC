"This is a modified form of Shanks' log_b(a) algorithm 
""See  http://www.maths.uq.edu.au/~krm/log.pdf, page 6.
""Typing log_b(a,b,d,u,v),  a>b>1,d>1, u>v>=1
""outputs a sequence of integers that is likely
""to be the initial partial quotients of log_b(a)/log_b(b)
""if d,u,v and u-v are large.
"
define log_b(a,b,d,u,v){
        auto x,y,aa,bb,i,j,c,cc,s,ss,t,n,nn
	i=0
	j=0
        s=2
        ss=2
	c=d^u
	cc=d^v
	x=a
	y=b
        a=x*c
        aa=x*cc
        b=y*c
        bb=y*cc
        while(b> c && bb > cc){
                while(a>=b){
                    a=(a*c)/b
                    i=i+1
                }
		n=i
		s=s+1
		t=b
		b=a
		a=t
		i=0 /* reset the partial quotient count */
                while(aa>=bb){
                    aa=(aa*cc)/bb
                    j=j+1
                }
		nn=j
		ss=ss+1
		t=bb
		bb=aa
		aa=t
		j=0 /* reset the partial quotient count */
		if(n!=nn){
			<- n,"!=",nn,"\n"
			break
		}
		<- "n[",s-3,"]=",n,"\n"
        }
	<- "\n"
	return(0)
}

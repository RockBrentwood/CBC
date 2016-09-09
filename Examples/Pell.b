/* gnubc program: pell */
"This is a program for finding least solution of Pell's equations x^2-d*y^2=+-1,2."
"The algorithm is based on K. Rosen, Elementary number theory and its applications, p382,"
"B.A. Venkov, Elementary Number theory, p.62 and D. Knuth, Art of computer programming, Vol.2, p359."
"To run the program for (say) d=33: type pell(33) (return)"

define pell(d){
	auto b,c,i,k,l,m,n,r,s,t,u,v,x,y
	b=x=sqrt(d)
"b=";b
	if(x*x==d){d;"is a perfect square ";return(0)}
	c=1
"c=";c
	l=0;k=1;m=1;n=0
	<- "sqrt(d)+[srqt(d)] has purely periodic continued fraction\n"
	<- " expansion with period partial quotients:\n"
	for(i=0;1;i++){
		y=(x+b)/c
		<- "a[",i,"] = ";y
		b=y*c-b
"b=";b
		c=(d-(b*b))/c
"c=";c
		if(i==0)y=x
		u=k*y+l;v=n*y+m
/* u/v is the i-th convergent to sqrt(d) */
		l=k;m=n
		k=u;n=v
		if(c==2){t=1;r=u;s=v}
		if(c==1){
if(t){
<- "the least solution of u*u-",d,"*v*v = ",(-1)^((i+1)%2)*2," is:\n"
<- "u = ",r,"\n"
<- "v = ",s,"\n"
}
<- "the least solution of u*u-",d,"*v*v = ",(-1)^((i+1)%2)," is:\n"
<- "u = ",u,"\n"
<- "v = "; return(v)
		}
	}
}

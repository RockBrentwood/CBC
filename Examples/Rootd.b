/* gnubc program: rootd */
"This is a program for finding the period of the regular continued
""fraction expansion of square-root d.
""The algorithm is from Sierpinski's 'Theory of Numbers', p.296 and 
""Davenport's 'The Higher Arithmetic', p.109. 
""Here sqrt(d)=a[0]+1/a[1]+...+1/a[n-1]+1/2*a[0]+1/a[1]+... 
""The sequence a[1],...,a[n-1] is palindromic and we print only
""a[0],a[1],...,a[i] if n = 2i or n = 2i+1.

""To run the program for (say) d=46: type	'root(46)' (return)      
"

define root(d){
	auto b,c,y,a[],l,k,m,n,h,p,e,f

	y=a[0]=sqrt(d);b=a[0];c=a[1]=d-(y*y)
	if(y*y==d){d;"is a perfect square ";return(0)}
	<- "a[0] = ",y,"\n"
	for(i=0;1;i++){
		y=(a[0]+b)/c
		<- "a[",i+1,"] = ",y,"\n"
		e=b
		b=y*c-b
		f=c
		c=(d-(b*b))/c
		if(b==e){
			i=i+1
			<- "the regular continued fraction for sqrt(",d,")\n"
<- "has even period length = ";return(2*i)
		}
		if(c==f){
			i=i+1
			<- "the regular continued fraction for sqrt(",d,")\n"
<- "has even period length = ";return(2*i+1)
		}
	}
}

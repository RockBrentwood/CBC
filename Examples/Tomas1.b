/* gnubc program: tomas1 */

"
""        Iteration of Tomas Oliveira e Silva's mapping T_5
""        -------------------------------------------------------

""		a = mod(x,6)
""		if(a==0) return(x/2)
""		if(a==1) return(5*x+1)
""		if(a==2) return(x/2)
""		if(a==3) return(x/3)
""		if(a==4) return(x/2)
""		if(a==5) return(5*x+1)





""if tomas1(y) is typed in, the iterates

""y, t(y), t(t(y)),... of t(x) are printed

""and the number of steps taken to reach one of the cycles 

""starting with 0; 1; -1; -7 is recorded.

""is recorded.  (It is conjectured that every trajectory

""will end up as one of these numbers, the complete cycles being 

""0; 1,6,3;  -1,-4,-2;  -7,-34,-17,-84,-42,-21.)

"

/*  the least non-negative remainder when an integer a is divided by a positive
integer b */

/* a%b=m(a,b) if a>=0 or a<0 and b divides a */
/* a%b=m(a,b)-b if a<0, b>0, a not divisible by b */

define mod(a,b){
	auto c
	c=a%b
	if(a>=0) return(c)
	if(c==0) return(0)
        return(c+b)	
}

define t(x){
	auto a
	a = mod(x,6)
	if(a==0) return(x/2)
	if(a==1) return(5*x+1)
	if(a==2) return(x/2)
	if(a==3) return(x/3)
	if(a==4) return(x/2)
	return(5*x+1)
}

define tomas1(y){
	auto i,x
	x=y
		for(i=0;i>=0;i++){
	
			if(x==0){
				"starting number = ";y;
				"the number of iterations taken to reach 0 is "
				return(i)
			}
			if(x==1){
				"starting number = ";y;
				"the number of iterations taken to reach 1 is "
				return(i)
			}
			if(x == -1){
				"starting number = ";y
				"the number of iterations taken to reach -1 is "
				return(i)
			}
			if(x == -7){
				"starting number = ";y
				"the number of iterations taken to reach -5 is "
				return(i)
			}
			(x=t(x)) /* this prints t(x) */
		}
}

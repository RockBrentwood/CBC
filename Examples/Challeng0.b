/* gnubc program: challenge */

"
			A GENERALIZED 3x+1 CONJECTURE:





""Let t(x)=x if 3|x, (7x+2)/3 if 3|x-1, (x-2)/3 if 3|x-2.

""If s(y) is typed in, the iterates y, t(y), t(t(y)),... of the 

""generalized 3x+1 function t(x) are printed until either an iterate

""is = 0 (mod 3) or reaches one of the cycles -1,1 or -2,-4,-2.

""The number of steps taken is recorded.

""(Keith Matthews conjectures that every trajectory will end in this

""and offers $100 for a proof.)
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

/* the t(x) function */
define t(x){
auto r
	r=mod(x,3)
	if(r==0) return(x)
	if(r==1) return((7*x+2)/3)
	return((x-2)/3)
}

define s(y){
	auto i,r,x
	x=y
		for(i=0;i>=0;i++){
			r = mod(x,3)	
			if(r==0){
				"starting number = ";y;
				"the number of iterations taken to reach the zero class is "
				return(i)
			}
			if(x == -1){
				"starting number = ";y
				"the number of iterations taken to reach -1 is "
				return(i)
			}
			if(x == -2){
				"starting number = ";y
				"the number of iterations taken to reach -2 is "
				return(i)
			}
			(x=t(x)) /* this prints t(x) */
		}
}

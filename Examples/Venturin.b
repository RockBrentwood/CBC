/* gnubc program: venturini1 */
"
""Let t(x)=2500x/6+1 if 6|x, (21x-9)/6 if 6|x-1, (x+16)/6 if 6|x-2, 
""(21x-51)/6 if 6|x-3, (21x-72)/6 if 6|x-4, (x+13)/6 if 6|x-5 .

""If s(y) is typed in, the iterates y, t(y), t(t(y)),... of the 
""generalized 3x+1 function t(x) are printed until one of two cycles 
""is reached:

""2,3,2 or 
""6, 2501, 419, 72, 30001, 105002, 17503, 61259, 10212, 4255001, 
""709169, 118197, 413681, 68949, 241313, 40221, 140765, 23463, 82112,
""13688, 2284, 7982, 1333, 4664, 780, 325001, 54169, 189590, 31601, 
""5269, 18440, 3076, 10754, 1795, 6281, 1049, 177, 611, 104, 20, 6

""The number of steps taken is recorded.
""This is example 1 of G. Venturini, 'Iterates of Number Theoretic 
""Functions with Periodic Rational Coefficients (Generalization of the 
""3x+1 Problem)' Studies in Applied Mathematics, 86 (1992)185-218.
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
	r=mod(x,6)
	if(r==0) return(2500*x/6+1)
	if(r==1) return((21*x-9)/6)
	if(r==2) return((x+16)/6)
	if(r==3) return((21*x-51)/6)
	if(r==4) return((21*x-72)/6)
	return((x+13)/6)
}

define s(y){
	auto i,r,x
	x=y
		for(i=0;i>=0;i++){
			if(x == 2){
				"starting number = ";y
				"the number of iterations taken to reach 2 is "
				return(i)
			}
			if(x == 6){
				"starting number = ";y
				"the number of iterations taken to reach 6 is "
				return(i)
			}
			(x=t(x)) /* this prints t(x) */
		}
}

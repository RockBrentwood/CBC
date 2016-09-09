
/* gnubc program: tomas2 */

"
""        Iteration of Tomas Oliveira e Silva's mapping T_7(x)=t(x):
""        -------------------------------------------------------

""		if(x(mod 2)=0) return(x/2)
""		if(x(mod 2)=1 and x(mod 3)=0) return(x/3)
""		if(x(mod 2)=1 and x(mod 3)!=0 and x(mod 5)=0) return(x/5)
""		if(x(mod 2)=1 and x(mod 3)!=0 and x(mod 5)!=0) return(7x+1)





""if tomas2(y) is typed in, (y non-zero), the iterates

""y, t(y), t(t(y)),... of t(x) are printed

""and the number of steps taken to reach one of the cycles 

""starting with 0; 1; -1; -11; -509, -701, -961 is recorded.

""is recorded.  (It is conjectured that every trajectory 

""will end up as one of these numbers, the complete cycles being 


""0; 
""1,8,4,2;
""-1,-6,-3;
""-11,-76,-38,-19,-132,-66,-33:
""-509,-3562,-1781,-12466,-6233,-43630,-21815,-4363,-30540,-15270,-7635,-2545;
""-701,-4906,-2453,-17170,-8585,-1717,-12018,-6009,-2003,-14020,-7010,-3505;
""-961,-6726,-3363,-1121,-7846,-3923,-27460,-13730,-6865,-1373,-9610,-4805.
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
	auto a,b,c
	a = mod(x,2)
	b = mod(x,3)
	c = mod(x,5)
	if(!a)return(x/2)
	if(a && !b)return(x/3)
	if((a && b) && !c)return(x/5)
	if((a && b) && c)return(7*x+1)
}

define tomas2(y){
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
			if(x == -11){
				"starting number = ";y
				"the number of iterations taken to reach -11 is "
				return(i)
			}
			if(x == -509){
				"starting number = ";y
				"the number of iterations taken to reach -509 is "
				return(i)
			}
			if(x == -701){
				"starting number = ";y
				"the number of iterations taken to reach -701 is "
				return(i)
			}
			if(x == -961){
				"starting number = ";y
				"the number of iterations taken to reach -961 is "
				return(i)
			}
			(x=t(x)) /* this prints t(x) */
		}
}

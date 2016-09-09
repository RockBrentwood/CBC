number mpower(number a, number b, number c);
number lucas(number a);

/* bc program leastqnr for finding the least quadratic non-residue mod p. */
/* needs lucas and jacobi. */

define leastqnr(p){
auto i,r,t,x

x=p/2
r=mpower(2,x,p)
if(r == p-1){<- "n[",p,"]=";return(2)}

for(i=3;i<p;i=i+2){
	t=lucas(i)
	if(t){
		r=mpower(i,x,p)
		if(r== p-1){<- "n[",p,"]=";return(i)}
	}
}
}

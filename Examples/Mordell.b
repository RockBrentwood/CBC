number abs(number a);
number mthroot(number a, number b, number c);

/* gnubc program mordell */
"Typing f(a,k), a!=0, tries to find solutions of y^2=x^3+a for x<=k.
"
define f(a,k){
	auto i,t,y,w,x,z
	z=0
t=mthroot(abs(a),1,3)
if(a>0){b = -t}\
else {b=t}
    for(x=b;x<=k;x++){
	w=x^3+a
	if(w>0){y=sqrt(w)}
	if(y*y==w){<- "(x,y)=(",x,",",y,")\n";z=z+1}
    }
	"number of solutions = ";return(z)
}

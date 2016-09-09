/* gnubc program: pollard */
"
The Pollard p-1 method for obtaining a factor of a COMPOSITE integer.
Typing pollard(2^107+2^54+1) activates the Pollard p-1 factorization
algorithm
"
/* a^b (mod c) */
/* a,b,c integers, a,b>=0,c>=1 */

define e(a,b,c){
	auto x,y,z
	x=a
	y=b
	z=1
	while(y>0){
		while(y%2==0){
			y=y/2
			x=(x*x)%c
		}
		y=y-1
		z=(z*x)%c
	}
	return(z)
}

/*  gcd(m,n) for non--negative integers m and n */
/* Euclid's division algorithm is used. */

define g(m,n){
	auto a,b,c
	if(n==0)return(m)
	a=m
        b=n
        c=a%b
        while(c>0){
		a=b
                b=c
                c=a%b
        }
	return(b)
}   

define pollard(n){
	auto i,p,t,b
	b=t=2
	p=1
	for(i=2;i<=10^6;i++){
			if(i%10==0){"i=";i}
			t=e(t,i,n)/* now t=b ^(i!) */
			p=g(n,t-1)
			if(p>1){
				if(p<n){
		<- "With b = ",b,", i = ",i,", n = ",n,",\n"
		<- "gcd(b^i!-1,n)=",p, " is a proper factor of n = ";return(n)
				}
			}
			if(p==n){
			i=2;t=b=b+1
			"b= ";b
			if(b==100) {"number of factors found is ";return(0)}
			}
	}
			"number of factors found is ";return(0)
}

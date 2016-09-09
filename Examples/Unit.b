/* gnubc program: unit */
"
""This is a program for finding the fundamental unit of Q(sqrt(d)).
""The algorithm is based on K. Rosen, Elementary number theory
""and its applications, p382, B.A. Venkov, Elementary Number theory,
""p.62 and D. Knuth, Art of computer programming, Vol.2, p359, with
""Pohst's trick of using half the period.
""w=(1+sqrt(d))/2 if d=1 (mod 4), w=sqrt(d) otherwise.
""To run the program for (say) d=33: type unit(33) (return)
"
define unit(d){
	auto b,c,e,f,g,h,i,k,l,m,n,r,s,t,u,v,x,y,z
	x=sqrt(d)
	if(d==5){
		<- "the fundamental unit of Q(sqrt(",d,")) is w\n"
		<- "norm=";return(-1)
	}
	b=x;c=1
	h=(x-1)/2
	t=2*h+1
	z=d%4
	if(z==1){b=t;c=2}
	g=x*x
	if(d==g){d;"is a perfect square ";return(0)}
	if(d==g+1){/* period 1, exceptional case */
                 <- "the fundamental unit of Q(sqrt(",d,")) is x+yw\n"
		 if(z==1){
			 <- "x=";x-1
			 <- "y=";2
		 }\
		 else{
			 <- "x=";x
			 <- "y=";1
		 }
		 if (z == 1){<- "w=(1+sqrt(",d,"))/2\n"}
		 if (z !=1) {<- "w=sqrt(",d,")\n"}
		 <- "norm=";return(-1)
	}
	if(d==t^2+4){/* period 1, exceptional case */
                 <- "the fundamental unit of Q(sqrt(",d,")) is x+yw\n"
                 <- "x=";h
                 <- "y=";1
		 if (z == 1){<- "w=(1+sqrt(",d,"))/2\n"}
		 if (z !=1){<- "w=sqrt(",d,")\n"}
		 <- "norm=";return(-1)
	}
	l=0;k=1;m=1;n=0
	for(i=0;1;i++){
		y=(x+b)/c
		"i = ";i
		f = b
		b=y*c-b
		e = c
		c=(d-(b*b))/c
		if(i==0){y=x;if(d%4==1)y=h}
		r=l;s=m
		u=k*y+l;v=n*y+m
		l=k;m=n
		k=u;n=v
/* u/v is the i-th convergent to sqrt(d) or (sqrt(d)-1)/2 */
	if(i){
		if(b==f){/*\alpha_h=\alpha_{h+1}, even period 2h */
                 <- "the fundamental unit of Q(sqrt(",d,")) is x+yw\n"
                 <- "x=";m*(u+r)+(-1)^(i%2)
                 <- "y=";m*(v+s)
		 if (z == 1){<- "w=(1+sqrt(",d,"))/2\n"}
		 <- "w=sqrt(",d,")\n"
		 <- "norm=";return(1)
		}
		if(c==e){/*\beta_{h-1}=\beta_h, odd period 2h-1 */
                 <- "the fundamental unit of Q(sqrt(",d,")) is x+yw\n"
                 <- "x=";u*v+l*m
                 <- "y=";v*v+m*m
		 if (z == 1){<- "w=(1+sqrt(",d,"))/2\n"}
		 <- "w=sqrt(",d,")\n"
		 <- "norm=";return(-1)
		}
	}
    }
}

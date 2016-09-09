number mod(number a, number b);

" variant1 of Shanks' log_b(a) algorithm.
"" See  http://www.maths.uq.edu.au/~krm/log.pdf.
"" Typing log(a,b,d,r,e) experimentally computes n 
"" (approximately 2r) partial quotients of log(a)/log(b)
"" if d >=2. 
"" We do not guarantee that these are indeed the 
"" first n partial quotients.  
"" e=0 prints only the partial quotients, while 
"" e=1 also prints the convergents and the A[i]
"" of the above paper.
"" The number of partial quotients is returned.
"

/* int(a,b)=integer part of a/b, a, b integers, b != 0 */

define int(a,b){
	if(b<0){
	a= -a
	b= -b
	}
	return((a-mod(a,b))/b)
}


/* m,n,u,v are positive integers, b is the base.
 * We compare the base b expansions. If the integer parts
 * of m/n and u/v are equal, we go on to compare the expansions
 * after the decimal point. We print out the t common decimals and
 * the number t.
 */
define compare(m,n,u,v,b){
	auto i,r,s,t,p,rr,pp
	scale=0
	
	r=m/n
	rr=u/v
 /* integer parts are equal */
	if(r==rr){<- r}\
	else{
/*	<- "integer part difference !="*/
	return(0)
	}
	m=m-r*n
	u=u-rr*v
	i=0
	p=b*m;pp=b*u
	r=p%n;rr=pp%v
	s=(p-r)/n /* the first decimal digit of {m/n} */
	t=(pp-rr)/v /* the first decimal digit of {u/v} */
	<- "."
	while(s==t){
		<- s
		p=b*r;pp=b*rr
		r=p%n;rr=pp%v
		s=(p-r)/n /* the i-th decimal digit of {m/n} */
		t=(pp-rr)/v /* the i-th decimal digit of {u/v} */
		i=i+1
	}
	<- "\n"
/*	if (i==0){<- "no. of common decimal digits after the decimal point is "} */
	return(i)
}
define log_b(a,b,d,r,z){
        auto e,i,c,rr,s,t, pn,qn,pp,qp,xx,yy,x,y,f
	xx=a
	yy=b
	i=0
        s=2
	pn=1
	pp=0
	qn=0
	qp=1
        rr=r
        c=d^(2*r)
	e=c+d^(r+2)
        a=a*c
        b=b*c
	if(z){
		<- "A[0]=",a,";\n"
		<- "A[1]=",b,";\n"
	}

        while(b>=e){
/* <- "a=",a,"; b=",b,"\n"   */
                while(a>=b){
                    a=(a*c)/b
/* <- "a=",a,"; b=",b,"\n" */
                    i=i+1
			if(z){
				pn=pn+pp
				qn=qn+qp
				
			}\
                }
		if(z){
			<- "A[",s,"]=",a,";"
			<- " n[",s-2,"]=",i,";\n"
scale=10*r
			<- "A/c=",a/c,"\n"
scale=0
			
		}\
		else{
			<- " n[",s-2,"]=",i,"\n"
		}
		s=s+1
		t=b
		b=a
		a=t
		i=0 /* reset the partial quotient count */
		if(z){
			t=pn
			pn=pp
			pp=t
			t=qn
			qn=qp
			qp=t
			<- " p[",s-3,"]/q[",s-3,"]=",qp, "/", pp, "\n"
		}
        }
/* <- "exit: b=",b,"; e=",e,"\n" */
	if(z){
		<- "the log of ",xx, " to base ",yy
		if(s==3){
			<- " has integer part ",qp,"\n"
		}
		<- " equals "
		if(pn){/* Actually pn >=1 here */
			tt=compare(qp,pp,qn,pn,10)
			if(tt==-1){
				x=qp*pn
				y=pp*qn
				<- " has integer part "
				if(x<y){
					z=int(qp,pp)
				}\
				else{
					z=int(qn,pn)
				}
				<- z,"\n"
			}\
			else{
				<- "truncated to ",tt," decimal places\n"
			}
		}
	}
	<- "the cutoff value for A[i] is ",e,"\n"
	<- "The number of partial quotients returned is "
	return (s-2)
}

number mpower(number a, number b, number c);
number inv(number a, number n);
number mod(number a, number b);

/*
 * bc program baby_giant. 11/7/99.
 */

/* Divide and conquer method for locating the
 * index k such that integer i=a[k] in the
 * sequence of distinct integers a[m],...,a[n].
 * returns -1 if i does not occur.
 */

define detect(i,a[],m,n){
auto j,k,l,t,s
j=m
k=n
s=k-j
while(s>1){
	t=(j+k)/2
	l=a[t]
	if(i==l)return(t)
	if(i<l)k=t
	if(i>l)j=t
	s=k-j
}
if(i==a[j])return(j)
if(i==a[k])return(k)
return(-1)
}

/* From "Algorithms", by R. Sedgewick, p. 118.
 * Here the arrays a[],b[] are global, being
 * produced by program shanks() below.
 * Initially b[k]=k, while at the end of sorting,
 * b[i]<-s[i], where s is the sorting permutation
 * and a[i]<-a[s[i]].
 */

define quicksort(l,r){
auto v,t,i,j,k,z

/*<- "l=",l,",r=",r,"\n"*/
if(r>l){
	v=a[r]
        i=l-1
        j=r
	while(j>i){
		while(1){
			i=i+1
			if(a[i]>=v)break
		}
		while(1){
			j=j-1
			if(a[j]<=v)break
		}
		t=a[i];z=b[i]
		a[i]=a[j]; b[i]=b[j]
		a[j]=t; b[j]=z;
	}
	a[j]=a[i]; b[j]=b[i];
	a[i]=a[r]; b[i]=b[r];
	a[r]=t; b[r]=z;
/*
	for(k=1;k<=5;k++){
		<- "a[",k,"]=",a[k],"\n"
		<- "b[",k,"]=",b[k],"\n"
	}
*/
        quicksort(l,i-1)
        quicksort(i+1,r)
}\
else return(0)
}

/* From O. Forster, "Algorithmische Zahlentheorie", Vieweg 1996,
 * 65-66.
 */
define shanks(x,g,p){
auto b,i,h,k,a[],b[]
q=(sqrt(4*p+1)+1)/2
/*q=q-1*/
for(i=0;i<=q;i++){b[i]=i}
for(k=0;k<=q;k++){
	<- "g^",q,"*",k,"=",mpower(g,q*k,p),"\n"
	a[k]=mpower(g,q*k,p)
}
b=quicksort(0,q)
h=inv(g,p)
for(i=0;i<q;i++){
	j=mod((x*mpower(h,i,p)),p)
	k=detect(j,a[],0,q)
	if(k>=0){
<- "q*(q+1)=",q*(q+1),",p=",p,"\n"
		<- "q=",q,";i=",i,";b[",k,"]=",b[k],"\n"
		<- "log ",x,"=";return((b[k]*q+i)%(p-1));
	}
}
}

"
""f(x)=a[n]x^n+...+a[0], a[n]>0, is a polynomial
""with integer coefficients, having no rational roots
""and having exactly one real positive root x, this
""being > 1.
""The method of Lagrange (1797) is used to find the
""the first m+1 partial quotients of x.
""type lagrange(a[],n,m)
"
/* (See Knuth, Art of computer programming, volume2,
problem 13, 4.5.3. Also S. Lang and H. Trotter,
'Continued fractions for some algebraic numbers'
J. fur Math. 255 (1972) 112-134; Addendum 267 (1974) ibid. 219-220.
Also see page 261, Number Theory with Applications, by R. Kumanduri and
C. Romero.
*/
/* Improved by Sean Seefried, Vacation scholar, University of Queensland, 17/12/99. */

/* returns a[0]+...+a[n] */
define sum(a[],n)
{
auto s,i;
s=0;
for (i=0;i<=n;i++)
  {s=s+a[i]}
return(s);
}


/* returns the integer part of the logarithm of n base 2 */
define log_base2(n) 
{
  auto p, logb;
  p=1;
  for (p=1; p<=n; p*=2) {
    logb=logb+1;
  }
  return (logb-1);
}

/* See Akritas, Elements of Computer Algebra with Applications p 352 
 * l = lambda */


define cauchy(a[],n)
{
  auto k, k_, k__, l, i, j, t, c, ci_, cn_, p, q, r, tmp;
  if (a[n] < 0) 
  for (c=0; c<=n; c++)
    a[c]=-a[c];
  /* count number of negative coefficients */
  l=0;
  for (c=0; c<n; c++) 
    if (a[c] < 0)
      l=l+1;
  k__ =0 ;
  j = log_base2(a[n]);
  t = 0;
  if (!(l==0 || n==0)) {
    for (c=0; c<n;  c++)
      if (a[c] < 0) {
	k=n-c;
	ci_ = -l*a[c];
	i = log_base2(ci_);
	p=i-j-1;
	q=p/k;
	r=p-k*q;
	if (r<0) {
	  r= r + k;
	  q = q - 1;
	}
	k_ = q + 1;
	if (r == (k-1)) {
	  cn_ = cn*2^(k_*k);
	  if (ci_ > cn_)
	    k_ = k_ + 1;
	}
	if (t==0 || k_ > k__) {
	  k__ = k_;
	  t = 1;
	}
      }
  }
  return (2^(k__));  
}

/* Evaluates a polynomial a[n]*x^n + ... + a[0] at x=b */
define evalp(a[],n,b) 
{
  auto i, j, val, term;
  for (i=0; i<=n; i++) {
    term=1;
    for (j=0; j<i; j++)
      term=term*b;
    val+=a[i]*term;
  }
  return (val);
}

/* prints polynomial in a[] to screen */
define printp(a[],n)
{
  auto i;
  if (n>1) 
    for (i=n;i>1;i--) {
      <- a[i],"x^",i," + ";
    }
  if (n>0)
    <- a[1],"x + ";
  <- a[0], "
";

}
define lagrange(a[],n,m)
{
  auto i,j,k,low,high,mid,t,s;
  s=scale;
  scale=0;

  for(i=0;i<=m;i++) {

    low=1;
    high=cauchy(a[],n);
/* standard binary search */
    while (low+1 != high) {
      mid=(low+high)/2;
      if (evalp(a[], n, mid) >0)
	{high=mid}\
		    else low=mid;
    }
    <- "a[",i,"]=",low, " \n" 
    /* assigns f(x) = f(x+aa) */
    for(k=0;k<=n-1;k++){
      for(j=n-1;j>=k;j--){
	a[j]=low*a[j+1]+a[j];
      }
    }
    for(j=n;j>n/2;j--){
      t=a[j];
      a[j]= -a[n-j];
      a[n-j]= -t;
    }
    if(n%2==0)
      {a[n/2]= -a[n/2]}
  }
  scale = s;
  <- "
";
}

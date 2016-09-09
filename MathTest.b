deg = a(1)/45, pi = 180*deg;
<- "Degree: ",deg,": pi: ",pi,".\n";
<- "Exponent:\n";
for (i = -5; i <= 5; i += 0.2) <- "e(",i,") = ",e(i),".\n";
<- "Logarithm:\n";
x = 1.2;
for (i = -5; i <= 5; i += 0.2) <- x,"^",i,"= ",x^i,".\n"
for (i = -5; i <= 5; i += 0.2) <- "l(",x,"^",i,"[= ",x^i,"]) = ",l(x^i),".\n"
<- "Arctangent:\n";
for (i = -5; i <= 5; i += 0.2) <- "a(",i,") = ",a(i)/deg," degrees.\n";
<- "Sine and cosine:\n";
for (i = -90; i < 90; i += 5) <- "1^{",i," degrees} = ",c(i*deg)," + i ",s(i*deg),".\n";
<- "Bessel:\n";
for (n = 0; n < 4; n++) for (i = -5; i <= 5; i += 0.2) <- "j(",n,",",i,") = ",j(n,i),".\n";
halt;

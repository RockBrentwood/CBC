// Get the stats routines.
include "Stats.b"

// First 24 lines of the Stats.b file.
ifile("Stats.b"); string s;
for (i = 0; i < 24; i++) { -> s; s; }
ifile(0);

// Do calculations to 20 places.
scale = 20;

number row[][];

// Row 0 = x
n = get(row[0], 0);

// Row 1 = x^2, Row 2 = x^3
for (i = 0; i < n; i++) row[1][i] = row[0][i]^2, row[2][i] = row[0][i]^3;

// Row 3 = y.
get(row[3], n);

// Averages, block form:
// < x's | y's >.
number ave[];
for (i = 0; i < 4; i++) ave[i] = m1(row[i], n);

<- "Averages: "; put(ave[], 4);

// Covariances, block form:
// / xx's | xy's \
// |------+------|
// \ yx's | yy's /
number covar[][];
for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) covar[i][j] = m2(row[i], row[j], n);

<- "Covariances:\n";
for (i = 0; i < 4; i++) put(covar[i], 4);

// Get the matrix routines.
include "Matrix.b"

// Invert the covariances matrix
number un[][];
invert(covar[], un[], 4);

<- "Inverse covariances:\n";
for (i = 0; i < 4; i++) put(un[i], 4);

// The inverse, un, has the form
// / U + b'b/c | -b/c \
// \ -b'/c     | 1/c  /
// c = yy variance times r-squared
// b = b coefficients, b' = transpose of b.
// U = inverse of xx covariance matrix.

number b[], rr;
for (i = 0; i < 4; i++) b[i] = -un[i][3]/un[3][3];
rr = 1/(un[3][3]*covar[3][3]);

// a coefficient
for (a = 0, i = 0; i < 4; i++) a -= ave[i]*b[i];

// Show the the regression.
<- "y = ", a, " + ", b[0], " x + ", b[1], " x^2 + ", b[2], " x^3\n";
<- "Fit = ", rr, "\n";

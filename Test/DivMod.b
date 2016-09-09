oldS = scale, scale = 2

r=114381625757888867669235779976146612010218296721242362562561842935706935245733897830597123563958705058989075147599290026879543541

a = r/2 - 2^21 - 7247; a
b = r%a; b
"last item should be: ";  2^22 + 14495
q = a/b;
r = a - q*b; r
e = a%b; e
"last 2 items are "
r == e? <- "equal\n": <- "not equal\n"
scale = oldS
quit

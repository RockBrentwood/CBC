scale=2
<- "\nCheck book program!\n"
<- "  Remember, deposits are negative transactions.\n"
<- "  Exit by a 0 transaction.\n\n"

<- "Initial balance? "; -> bal
bal /= 1
<- "\n"
while (1) {
  "current balance = "; bal
  "transaction? "; -> trans
  if (trans == 0) break;
  bal -= trans
  bal /= 1
}
quit

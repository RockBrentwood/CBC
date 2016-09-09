// Reference parameters tested.

define printArr(x[]) {
   number i;
   for (i = 0; i < 10; i++) x[i];
}

define mulArr(x[]) {
   auto i;
   for (i = 0; i < 10; i++) x[i] *= 2;
}

scale = 20;    
for (i = 0; i < 10; i++) a[i] = sqrt(i);

s = printArr(a[]); s = mulArr(a[]); s = printArr(a[]);
quit

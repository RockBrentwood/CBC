// 1st cumulant <x> = (x[0] + ... + x[n-1])/n (Average)
number m1(x[], n);

// 2nd cumulant <xy> - <x><y> (Covariance)
number m2(x[], y[], n);

// 3rd cumulant <xyz> - 1! (<x><yz> + <y><zx> + <z><xy>) + 2! <x><y><z>.
number m3(x[], y[], z[], n);

// 4th cumulant (long formula)
number m4(number w[], x[], y[], z[], n);

// Sample estimates of cumulants require adjustment.
number unbiased;
unbiased = 0; // 0 = Don't adjust, 1 = Adjust.

// Routine to read in values.
number get(x[], n);
// Routine to write out values.
number put(x[], n);
// Add in a prompt for the read routine.
number prompt;
prompt = 0; // 0 = don't prompt, 1 = prompt.

define m1(x[], n) {
// 1st cumulant: <x>
   number x, i;
   if (n <= 0) return 0;
   for (x = 0, i = 0; i < n; i++) x += x[i];
   return x / n;
}

define m2(x[], y[], n) {
// 2nd cumulant: <xy> - <x><y>
   number x, y, xy, i, m2;
   if (n <= (unbiased? 1: 0)) return 0;
   for (x = y = xy = 0, i = 0; i < n; i++)
      x += x[i], y += y[i], xy += x[i]*y[i];
   x /= n, y /= n, xy /= n;
   m2 = xy - x*y;
   if (unbiased) m2 *= n/(n - 1);
   return m2;
}

define m3(x[], y[], z[], n) {
// 3rd cumulant: <xyz> - <x><yz> - <y><zx> - <z><xy> + 2<x><y><z>
   number x, y, z, yz, zx, xy, xyz, i;
   if (n <= (unbiased? 2: 0)) return 0;
   for (x = y = z = yz = zx = xy = xyz = 0, i = 0; i < n; i++) {
      x += x[i], y += y[i], z += z[i];
      yz += y[i]*z[i], zx += z[i]*x[i], xy += x[i]*y[i];
      xyz += x[i]*y[i]*x[i];
   }
   x /= n, y /= n, z /= n, zx /= n, yz /= n, xy /= n, xyz /= n;
   m3 = xyz - x*yz - y*zx - z*xy + 2*x*y*z;
   if (unbiased) m3 *= n/(n - 1), m3 *= n/(n - 2);
   return m3;
}

define m4(w[], x[], y[], z[], n) {
// 4th cumulant
   number w, x, y, z, wx, wy, wz, xy, xz, yz, wxy, wxz, wyz, xyz, wxyz, i, m4;
   if (n <= (unbiased? 3: 0)) return 0;
   w = x = y = z = 0;
   wx = wy = wz = xy = xz = yz = 0;
   wxy = wxz = wyz = xyz = 0;
   wxyz = 0;
   for (i = 0; i < n; i++) {
      w += w[i], x += x[i], y += y[i], z += z[i];
      wx += w[i]*x[i], wy += w[i]*y[i], wz += w[i]*z[i];
      xy += x[i]*y[i], xz += x[i]*z[i], yz += y[i]*z[i];
      wxy += w[i]*x[i]*y[i], wxz += w[i]*x[i]*z[i];
      wyz += w[i]*y[i]*z[i], xyz += x[i]*y[i]*z[i];
      wxyz += w[i]*x[i]*y[i]*z[i];
   }
   w /= n, x /= n, y /= n, z /= n;
   wx /= n, wy /= n, wz /= n, xy /= n, xz /= n, yz /= n;
   wxy /= n, wxz /= n, wyz /= n, xyz /= n;
   wxyz /= n;
   m4 = wxyz
      - (w*xyz + x*wyz + y*wxz + z*wxy)
      - (wx*yz + wy*xz + wz*xy)
      + 2*(wx*y*z + wy*x*z + wz*x*y + xy*w*z + xz*w*y + yz*w*x)
      - 6*w*x*y*z;
   if (unbiased) m4 *= n/(n - 1), m4 *= n/(n - 2), m4 *= n/(n - 3);
   return m4;
}

define get(x[], n) {
   number i;
   for (i = 0; (n == 0) || (i < n); i++) {
      if (prompt) <- "Item #", i, ": ";
      if ((->x[i]) < 1) break;
      if (prompt) <- "\n";
   }
   if (prompt) <- "\n";
   return i;
}

define put(x[], n) {
   number i;
   for (i = 0; i < n; i++) <- " ", x[i];
   <- "\n";
}

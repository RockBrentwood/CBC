// Translation to C-BC guided by the translation, by Jim Storer, from FOCAL:
//	http://www.cs.brandeis.edu/~storer/LunarLander/LunarLander/LunarLanderListing.jpg
// to C:
//	https://www.cs.brandeis.edu/~storer/LunarLander/LunarLander.html
// The FOCAL original is from 1969.
string p;
number a; // (z) Altitude (miles)
number g; // (g) Gravity
number i; // (dz) Intermediate altitude (miles)
number j; // (dv) Intermediate velocity (miles/second)
number k; // (df) Fuel rate
number l; // (t) Elapsed time
number m; // (m+f) Total weight = Empty weight + Fuel weight
number n; // (m) Empty weight
number q; // (q) Local variable in subroutine p09().
number s; // (dt) Time elapsed in the current 10-second round (seconds)
number t; // (t0) Time remaining in the current 10-second round (seconds)
number v; // (v) Downward speed
number w; // (Working variable)
number z; // Thrust per pound of fuel burned

define erase() {
   p = "";
   z = w = v = t = s = q = n = m = l = k = j = i = g = a = 0;
}

scale = 7;
define trunc(x) {
   number sc; sc = scale, scale = 0, x /= 1, scale = sc; return x;
}

define string tab(pre, post, x) {
   number sc, scalex, i;
   sc = scale;
   scalex = (x == 0? 1: length(x)) - scale(x), scale = post; x /= 1;
   for (i = scalex; i < pre; i++) <- " ";
   <- x;
   scale = sc;
   return "";
}

define p06() {
_06_10: l = l + s, t = t - s, m = m - s*k, a = i, v = j;
}

define p09() {
_09_10: q = s*k/m, j = v + g*s + z*(-q - q^2/2 - q^3/3 - q^4/4 - q^5/5);
_09_40: i = a - g*s*s/2 - v*s + z*s*(q/2 + q^2/6 + q^3/12 + q^4/20 + q^5/30);
}

{ // Needed, because goto's at the top level are not permitted in C-BC.
// Restart
_01_04: <- "Control calling lunar module.\n";
        <- "Manual control is necessary.\n";
_01_06: <- "You may reset the thrust (K) each 10 seconds to 0 or any value between 8 and 200 lbs./second.\n";
_01_08: <- "You have 16000 lbs. fuel.\n";
_01_11: <- "The estimated free fall impact time is 120 seconds.\n";
_01_20: <- "The capsule weight is 32500 lbs.\n";
        <- "The first radar check is coming up.\n\n"; void=erase();
_01_30: <- "Commence the landing procedure.\n";
_01_40: <- "\tTime    Height     Speed     Fuel    Thrust\n"
        <- "\tSec.  Miles Feet    MPH      Lbs.    Lbs./Sec.\n"
_01_50: a = 120, v = 1, m = 32500, n = 16500, g = .001, z = 1.8;

_02_10: <- "\t",tab(4,0,l),"  ",tab(5,0,trunc(a))," ",tab(4,0,5280*(a - trunc(a)));
_02_20: <- "  ",tab(4,2,3600*v),"  ",tab(6,1,m - n),"  K = "; -> k; t = 10;
_02_70: if (200 < k) goto _02_72; if (8 <= k) goto _03_10; if (k < 0) goto _02_72; else if (k == 0) goto _03_10;
_02_72: <- "\tNot possible "; for (x = 1; x <= 23; x++) <- ".";
_02_73: <- " K = "; -> k; goto _02_70;

_03_10: if (m - n < .001) goto _04_10; if (t < .001) goto _02_10; s = t;
_03_40: if (n + s*k <= m) goto _03_50; s = (m - n)/k;
_03_50: void=p09(); if (i <= 0) goto _07_10; if (v <= 0) goto _03_80; if (j < 0) goto _08_10;
_03_80: void=p06(); goto _03_10;

// No more fuel.
_04_10: <- "Fuel out at        ",tab(8,4,l)," seconds\n";
_04_40: s = (sqrt(v*v + 2*a*g) - v)/g, v = v + g*s, l = l + s;

// On the moon.
_05_10: <- "On the moon at     ",tab(8,4,l)," seconds\n"; w = 3600*v;
_05_20: <- "Impact velocity of ",tab(8,4,w)," M.P.H.\n";
        <- "Fuel left:         ",tab(8,4,m - n)," lbs.\n";
_05_40: if (1 <= w) goto _05_50; <- "Perfect landing! - (lucky).\n"; goto _05_90;
_05_50: if (10 <= w) goto _05_60; <- "Good landing - (could be better).\n"; goto _05_90;
_05_60: if (22 <= w) goto _05_70; <- "Congratulations on a poor landing.\n"; goto _05_90;
_05_70: if (40 <= w) goto _05_81; <- "Craft damage. Good luck.\n"; goto _05_90;
_05_81: if (60 <= w) goto _05_82; <- "Crash landing - you have 5 hours oxygen.\n"; goto _05_90;
_05_82: <- "Sorry, but there were no survivors - you blew it!\n";
_05_83: <- "In fact you blasted a new lunar crater ",w*.277777," feet deep.\n\n";
_05_90: <- "Try again?\n";
_05_92: <- "(Answer yes or no)"; -> p; if (p != "no") goto _05_94; else goto _05_98;
_05_94: if (p != "yes") goto _05_92; else goto _01_20;
_05_98: <- "Control out.\n"; halt;

// Fall down.
_07_10: if (s < .005) goto _05_10; s = 2*a/(v + sqrt(v*v + 2*a*(g - z*k/m)));
_07_30: void=p09(); void=p06(); goto _07_10;

_08_10: w = (1 - m*g/(z*k))/2, s = m*v/(z*k*(w + sqrt(w*w + v/z))) + .05, void=p09();
_08_30: if (i <= 0) goto _07_10; void=p06(); if (j >= 0) goto _03_10; if (v <= 0) goto _03_10; else goto _08_10;
}

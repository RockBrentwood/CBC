// This normalizes a date of the form y/m/d, where y, m and d can be ARBITRARY integers, in such a way that:
// (a) months m out of the range 1-12 are adjusted to that range with a compensating change to the year y
// (b) days d out of the range for the month are treated as the number of days before/after the day preceding the month
// (c) the total number of days is taken from January 1, 1 BC, with this set to 0.
// (d) years before 1AD should be treated here in the "AD" calendar by the equivalence AD 0 = 1 BC, AD -1 = 2 BC, etc.
// (e) the corresponding "BC" calendar would treat 0 BC = AD 1, -1 BC = AD 2, etc.
// (f) everything is tied to "The Day The Universe Began" reference.
define days(number y, number m, number d) {
   number ly, dd;
// Normalize the month to the range [1, 12] and adjust the year.
   if (m < 1) y -= (12 - m)/12, m = 12 - (-m)%12; else y += (m - 1)/12, m = 1 + (m - 1)%12;
// Run the month down to 1 and adjust the days.
   if (m < 7) {
      if (m < 4) {
         if (m == 1) dd = -1; else if (m == 2) dd = 30; else dd = 58;
      } else {
         if (m == 4) dd = 89; else if (m == 5) dd = 119; else dd = 150;
      }
   } else {
      if (m < 10) {
         if (m == 7) dd = 180; else if (m == 8) dd = 211; else dd = 242;
      } else {
         if (m == 10) dd = 272; else if (m == 11) dd = 303; else dd = 333;
      }
   }
   d += dd;
// Adjust for the leap year and the leap day.
   if (y < 0) ly = -y; else ly = y;
   if (ly%400 == 0) ly = 1; else if (ly%100 == 0) ly = 0; else if (ly%4 == 0) ly = 1; else ly = 0;
   if (ly) {
      if ((y > 0) && (m >= 3)) d++; else if ((y <= 0) && (m < 3)) d--;
   }
// Run the year down to 1, adjust the days and normalize to The Day the Universe Began (Day 0 is a Friday).
   d += 365*y - 717379;
   if (y > 0) y--, d += y/4 - y/100 + y/400; else if (y < 0) y = -y + 3, d -= y/4 - y/100 + y/400;
   return d;
}

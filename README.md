some explaining<br/>
<br/>
goodkelvins.sh :<br/>
1 - is an hack that profits from redshift functionality and allows the user to automatically customize the display color temperature change throughout the day (and yes, redshift does it too; this is my hackish way to do it)<br/>
2 - up to the user to verify that redshift works<br/>
3 - bc is needed for calculations (assumes bc is installed, no  testing performed; lazy, I know)<br/>
4 - for english locales; adapt as needed<br/>
5 - gnuplot is optional but it is nice to have a graph<br/>
6 - values in kelvins can go from 1000 to 25000 (redshift limitation)<br/>
7 - why this? because it was fun<br/>
 <br/>
#########################################<br/>
<br/>
variables<br/>
<br/>
kelvins_max=3000<br/>
maximum (positive integer) color value<br/>
<br/>
kelvins_min=1700<br/>
minimum (positive integer) color value<br/>
<br/>
obviously, $kelvins_min must be smaller than $kelvins_max<br/>
<br/>
day_start=8<br/>
hour value; positive (integers or reals);this is the time when the color value is set to $kelvins_max; no AM / PM; decimals are OK (eg, 8.5 equals 8h30mn); this will be converted to minutes<br/>
<br/>
day_end=20<br/>
hour value; positive (integers or reals);this is the time when the color value is set to $kelvins_min; no AM / PM; decimals are OK (eg, 20.5 equals 20h30mn); this will be converted to minutes<br/>
<br/>
sunset_bias=20<br/>
integers only; "delay" for the color changes within the time frame ($day_start to $day_end)<br/>
with higher $sunset_ bias values, the change to $kelvins_min (the warmer colors) is shifted towards $day_end<br/>
<br/>
$kelvins_max - ($kelvins_max - $kelvins_min) * (($current_time / $day_end) ^$sunset_bias)<br/>
Formula used to set the color value in kelvins with every call to goodkelvins.sh<br/>
<br/>
#########################################<br/>
<br/>
this runs one time only and sets the display color temperature according to the values in the variables and the $current_time<br/>
/path/to/goodkelvins.sh<br/>
<br/>
this enters simulation mode and shows the evolution of the display color temperature from $day_start to $day_end<br/>
/path/to/goodkelvins.sh --show-me<br/>
<br/>
if gnuplot is installed, we can see goodkelvins.sh color change in a nice graph<br/>
/path/to/goodkelvins.sh --plot<br/>
<br/>
this shows a small help<br/>
/path/to/goodkelvins.sh --help<br/>
/path/to/goodkelvins.sh whatevertexthere<br/>
<br/>
#########################################<br/>
<br/>
Some values<br/>
<br/>
so, for the values<br/>
kelvins_max=4000<br/>
kelvins_min=1700<br/>
day_start=8     will be converted to minutes (240)<br/>
day_end=20     will be converted to minutes (1200)<br/>
sunset_bias=20<br/>
<br/>
given the time, we get the color value in kelvins:<br/>
<br/>
3h10mn<br/>
$current_time=190   minutes<br/>
4000-(4000-1700)*((190/1200)^20) =  4000 kelvin (rounded), but 1700 ($kelvins_min) will be set<br/>
<br/>
8h40mn<br/>
$current_time=520  minutes<br/>
4000-(4000-1700)*((520/1200)^20) = 4000 kelvin (rounded)<br/>
<br/>
13h00mn<br/>
$current_time=950   minutes<br/>
4000-(4000-1700)*((780/1200)^20) = 4000 kelvin (rounded)<br/>
<br/>
15h50mn<br/>
$current_time=950   minutes<br/>
4000-(4000-1700)*((950/1200)^20) = 3978 kelvin (rounded)<br/>
<br/>
19h00mn<br/>
$current_time=1140   minutes<br/>
4000-(4000-1700)*((1140/1200)^20) = 3175 kelvin (rounded)<br/>
<br/>
19h50mn<br/>
$current_time=1190   minutes<br/>
4000-(4000-1700)*((1140/1200)^20) = 2054 kelvin (rounded)<br/>
<br/>
20h00mn<br/>
$current_time=1200   minutes<br/>
4000-(4000-1700)*((1200/1200)^20) = 1700 kelvin (rounded)<br/>
<br/>
20h20mn<br/>
$current_time=1230   minutes<br/>
4000-(4000-1700)*((1230/1200)^20) =  231 kelvin (rounded), but 1700 ($kelvins_min) will be set<br/>
<br/>
***************************<br/>
<br/>
crontab<br/>
<br/>
add goodkelvins.sh to crontab and make it repeatable every X minutes (this is the whole purpose of this scrit)<br/>
<br/>
in a terminal:<br/>
crontab -e <enter><br/>
<br/>
if unset, choose nano as your editor (the easiest option)<br/>
<br/>
at the end of crontab, add (for repeated calls to goodkelvins.sh every 2 minutes<br/>
use the minimum value of 1 minute (cron limitation) for a smoother change)<br/>
*/2 * * * * export DISPLAY=:0 && /path/to/goodkelvins.sh<br/>
<br/>
save and exit<br/>
**control o** + **control x** & **enter**<br/>
 

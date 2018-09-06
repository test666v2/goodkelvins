some explaining

goodkelvins.sh :
1 - is an hack that profits from redshift functionality and allows the user to automatically customize the display color temperature change throughout the day (and yes, redshift does it too; this is my hackish way to do it)

2 - up to the user to verify that redshift works

3 - bc is needed for calculations (assumes bc is installed, no  testing performed; lazy, I know)

4 - for english locales; adapt as needed

5 - gnuplot is optional but it is nice to have a graph

6 - values in kelvins can go from 1000 to 25000 (redshift limitation)

7 - why this? because it was fun
 
#########################################

variables

kelvins_max=3000
maximum (positive integer) color value

kelvins_min=1700
minimum (positive integer) color value

obviously, $kelvins_min must be smaller than $kelvins_max

day_start=8

hour value; positive (integers or reals);this is the time when the color value is set to $kelvins_max; no AM / PM; decimals are OK (eg, 8.5 equals 8h30mn); this will be converted to minutes

day_end=20

hour value; positive (integers or reals);this is the time when the color value is set to $kelvins_min; no AM / PM; decimals are OK (eg, 20.5 equals 20h30mn); this will be converted to minutes

sunset_bias=20

integers only; "delay" for the color changes within the time frame ($day_start to $day_end)
with higher $sunset_ bias values, the change to $kelvins_min (the warmer colors) is shifted towards $day_end

$kelvins_max - ($kelvins_max - $kelvins_min) * (($current_time / $day_end) ^$sunset_bias)

Formula used to set the color value in kelvins with every call to goodkelvins.sh

#########################################

this runs one time only and sets the display color temperature according to the values in the variables and the $current_time
/path/to/goodkelvins.sh

this enters simulation mode and shows the evolution of the display color temperature from $day_start to $day_end
/path/to/goodkelvins.sh --show-me

if gnuplot is installed, we can see goodkelvins.sh color change in a nice graph
/path/to/goodkelvins.sh --plot

this shows a small help
/path/to/goodkelvins.sh --help
/path/to/goodkelvins.sh whatevertexthere

#########################################

Some values

so, for the values
kelvins_max=4000
kelvins_min=1700
day_start=8     will be converted to minutes (240)
day_end=20     will be converted to minutes (1200)
sunset_bias=20

given the time, we get the color value in kelvins:

3h10mn
$current_time=190   minutes
4000-(4000-1700)*((190/1200)^20) =  4000 kelvin (rounded), but 1700 ($kelvins_min) will be set

8h40mn
$current_time=520  minutes
4000-(4000-1700)*((520/1200)^20) = 4000 kelvin (rounded)

13h00mn
$current_time=950   minutes
4000-(4000-1700)*((780/1200)^20) = 4000 kelvin (rounded)

15h50mn
$current_time=950   minutes
4000-(4000-1700)*((950/1200)^20) = 3978 kelvin (rounded)

19h00mn
$current_time=1140   minutes
4000-(4000-1700)*((1140/1200)^20) = 3175 kelvin (rounded)

19h50mn
$current_time=1190   minutes
4000-(4000-1700)*((1140/1200)^20) = 2054 kelvin (rounded)

20h00mn
$current_time=1200   minutes
4000-(4000-1700)*((1200/1200)^20) = 1700 kelvin (rounded)

20h20mn
$current_time=1230   minutes
4000-(4000-1700)*((1230/1200)^20) =  231 kelvin (rounded), but 1700 ($kelvins_min) will be set

***************************

crontab

add goodkelvins.sh to crontab and make it repeatable every X minutes (this is the whole purpose of this scrit)

in a terminal:
crontab -e <enter>

if unset, choose nano as your editor (the easiest option)

at the end of crontab, add (for repeated calls to goodkelvins.sh every 2 minutes
use the minimum value of 1 minute (cron limitation) for a smoother change)
*/2 * * * * export DISPLAY=:0 && /path/to/goodkelvins.sh

save and exit
<control><o><control><x><enter>

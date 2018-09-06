#!/bin/bash

#########################################

# This script sets a onetime value for the color of the display using redshift (see explanation at the end of the script)

# adapt as needed

# goto "starts here" to customize the values AFTER reading the info at the end of the script

###################################################

# DISCLAIMER

# Use this script at your own risk
# You, as a user, have no right to support even if implied
# Carefully read the script and then interpret, modify, correct, fork, disdain, whatever

###################################################

#Copyright (c) <2018> <test666v2>
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

###################################################

plot ()
{
    testing=$(locate gnuplot | grep bin)
   if [ -z "$testing" ]
      then
         echo "gnuplot is not installed"
         exit
   fi
   echo "Buiding data for gnuplot. Please wait"
   ! [ -f "$temp_dir.goodkelvins.plot" ] || rm "$temp_dir.goodkelvins.plot"
   for (( i  = day_start; i <= day_end ; i+=10 ))
      do
         i_time=$(echo "scale=2; $i/60" | bc -l)
         temp=$(echo "$kelvins_max-($kelvins_max-$kelvins_min)*($i/$day_end)^$sunset_bias" | bc -l)
         kelvins_set=$(echo "scale=0;$temp/1" | bc -l)
         echo "$i_time   $kelvins_set" >> "$temp_dir.goodkelvins.plot"
      done
   echo "Done"
   gnuplot -persist -e "plot '$temp_dir.goodkelvins.plot' with lines notitle" 2>&1 | 2>&1
   rm "$temp_dir.goodkelvins.plot"
   exit
}

show-me ()
{
   for (( i  = day_start; i <= day_end ; i+=10 ))
      do
         i_time="$(echo "scale=0; $i/60" | bc -l)h"
         i_time+="$(echo "$((i%60))")mn"
         temp=$(echo "$kelvins_max-($kelvins_max-$kelvins_min)*($i/$day_end)^$sunset_bias" | bc -l)
         kelvins_set=$(echo "scale=0;$temp/1" | bc -l)
         echo "$i_time   $kelvins_set"
         redshift -O $kelvins_set > /dev/null
         sleep 0.08
      done
   echo
   echo "Press <enter> key to keep current color mood ($kelvins_set kelvins)"
   echo
   echo "Enter the value (in kelvins, 1000-25000) to set othe color mood for the display"
   echo "It's possible to get different results for diferent displays"
   echo "Values 5500 to 6500 set midday color mood"
   echo "Values 5500 to 6500 are colder (bluish)"
   echo "Values lower than 5500 are warmer (orange/redish)"
   while [[ $testing != "TRUE" ]]
      do
         read -r kelvins_set
         ! [ -z $kelvins_set ] || exit
         if ! [[ -z "${kelvins_set##*[!0-9]*}" ]]
            then
               ! (( kelvins_set >= 1000 )) || ! (( kelvins_set <= 25000 )) ||  testing="TRUE"
         fi
   done
echo
echo "Setting $kelvins_set kelvins"
redshift -O $kelvins_set > /dev/null
exit
}

help ()
{
   echo
   echo "$0 : executes the script one time and sets the color temperature according to the time of the day"
   echo "$0 --show-me : shows, in 10   minutes increments, the evolution for the color display given the values set in the script"
   echo "$0 --plot : (gnu)plots a graph given the values set in the script, so the user can \"fine tune\" the script"
   echo "$0 some text : shows this help text. For a more compreensive explanation, see the text at the end of the script"
   echo
   exit
}

#########################################

# starts here

kelvins_max=3000

kelvins_min=1700

day_start=8

day_end=20

sunset_bias=20

temp=$(echo "$day_start*60" | bc -l)
day_start=$(echo "scale=0;$temp/1" | bc -l)

temp=$(echo "$day_end*60" | bc -l)
day_end=$(echo "scale=0; $temp/1" | bc -l)

temp_dir=$(dirname $(mktemp -u))
temp_dir+="/"

#########################################

! [[ $1 = "--plot" ]] || plot

! [[ $1 = "--show-me" ]] || show-me

[ -z $1 ] || help

current_time=$(echo "`date +%H`*60+`date +%M`" | bc -l)

if (( current_time > day_end )) || (( current_time < day_start ))
   then
      kelvins_set=$kelvins_min
   else
      temp=$(echo "$kelvins_max-($kelvins_max-$kelvins_min)*($current_time/$day_end)^$sunset_bias" | bc -l)
      kelvins_set=$(echo "scale=0; $temp/1" | bc -l)
fi

kelvins_temp=$(grep kelvins "$temp_dir.goodkelvins.current" 2>&1 | grep -v grep | awk '{print $1}')

case $kelvins_temp in
   $kelvins_set) ;;
   *) (redshift -O $kelvins_set > /dev/null;echo "$kelvins_set kelvins" > "$temp_dir.goodkelvins.current")
esac

exit 0

#########################################

: '

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

Customizable variables

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
$current_time=780   minutes
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
'

#!/bin/bash
# this script uses petcat and x64 from the Vice emulator
#cat seaport.txt | sed 's/#.*$//g' | tr '\n ' '\t'  | sed 's/\t[0-9]/\n\0/g' | sed 's/\t//g' > temp.bas
cpp seaport.txt | grep -v "^#" | grep -v "^$" | sed -z -e 's/\ *:\ *\n/:/g' | sed -e 's/:\t/:/g' > temp.bas
#petcat -w10 -o seaport.prg -l 1001 -- temp.bas
petcat -w2 -o seaport.prg -l 0801 -- temp.bas
#rm temp.bas
petcat seaport.prg > seaport.bas
c1541 -format seaport,01 d81 seaport.d81 -attach seaport.d81 -write seaport.prg game
#c1541 -format seaport,01 d81 seaport.d81 -attach seaport.d81 -write seaport.prg autoboot.c65
#/usr/bin/xmega65 -besure -forcerom -loadrom /home/mega65/Temp/MEGA65.ROM -fontrefresh -8 seaport.d81
x64 seaport.d81
#xemu-xmega65 -besure -go64 -prg seaport.prg
rm dump.mem

#!/bin/bash

# HK: xmin = 800000, xmax = 870000, ymin = 800000, ymax = 848000

P=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

for y in `seq 60 -1 0`
do
    Y=`echo $y \* 800 | bc`
    LAT=`echo $Y + 800000 | bc`
    for x in `seq 0 70`
    do
        X=`echo $x \* 1000 | bc`
        LNG=`echo $X + 800000 | bc`
        #echo $LAT $LNG
        ${P}/identify.sh ${LAT} ${LNG}
    done
done

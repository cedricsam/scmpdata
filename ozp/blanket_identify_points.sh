#!/bin/bash

# HK: xmin = 800000, xmax = 870000, ymin = 800000, ymax = 848000

P=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

for y in `seq 480 -1 0`
do
    Y=`echo $y \* 100 | bc`
    LAT=`echo $Y + 800000 | bc`
    for x in `seq 0 700`
    do
        X=`echo $x \* 100 | bc`
        LNG=`echo $X + 800000 | bc`
        #echo $LAT $LNG
        ${P}/identify_points.sh ${LAT} ${LNG}
    done
done

#!/bin/bash

D=`date -d"yesterday" +%Y%m%d`
DATE=`date -d"yesterday" +%Y-%_m-%_d | sed 's/ //g'`

cd hk

for typ in real cargo
do
    for ft in dep arr
    do
        FO="${D}_${typ}_${ft}.html"
        if [ ! -s ${FO} ]
        then
            wget -q "http://www.hongkongairport.com/flightinfo/eng/${typ}_${ft}info.do?fromDate=${DATE}" -O "${FO}"
        fi
    done
done

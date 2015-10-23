#!/bin/bash

D=`date -d"yesterday" +%Y%m%d`
DATE=`date -d"yesterday" +%Y/%m/%d | sed 's/\//%2F/g'`

cd tp

for ft in depart arrival
do
    FO="${D}_${ft}.html"
    curl -s "http://www.taoyuan-airport.com/english/Ajax_Flight_${ft}/" -d "StartDT=${DATE}&EndDT=${DATE}" -o ${FO}
done

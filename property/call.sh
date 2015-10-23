#!/bin/bash

DIR="all"
D=`date +%Y%m%d-%H%M`

./parse.py > all.${D}.csv
for i in `seq 1 10000`
do
    if [ ! -s ${DIR}/$i.html ]
    then
	break
    fi
    sed -n "/<table id='deal_table'/,/<\/table>/p" ${DIR}/$i.html > ${DIR}/$i.xml
    sed -i 's/color=\(green\|red\)/color="\1"/g' ${DIR}/$i.xml
    echo $i >> all.${D}.log
    ./parse.py ${DIR}/$i.xml >> all.${D}.csv 2>> all.${D}.log
done

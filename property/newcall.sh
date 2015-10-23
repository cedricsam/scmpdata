#!/bin/bash

# for version in Chinese and English

DIR_CH="all_ch"
DIR_EN="all_en"
D=`date +%Y%m%d-%H%M`

./parse.py > all.${D}.csv
for i in `seq 1 10000`
do
    if [ ! -s ${DIR_CH}/$i.html ] || [ ! -s ${DIR_EN}/$i.html ]
    then
	break
    fi
    sed -n "/<table id='deal_table'/,/<\/table>/p" ${DIR_CH}/$i.html > ${DIR_CH}/$i.xml
    sed -i 's/color=\(green\|red\)/color="\1"/g' ${DIR_CH}/$i.xml
    sed -i 's/&/\&amp;/g' ${DIR_CH}/$i.xml
    sed -n "/<table id='deal_table'/,/<\/table>/p" ${DIR_EN}/$i.html > ${DIR_EN}/$i.xml
    sed -i 's/color=\(green\|red\)/color="\1"/g' ${DIR_EN}/$i.xml
    sed -i 's/&/\&amp;/g' ${DIR_EN}/$i.xml
    echo $i >> all.${D}.log
    ./parse.py ${DIR_CH}/$i.xml >> all.${D}.csv 2>> all.${D}.log
    ./parse.py ${DIR_EN}/$i.xml >> all.${D}.csv 2>> all.${D}.log
done

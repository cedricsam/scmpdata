#!/bin/bash

D=`date +%Y%m%d`
if [ $# -ge 1 ]
then
    D=$1
fi

while read c
do
    cp ${c}.summary.${D}.csv ${c}.summary.${D}.clean.csv
done < courts.txt
while read i
do
    F=`echo "$i" | cut -d, -f1`
    DEL=`echo "$i" | cut -d, -f2- | sed 's/[\r\n]//g'`
    grep -v "${DEL}" ${F}.summary.${D}.clean.csv > ${F}.summary.${D}.clean.foo.csv 
    mv ${F}.summary.${D}.clean.foo.csv ${F}.summary.${D}.clean.csv
    #chmod 600 ${F}.summary.${D}.clean.csv
done < header_rows_to_delete.txt
./parse_daily_causes.py > all.summary.${D}.csv
while read c
do
    cat ${c}.summary.${D}.clean.csv >> all.summary.${D}.csv
done < courts.txt
#chmod 600 all.summary.${D}.csv

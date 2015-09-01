#!/bin/bash

COURTS="courts.txt"
if [ $# -ge 1 ] && [ -s $1 ]
then
    COURTS=$1
fi

D=`date +%Y%m%d`
# `find daily_causes -type f -size -8856c -size +8856c -name ${c}_\*.html | sort`
while read c
do
    for f in `ls -t daily_causes/${c}_*.html`
    do
        ./parse_daily_causes.py $f
    done > $c.summary.${D}.csv
    chmod 600 $c.summary.${D}.csv
done < $COURTS

./prepare_all_rows.sh ${D}

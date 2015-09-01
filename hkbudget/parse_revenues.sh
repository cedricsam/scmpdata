#!/bin/bash

Y=$1

types=""

if [ $Y ]
then
    echo -n "head_no,head_name"
    let y1=$Y-1
    let y2=$Y-2
    for t in $types
    do
        echo -n ",actual_${t}_${y2},original_${t}_${y1},revised_${t}_${y1},estimate_${t}_${Y}"
    done
    echo ""
fi

for i in `find www.budget.gov.hk/${Y} -name head*b.txt | sort -n`
do
    HEAD=`grep "Head" $i | head -1`
    HEAD_NB=`echo $HEAD | grep -oE "[0-9]+" | head -1`
    HEAD_NAME=`echo $HEAD | sed 's/Head //' | cut -d" " -f3- | sed 's/^\b//'`
    echo -n $HEAD_NB,\"$HEAD_NAME\"
    echo ""
done

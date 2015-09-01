#!/bin/bash

Y=$1

types="recurrent nonrecurrent operating plant_equipment_works subventions capital expenditure"

if [ $Y ]
then
    echo -n "head_no,head_name"
    let y1=$Y-1
    let y2=$Y-2
    for t in $types
    do
        echo -n ",actual_${t}_${y2},approved_${t}_${y1},revised_${t}_${y1},estimate_${t}_${Y}"
    done
    echo ""
fi

for i in `find www.budget.gov.hk/${Y} -name head*.txt | sort -n`
do
    HEAD=`grep "Head" $i | head -1`
    HEAD_NB=`echo $HEAD | grep -oE "[0-9]+" | head -1`
    HEAD_NAME=`echo $HEAD | sed 's/Head //' | cut -d" " -f3- | sed 's/^\b//'`
    TOTALS=`grep -E "Total, " $i`
    RECURRENT=`echo "$TOTALS" | grep ", Recurrent" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    NONRECURRENT=`echo "$TOTALS" | grep ", Non-Recurrent" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    OPERATING=`echo "$TOTALS" | grep ", Operating Account" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    PLANT=`echo "$TOTALS" | grep ", Plant, Equipment and Works" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    SUBS=`echo "$TOTALS" | grep ", Subventions" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    CAPITAL=`echo "$TOTALS" | grep ", Capital Account" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    EXPENDITURES=`echo "$TOTALS" | grep ", Expenditure" | sed 's/[,.#]//g' | sed 's/^[a-Z, -]\+//' | sed 's/ \+/,/g'`
    echo -n $HEAD_NB,\"$HEAD_NAME\"
    if [ "${RECURRENT}" ]; then echo -n ",${RECURRENT}"; else echo -n ",,,,"; fi;
    if [ "${NONRECURRENT}" ]; then echo -n ",${NONRECURRENT}"; else echo -n ",,,,"; fi;
    if [ "${OPERATING}" ]; then echo -n ",${OPERATING}"; else echo -n ",,,,"; fi;
    if [ "${PLANT}" ]; then echo -n ",${PLANT}"; else echo -n ",,,,"; fi;
    if [ "${SUBS}" ]; then echo -n ",${SUBS}"; else echo -n ",,,,"; fi;
    if [ "${CAPITAL}" ]; then echo -n ",${CAPITAL}"; else echo -n ",,,,"; fi;
    if [ "${EXPENDITURES}" ]; then echo -n ",${EXPENDITURES}"; else echo -n ",,,,"; fi;
    echo ""
done

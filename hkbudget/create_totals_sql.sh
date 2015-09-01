#!/bin/bash

Y=$1

types="recurrent nonrecurrent operating plant_equipment_works subventions capital expenditure"

echo -n "create table budget_expenditures_totals (head_no smallint primary key,head_name varchar(512)"

for Y in `seq 2005 2013`
do
    let y1=$Y-1
    let y2=$Y-2
    for t in $types
    do
        echo -n ",actual_${t}_${y2} int"
        echo -n ",approved_${t}_${y1} int"
        echo -n ",revised_${t}_${y1} int"
        echo -n ",estimate_${t}_${Y} int"
    done
done

echo ")"

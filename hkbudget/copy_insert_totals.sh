#!/bin/bash

Y=$1

types="recurrent nonrecurrent operating plant_equipment_works subventions capital expenditure"

for Y in `seq 2006 2013`
do
    F="${Y}.csv"
    csvextract.py 1 $F
done | sort -un > head_nos.tmp

while read head_no
do
    head_no=`echo $head_no | sed 's/\r//g'`
    SQL="INSERT INTO budget_expenditures_totals (head_no) VALUES ($head_no) ;"
    #echo $SQL
    #psql -h 127.0.0.1 -U scmp -c "${SQL}"
done < head_nos.tmp

for Y in `seq 2006 2013`
do
    F="${Y}.csv"
    HEAD=`head -1 ${F}`
    line_no=0
    while read line
    do
        if [ $line_no -le 0 ]
        then
            let line_no=$line_no+1
            continue
        fi
        SQL="UPDATE budget_expenditures_totals SET "
        i=3
        while true
        do
            head_no=`echo $line | csvextract.py 1 | sed 's/\r//g'`
            COL=`echo $HEAD | csvextract.py $i`
            VAL=`echo $line | csvextract.py $i`
            COL=`echo $COL | sed 's/\r//g'`
            VAL=`echo $VAL | sed 's/\r//g'`
            if [ `echo "$COL" | wc -c` -le 3 ]
            then
                break
            fi
            if [ $i -gt 3 ]
            then
                SQL="${SQL}, "
            fi
            if [ ${VAL} == '""' ]
            then
                VAL="NULL"
            fi
            SQL="${SQL} ${COL} = ${VAL}"
            let i=$i+1
        done
        SQL="${SQL} WHERE head_no = ${head_no}"
        echo $SQL
        psql -h 127.0.0.1 -U scmp -c "${SQL}"
        let line_no=$line_no+1
    done < $F
done

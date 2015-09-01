#!/bin/bash

if [ -z $1 ]
then
    exit
fi

FO="$1.paras.txt"

for i in `find -regex .*/www.budget.gov.hk/$1/.*/budget.*\.extract\.html? | sort -n`
do
    ./extract_paras.py $i
done #> $FO

#sed ':a;N;$!ba;s/\n\(([a-z])\)/ \1/g' $FO > $FO.tmp
#mv $FO.tmp $FO

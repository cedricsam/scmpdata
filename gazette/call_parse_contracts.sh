#!/bin/bash

D=`date +%Y%m%d`
FC="contracts.awarded.4.txt"

find text -type f -exec grep -lE "(NOTICE OF AWARD|CONTRACTS? AWARD)" {} \; > ${FC}

sort ${FC} > ${FC}.sorted
mv ${FC}.sorted ${FC}

FO="`pwd`/allcontracts.${D}.csv"
FL="`pwd`/allcontracts.csv"

./parse_contracts.py > ${FO}
while read i
do
    ./parse_contracts.py $i
done < ${FC} >> ${FO}

mv `readlink ${FL}` contracts
rm ${FL}
ln -s ${FO} ${FL}

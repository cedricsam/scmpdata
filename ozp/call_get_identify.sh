#!/bin/bash

D=`date +\%Y\%m\%d`
DIR="identify_${D}"
mkdir ${DIR} 2> /dev/null
cd ${DIR}
../blanket_identify.sh 2> /dev/null
../blanket_identify.sh 2> /dev/null
for i in `seq 5000`
do
    ../random_identify.sh
done

F="../ozp_${DIR}.csv"

for i in `ls`
do
    ../parse_identify.py $i
done > ../ozp_${DIR}.csv

while read line
do
    echo $line | sed 's/POLYGON/SRID=2326;POLYGON/' | psql -h 127.0.0.1 -U scmp -c "\\copy ozp_identify from stdin csv"
done < ${F}

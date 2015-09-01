#!/bin/bash

DIR=daily_causes

cd ${DIR}

courts=( crc lt smt oat etnmag kcmag ktmag twmag stmag flmag tmmag allmag cfa cacfi hcmc mcl lands dc dcmc fmc )

if [ $# -lt 1 ]
then
    N=1
else
    N=$1
fi
D=`date -d"${N} days" +%d%m%Y`
DO=`date -d"${N} days" +%Y%m%d`

for C in ${courts[@]}
do
    #echo $C
    curl -s "http://www.judiciary.gov.hk/en/crt_lists/lists/${D}/${C}.html" -o ${C}_${DO}.html
done

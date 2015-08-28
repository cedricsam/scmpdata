#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
D=`date +%Y%m%d`
DR="archive/${D}"
mkdir -p ${DR}
cd ${DR}
S1=`seq 16`
S2="NE SE SW NW"
S3="A B C D"
S4="C CR DT F FR ND NS R"

for s1 in $S1
do
    for s2 in $S2
    do
        for s3 in $S3
        do
            for s4 in $S4
            do
                s="$s1$s2-$s3/$s4"
                FO="`echo "$s" | sed 's/[\/ ]\+/_/'`"
                if [ -s "${FO}.json" ]
                then
                    continue
                fi
                #echo $s
                ${DIR}/scrape_slopes.sh "${s}"
                grep -Eo '"SLOPE_NO":"[0-9][^"]+"' "${FO}.json" | cut -d\" -f4 | sed 's/\\\//\//' > "${FO}.txt"
                N=`wc -l "${FO}.txt" | cut -d" " -f1`
                if [ ! -s "${FO}.json" ] || [ $N -le 0 ]
                then
                    rm ${FO}.json ${FO}.txt
                fi
            done
        done
    done
done

LOGFILE="morethan1000.log"
for i in `ls -v *.txt`
do
    N=`wc -l $i | cut -d" " -f1`
    if [ $N -ge 1000 ]
    then
        echo $i | sed 's/_/\//' | sed 's/\.txt$//'
    fi
done > ${LOGFILE}

while read s
do
    for i in `seq 9`
    do
        ss="$s$i"
        FO="`echo "${ss}" | sed 's/[\/ ]\+/_/'`"
        if [ -s "${FO}.json" ]
        then
            continue
        fi
        ${DIR}/scrape_slopes.sh "${ss}"
        grep -Eo '"SLOPE_NO":"[0-9][^"]+"' "${FO}.json" | cut -d\" -f4 | sed 's/\\\//\//' > "${FO}.txt"
        N=`wc -l "${FO}.txt" | cut -d" " -f1`
        if [ ! -s "${FO}.json" ] || [ $N -le 0 ]
        then
            rm ${FO}.json ${FO}.txt
        fi
    done
done < ${LOGFILE}

cat *.txt | sort -u > ${DIR}/slopes.txt

rm ${LOGFILE}

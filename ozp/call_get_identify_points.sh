#!/bin/bash

D=`date +\%Y\%m\%d`
DIR="identify_${D}"
FP="../points_${D}.csv"
mkdir ${DIR} 2> /dev/null
cd ${DIR}

# Center point
SQL="select objectid, st_y(p), st_x(p) from (select objectid, ST_PointOnSurface(geom) p from ozp_identify where shape = 'Polygon') foo"
psql -h 127.0.0.1 -U scmp -c "\\copy (${SQL}) to stdout csv" | shuf > ${FP}

# Random point
SQL="select objectid, st_y(p), st_x(p) from (select objectid, RandomPoint(geom) p from ozp_identify where shape = 'Polygon') foo"
for i in `seq 10`
do
    psql -h 127.0.0.1 -U scmp -c "\\copy (${SQL}) to stdout csv" | shuf >> ${FP}
done

while read i
do
    lat=`echo $i | cut -d, -f2`
    lng=`echo $i | cut -d, -f3`
    ../identify_points.sh $lat $lng
done < ${FP}

FO="../ozp_${DIR}.csv"

for i in `ls`
do
    ../parse_identify.py $i
done > ${FO}

while read line
do
    echo $line | sed 's/POLYGON/SRID=2326;POLYGON/' | psql -h 127.0.0.1 -U scmp -c "\\copy ozp_identify from stdin csv"
done < ${FO}

#!/bin/bash
DIR="districts"

while read dist
do
    ID=`echo "$dist" | cut -d, -f1`
    DIST=`echo "$dist" | cut -d, -f2-`
    date
    echo "Doing district: ${ID} ${DIST}"
    for i in `seq 2000`
    do
	FO="${DIR}/${ID}_${i}.html"
	if [ -s "${FO}" ]
	then
	    continue
	fi
	curl -s "http://data.28hse.com/en/datarecord41.html" --data "plxf=getlatest_land&plxa[]=${ID}&plxa[]=${i}&plxa[]=30&plxa[]=0" -o "${FO}";
	if [ `expr $i % 100` -eq 0 ]
	then
	    date
	    echo $i
	fi
	if [ ! -s "${FO}" ] || [ `grep "No data available yet" ${FO} | wc -l | cut -d" " -f1` -ge 1 ] || [ `grep "Some error on the page" ${FO} | wc -l | cut -d" " -f1` -ge 1 ]
	then
	    rm ${FO}
	    echo "Max reached: ${i}"
	    break
	fi
    done
done < districts.csv

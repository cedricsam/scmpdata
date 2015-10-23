#!/bin/bash

D=`date -d"yesterday" +%Y%m%d`
DATE=`date -d"yesterday" +%Y/%m/%d`

TRIES=10

cd bk

POSTDATA="start_time=00%3A00&end_time=23%3A59&date=${DATE}"

for i in `seq $TRIES`
do
    curl -s "http://suvarnabhumiairport.com/en/4-passenger-departures" -d "${POSTDATA}" -o ${D}_departures.html
    curl -s "http://suvarnabhumiairport.com/en/3-passenger-arrivals" -d "${POSTDATA}" -o ${D}_arrivals.html
    if [ `stat -c %s "${D}_departures.html"` -gt 10000 ] && [ `stat -c %s "${D}_arrivals.html"` -gt 10000 ]
    then
        break
    fi
    sleep 60
done

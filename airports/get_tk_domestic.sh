#!/bin/bash

D=`date +%Y%m%d`
DATE=`date +%Y/%m/%d`

TRIES=90
THRESH=12000

cd tk

for i in `seq $TRIES`
do
    if [ `date +%H%M` -lt 2200 ]
    then
        break
    fi
    curl -s "http://jatns.tokyo-airport-bldg.co.jp/en/flight/domestic/todays_flight/all_flights_list/departure.html" -o ${D}_domestic_departures.html.tmp
    curl -s "http://jatns.tokyo-airport-bldg.co.jp/en/flight/domestic/todays_flight/all_flights_list/arrival.html" -o ${D}_domestic_arrivals.html.tmp
    if [ `stat -c %s "${D}_domestic_departures.html.tmp"` -lt ${THRESH} ] && [ `stat -c %s "${D}_domestic_arrivals.html.tmp"` -lt ${THRESH} ] && [ -s ${D}_domestic_departures.html ] && [ -s ${D}_domestic_arrivals.html ]
    then
        break
    fi
    if [ `stat -c %s "${D}_domestic_departures.html.tmp"` -ge ${THRESH} ]
    then
        mv ${D}_domestic_departures.html.tmp ${D}_domestic_departures.html
    fi
    if [ `stat -c %s "${D}_domestic_arrivals.html.tmp"` -ge ${THRESH} ]
    then
        mv ${D}_domestic_arrivals.html.tmp ${D}_domestic_arrivals.html
    fi
    sleep 60
done
rm ${D}_domestic_departures.html.tmp ${D}_domestic_arrivals.html.tmp 2> /dev/null

#!/bin/bash

D=`date -d"yesterday" +%Y%m%d`
DATE=`date -d"yesterday" +%Y/%m/%d`

cd tk

curl -s "http://www.haneda-airport.jp/inter/flight/searchFlightInfo" -d "ymd=2&da=D&langId=en" -o ${D}_international_departures.html
curl -s "http://www.haneda-airport.jp/inter/flight/searchFlightInfo" -d "ymd=2&da=A&langId=en" -o ${D}_international_arrivals.html

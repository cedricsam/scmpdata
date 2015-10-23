#!/bin/bash

D=`date -d"yesterday" +%Y%m%d`
DATE=`date -d"yesterday" +%Y/%m/%d | sed 's/\//%2F/g'`

HOST="http://202.136.9.40/"

cd sg

curl -s "${HOST}webfids/fidsp/get_flightinfo_cache.php?d=-1&type=pa&lang=en" -o "${D}_arrivals.gz"
gunzip "${D}_arrivals.gz"
mv "${D}_arrivals" "${D}_arrivals.js"
curl -s "${HOST}webfids/fidsp/get_flightinfo_cache.php?d=-1&type=pd&lang=en" -o "${D}_departures.gz"
gunzip "${D}_departures.gz"
mv "${D}_departures" "${D}_departures.js"

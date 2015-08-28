#!/bin/bash

if [ $# -lt 1 ]
then
    exit
fi

HOSTNUM=2
URLBASE="http://www${HOSTNUM}.slope.landsd.gov.hk"
DT=`date +%s`

FO="`echo "$1" | sed 's/[\/ ]\+/_/'`"
SLONO="$1"
SLONO="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "${SLONO}")"
#11SW-C%2FR99

URL1="${URLBASE}/smris/getSlopeBySlopeNo?sn=${SLONO}"
curl -s "${URL1}" --compressed -o "${FO}.slopeinfo.json"

URL2="${URLBASE}/smris/getSlopeTechInfo?sn=${SLONO}"
curl -s "${URL2}" --compressed -o "${FO}.techinfo.json"

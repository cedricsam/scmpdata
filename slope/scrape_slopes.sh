#!/bin/bash

if [ $# -lt 1 ]
then
    exit
fi

HOSTNUM=1
URLBASE="http://www${HOSTNUM}.slope.landsd.gov.hk"
DT=`date +%s`

FO="`echo "$1" | sed 's/[\/ ]\+/_/'`.json"
SLONO="'$1%'"
SLONO="$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "${SLONO}")"
#11SW-C%2FR99

QS="/arcgis/rest/services/rIA-SMRIS/rsm_dynamic__d00/MapServer/0/query?f=json&where=(SLOPE_NO)+like+((${SLONO}))&returnGeometry=true&spatialRel=esriSpatialRelIntersects&outSR=2326&outFields=SLOPE_NO%2CSUB_DIV_NO&_=${DT}"

URL="${URLBASE}${QS}"
#echo "${URL}"
curl -s "${URL}" --compressed -o "${FO}"

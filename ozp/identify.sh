#!/bin/bash

# HK: xmin = 800000, xmax = 870000, ymin = 800000, ymax = 848000

if [ $# -le 1 ]
then
    exit
fi
re='^[0-9]+\.?[0-9]*$'
if ! [[ $1 =~ $re ]] ; then exit; fi
if ! [[ $2 =~ $re ]] ; then exit; fi
LAT=$1
LNG=$2
LATMIN=`echo "$LAT - 600" | bc`
LATMAX=`echo "$LAT + 600" | bc`
LNGMIN=`echo "$LNG - 800" | bc`
LNGMAX=`echo "$LNG + 800" | bc`

LAYERS="1,0,3,11,4,10"
if [ $# -gt 2 ]
then
    LAYERS=$3
fi

SERVER="www1"

#UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.39 Safari/537.36"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.65 Safari/537.36"
#COOKIE="fwd30axa5zoy2prbj1gx5ruk"
SESSION_ID="wja5ajmc5jtycuuobfvpig0n"

#BASEURL="http://${SERVER}.ozp.tpb.gov.hk/arcgis/rest/services/OZP_PLAN/MapServer/identify"
BASEURL="http://${SERVER}.ozp.tpb.gov.hk/gos/proxy.ashx?http://${SERVER}.ozp.tpb.gov.hk/arcgis/rest/services/OZP_PLAN/MapServer/identify"
REFERER="http://${SERVER}.ozp.tpb.gov.hk/gos/default.aspx?"

#geometry="%7B%22x%22%3A${LNG}%2C%22y%22%3A${LAT}%2C%22spatialReference%22%3A%7B%22wkid%22%3A102140%2C%22latestWkid%22%3A2326%7D%7D"
#mapExtent="mapExtent={\"xmin\":800000,\"ymin\":800000,\"xmax\":870000,\"ymax\":848000,\"spatialReference\":{\"wkid\":102140,\"latestWkid\":2326}}"
mapExtent="%7B%22xmin%22%3A${LNGMIN}%2C%22ymin%22%3A${LATMIN}%2C%22xmax%22%3A${LNGMAX}%2C%22ymax%22%3A${LATMAX}%22spatialReference%22%3A%7B%22wkid%22%3A102140%2C%22latestWkid%22%3A2326%7D%7D"
geometry="${mapExtent}"
geoType="esriGeometryEnvelope"

URL="${BASEURL}?f=json&tolerance=1&returnGeometry=true&imageDisplay=810,610,96&geometryType=${geoType}&sr=102140&layers=visible:${LAYERS}&geometry=${geometry}&mapExtent=${mapExtent}"

OBJID_FN=`printf %07d "${OBJID}"`

FO="${LAT},${LNG}.json"

if [ -s ${FO} ]
then
    exit
fi

echo $LAT $LNG

#echo $URL

curl -s "${URL}" -b "ASP.NET_SessionId=${SESSION_ID}" -A "${UA}" -e "${REFERER}" -o "${FO}"

if [ `stat -c %s "${FO}"` -lt 1000 ]
then
    rm "${FO}"
fi

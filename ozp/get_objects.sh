#!/bin/bash

if [ $# -le 0 ]
then
    exit
fi
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then exit; fi
OBJID=$1

UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.65 Safari/537.36"
SESSION_ID="405h3lq15j5fmdautjvb5yex"
TOKEN="KljlNvdnXtfekrgcNuxmfQ%3D%3D"
POSTDATA="lang=0&token=${TOKEN}&OBJECTID=${OBJID}"
SERVER="www1"
REFERER="http://www1.ozp.tpb.gov.hk/gos/default.aspx?"

OBJID_FN=`printf %07d "${OBJID}"`

FO="${OBJID_FN}.json"

if [ -s ${FO} ]
then
    exit
fi

echo $OBJID

#curl -s 'http://${SERVER}.ozp.tpb.gov.hk/PlanDAPI/Detail/OZPZone' -b "ASP.NET_SessionId=${SESSION_ID}" -A "${UA}" -d "${POSTDATA}" -o "${FO}"
curl -s "http://${SERVER}.ozp.tpb.gov.hk/gos/ws_proxy.ashx?url=Detail/OZPZone" -b "ASP.NET_SessionId=${SESSION_ID}" -A "${UA}" -d "${POSTDATA}" -o "${FO}"

if [ -s ${FO} ] && [ `cat ${FO} | wc -c` -le 40 ]
then
    rm ${FO}
fi

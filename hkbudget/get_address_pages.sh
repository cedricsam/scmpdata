#!/bin/bash

if [ $# -lt 1 ]
then
    exit
fi

LINKS="../links.txt"
if [ $# -gt 1 ]
then
    LINKS=$2
fi

y=$1
echo $y
BASE=`grep -E "^${y}," ${LINKS} | cut -d, -f2`
PAGE="p1.html"
if [ $y -le 2006 ]
then
    PAGE="p1.htm"
fi
while true
do
    URL=${BASE}${PAGE}
    echo ${URL}
    wget "$URL" -O ${y}-${PAGE}
    if [ ! -s "${y}-${PAGE}" ]
    then
        continue
    fi
    NEXTLINK=`grep -oEi "<a href=\"p[0-9]+[a-z]?.html?\">(Next|下頁)</a>" "${y}-${PAGE}"`
    if [ -z "${NEXTLINK}" ]
    then
        break
    fi
    PAGE=`echo "${NEXTLINK}" | cut -d\" -f2`
done

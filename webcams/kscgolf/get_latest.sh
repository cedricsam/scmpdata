#!/bin/bash

FI="640x480.jpg"
IMGURL="http://www.kscgolf.org.hk/images/${FI}"
PRE="kscgolf"

wget -q "${IMGURL}"

D=`stat --printf=%Y 640x480.jpg | cut -d. -f1`
DD=`date -d@${D} +%Y%m%d-%H%M%S`

FO="${PRE}_${DD}.jpg"

if [ -s ${PRE} ]
then
    rm ${FI}
else
    mv ${FI} ${FO}
fi

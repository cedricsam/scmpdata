#!/bin/bash

MAXTRIES=20
TRIES=0
SLEEPTIME=60

toc_pages=""
if [ $# -ge 1 ]
then
    toc_pages=$1
fi

#curl -s "http://www.gld.gov.hk/egazette/english/gazette/disclaimer.php" -o /dev/null
#curl -s "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" -o /dev/null

while true
do
    let TRIES=${TRIES}+1
    OUT=`./gazettescraper.sh ${toc_pages}`
    LASTROW=`echo "${OUT}" | tail -1`
    if [ "${LASTROW}" == "SUCCESS" ]
    then
        break
    else
        echo "${OUT}"
    fi
    echo "Tried ${TRIES} times"
    sleep ${SLEEPTIME}
    if [ ${TRIES} -ge ${MAXTRIES} ]
    then
        echo "UNSUCCESSFUL"
        break
    fi
done

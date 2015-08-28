#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

let MAX_TRIES=20
tries=0
SLEEPSECS=5

while read i
do
    #COOKIE=`curl -I "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "Set-Cookie: ([^;]+);" | sed 's/Set-Cookie: //g' | sed ':a;N;$!ba;s/\n/ /g'`
    vol=`echo $i | grep -oE "&vol=([0-9]+)" | grep -oE "[0-9]+" `
    no=`echo $i | grep -oE "&no=([0-9]+)" | grep -oE "[0-9]+" `
    extra=`echo $i | grep -oE "extra=([0-9]+)" | grep -oE "[0-9]+" `
    Y=`echo $i | grep -oE "&year=([0-9]{4})" | grep -oE "[0-9]{4}" `
    m=`echo $i | grep -oE "&month=([0-9]{2})" | grep -oE "[0-9]{2}" `
    d=`echo $i | grep -oE "&day=([0-9]{2})" | grep -oE "[0-9]{2}" `
    gn=`echo $i | grep -oE "&gn=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
    #typ=`echo $i | grep -oE "&type=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
    FO="ls6-${Y}-${m}-${d}_${vol}-${no}_${extra}"
    URL=`echo "http://www.gld.gov.hk/egazette/english/gazette/${i}" `
    #echo $URL
    while true
    do
        curl -s -b "${COOKIE}" "${URL}" -o "${FO}.html"
        let tries=${tries}+1
        if [ -s "${FO}" ]
        then
            break
        else
            #echo "LOG: file empty: ${FO} (try #${tries})"
            if [ ${tries} -gt ${MAX_TRIES} ]
            then
                #echo "LOG: Tried maximum times (${MAX_TRIES}) on ${FO}. Go to next file..."
                break
            fi
            sleep 2
        fi
    done
    tries=0
done < $1

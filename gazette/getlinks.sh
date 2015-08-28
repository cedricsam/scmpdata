#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

secondpass=0
if [ $# -gt 1 ]
then
    case $2 in
    2)
        secondpass=1 ;;
    esac
fi

let MAX_TRIES=20
tries=0
SLEEPSECS=5

while read line
do
    if [ ${secondpass} -eq 1 ]
    then
        ref=`echo ${line} | cut -d\| -f2`
        i=`echo ${line} | cut -d\| -f1`
    else
        i=${line}
    fi
    LS6=0
    PDF=0
    VOL=0
    if [ `echo $i | grep -oE "^pdf.php" | wc -m` -ge 1 ]
    then
        PDF=1
    fi
    if [ `echo $i | grep -oE "^volume.php" | wc -m` -ge 1 ]
    then
        VOL=1
    fi
    if [ `echo $i | grep -oE "^ls6.php" | wc -m` -ge 1 ]
    then
        LS6=1
    fi
    #COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "Set-Cookie: ([^;]+);" | sed 's/Set-Cookie: //g' | sed ':a;N;$!ba;s/\n/ /g'`
    sleep 0.2
    vol=`echo $i | grep -oE "&vol=([0-9]+)" | grep -oE "[0-9]+" `
    no=`echo $i | grep -oE "&no=([0-9]+)" | grep -oE "[0-9]+" `
    extra=`echo $i | grep -oE "extra=([0-9]+)" | grep -oE "[0-9]+" `
    Y=`echo $i | grep -oE "&year=([0-9]{4})" | grep -oE "[0-9]{4}" `
    m=`echo $i | grep -oE "&month=([0-9]{2})" | grep -oE "[0-9]{2}" `
    d=`echo $i | grep -oE "&day=([0-9]{2})" | grep -oE "[0-9]{2}" `
    gn=`echo $i | grep -oE "&gn=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
    URL="http://www.gld.gov.hk/egazette/english/gazette/"
    if [ ${LS6} -eq 1 ]
    then
        FO="ls6-${Y}-${m}-${d}_${vol}-${no}_${extra}.html"
        URL=`echo "${URL}${i}"`
    elif [ ${PDF} -eq 1 ]
    then
        typ=`echo $i | grep -oE "&type=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
        id=`echo $i | grep -oE "&id=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
        FO="pdf-${Y}-${m}-${d}_${vol}-${no}_${extra}_${typ}_${id}.html"
        URL=`echo "${URL}${i}"`
    elif [ ${VOL} -eq 1 ]
    then
        typ=`echo $i | grep -oE "&type=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
        id=`echo $i | grep -oE "&id=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
        FO="volume-${Y}-${m}-${d}_${vol}-${no}_${extra}_${typ}_${id}.html"
        URL=`echo "${URL}${i}"`
    else
        typ=`echo $i | grep -oE "&type=([0-9]{1,})" | grep -oE "[0-9]{1,}" `
        FO="${Y}-${m}-${d}_${vol}-${no}_${extra}_${typ}.html"
        URL=`echo "${URL}volume.php${i}"`
    fi
    while true
    do
        curl -s -b "${COOKIE}" "${URL}" -o "${FO}"
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
    if [ -s ${FO} ]
    then
        if [ ${secondpass} -eq 1 ]
        then
            echo "$ref|$FO"
        else
            echo $FO
        fi
    else
        rm ${FO} 2> /dev/null
    fi
done < $1

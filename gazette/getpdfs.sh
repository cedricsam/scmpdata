#!/bin/bash

cd pdfs
FI="../$1"
SP="../`echo $1 | sed 's/\([^\/]\+\)$/to2ndpass.\1/'`"

if [ $# -lt 1 ]
then
    echo "Missing file"
    exit
fi

if [ ! -s ${FI} ]
then
    exit
fi

let MAX_TRIES=20
tries=0
SLEEPSECS=5
BASEURL="http://www.gld.gov.hk/egazette/english/gazette"
DISCLAIMER="${BASEURL}/disclaimer.php"
TOC="${BASEURL}/toc.php"
COOKIE=""
COUNTER=0
TRIES=60
PHPSESSID=""
TSCOOKIE=""
SICOOKIE=""

function renew_cookies {
    # Get PHP SESSION ID
    while [ `echo $PHPSESSID | wc -c` -lt 37 ] && [ $COUNTER -lt ${TRIES} ]
    do
        HDRS=`curl -sI "${TOC}"`
        PHPSESSID=`echo "${HDRS}" | grep -Eo "PHPSESSID=(\w+)"`
        TSCOOKIE=`echo "${HDRS}" | grep -Eo "Set-Cookie: (TS[^;]+)" | cut -d: -f2-`
        SICOOKIE=`echo "${HDRS}" | grep -Eo "Set-Cookie: (SI[^;]+)" | cut -d: -f2-`
        sleep .5
        let COUNTER=$COUNTER+1
    done

    if [ `echo $PHPSESSID | wc -c` -lt 37 ]
    then
        exit
    fi
    COUNTER=0
    URLTOUSE="${DISCLAIMER}"
    while [ `echo $SICOOKIE | wc -c` -lt 10 ] && [ $COUNTER -lt ${TRIES} ]
    do
        HDRS=`curl -sIb "${PHPSESSID};" "${URLTOUSE}"`
        if [ `echo $TSCOOKIE | wc -c` -lt 10 ]
        then
            TSCOOKIE=`echo "${HDRS}" | grep -Eo "Set-Cookie: (TS[^;]+)" | cut -d: -f2-`
        fi
        if [ `echo $SICOOKIE | wc -c` -lt 10 ]
        then
            SICOOKIE=`echo "${HDRS}" | grep -Eo "Set-Cookie: (SI[^;]+)" | cut -d: -f2-`
        else
            URLTOUSE="${TOC}?Submit=accept"
        fi
        sleep .5
        let COUNTER=$COUNTER+1
    done
    URLTOUSE="${TOC}?Submit=accept"

    if [ `echo $SICOOKIE | wc -c` -lt 10 ]
    then
        exit
    fi

    COOKIE="${PHPSESSID};${SICOOKIE};${TSCOOKIE}"
    COOKIE=`echo ${COOKIE} | sed 's/; *$//'`
    curl -sIb "${COOKIE}" "${URLTOUSE}" > /dev/null
    >&2 echo "$COOKIE"
}
renew_cookies

secondpass=0
if [ $# -gt 1 ]
then
    case $2 in
    2)
        secondpass=1 ;;
    esac
fi

while read i
do
    if [ ${secondpass} -eq 1 ]
    then
        ref=`echo ${i} | cut -d\| -f2`
        i=`echo ${i} | cut -d\| -f1`
    fi
    PAGE=`echo "${i}" | cut -d\| -f1`
    URL=`echo "${BASEURL}/${PAGE}"`
    HDRS=`curl -s -I -b "${COOKIE}" "${URL}"`
    LOC=`echo "${HDRS}" | grep -Eoi "Location: (.*)" | cut -d: -f2 | sed 's/[ ]\{1,\}..\/..\/..\/egazette\///g' | sed 's/[ \t\r\n]\+$//g'`
    if [ `echo ${LOC} | wc -c` -lt 10 ] && [ `echo "${HDRS}" | grep refresh | grep disclaimer.php | wc -l` -gt 0 ] # When it sends you to the disclaimer
    then
        renew_cookies
        LOC=`curl -s -I -b "${COOKIE}" "${URL}" | grep -Eoi "Location: (.*)" | cut -d: -f2 | sed 's/[ ]\{1,\}..\/..\/..\/egazette\///g' | sed 's/[ \t\r\n]\+$//g'`
        if [ `echo ${LOC} | wc -c` -lt 10 ]
        then
            exit
        fi
    elif [ `echo ${LOC} | wc -c` -lt 10 ] # Missing location, but does not send you to disclaimer (must be another page)
    then
        curl -sb "${COOKIE}" "${URL}" | sed 's/\&amp;/\&/g' | grep -oE "`echo ${PAGE} | sed 's/pdf.php//' | sed 's/?/\\?/g'`[^\"]+" | sed "s/$/|`echo "${PAGE}" | sed 's/\&/\\\&/g'`/" | sed 's/^/pdf.php?/g' | sort -u >> $SP
        continue
    fi
    URLPDF=`echo "http://www.gld.gov.hk/egazette/$LOC"`
    >&2 echo ${URL} ${URLPDF}
    FO=`echo $LOC | sed 's/^pdf\///' | sed 's/\//_/g'`
    if [ ! -s ${FO} ]
    then
        while true
        do
            curl -s -b "${COOKIE}" "${URLPDF}" -o ${FO}
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
        pdftotext -layout ${FO} "../text/`echo ${FO} | sed 's/\.pdf/.txt/g'`"
    fi
    if [ -s ${FO} ]
    then
        i=`echo ${i} | sed 's/[\r\n]\+//g'`
        if [ ${secondpass} -eq 1 ]
        then
            i="$ref|$i"
        fi
        echo ${i},${FO},`md5sum ${FO} | cut -d" " -f1`
    else
        echo "${i},,"
    fi
done < $FI

cd ..


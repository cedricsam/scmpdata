#!/bin/bash

PAGES=200

D=`date -d"yesterday" +%Y%m%d`
BASEURL="http://www.shairport.com/ajax/flights/search.aspx?action=getData"
POSTDATA="pageSize=1000&=1&language=en&timeDays=-1"

cd sh

for ft in `seq 4`
do
    MD5LAST=""
    for i in `seq ${PAGES}`
    do
        I=`printf "%02d" "${i}"`
        FO="${D}_${ft}_${I}.json"
        curl -s "${BASEURL}" -d "${POSTDATA}&direction=${ft}&currentPage=${i}" -o "${FO}"
        MD5=`md5sum ${FO} | cut -d" " -f1`
        if [ `stat -c %s "${FO}"` -le 12 ]
        then
            rm ${FO}
            break
        fi
        if [ "${MD5LAST}" == "${MD5}" ]
        then
            rm ${FO}
            if [ ${i} -gt 2 ] # remove before last, if same as first page
            then
                let BEF=$i-1
                F0="${D}_${ft}_01.html"
                FB="${D}_${ft}_`printf "%02d" "${BEF}"`.json"
                if [ "`md5sum ${F0} | cut -d' ' -f1`" == "`md5sum ${FB} | cut -d' ' -f1`" ]
                then
                    rm ${FB}
                fi
            fi
            break
        fi
        MD5LAST="${MD5}"
    done
done

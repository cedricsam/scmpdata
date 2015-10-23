#!/bin/bash

PAGES=200

D=`date -d"yesterday" +%Y%m%d`
BASEURL="http://en.bcia.com.cn/business/flightInfo.jspx?action=list&language=en&pageInfo.pageSize=1000"

cd bj

for ft in `seq 0 3`
do
    MD5LAST=""
    for i in `seq ${PAGES}`
    do
        I=`printf "%02d" "${i}"`
        FO="${D}_${ft}_${I}.html"
        curl -s "${BASEURL}&flightType=${ft}&pageInfo.pageIndex=${i}&day=0" -o "${FO}"
        MD5=`md5sum ${FO} | cut -d" " -f1`
        if [ "${MD5LAST}" == "${MD5}" ]
        then
            rm ${FO}
            if [ ${i} -gt 2 ] # remove before last, if same as first page
            then
                let BEF=$i-1
                F0="${D}_${ft}_01.html"
                FB="${D}_${ft}_`printf "%02d" "${BEF}"`.html"
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

#!/bin/bash

PAGES=20

D=`date -d"yesterday" +%Y%m%d`
DATE=`date -d"yesterday" +%Y-%m-%d`
BASEURL="http://en.bcia.com.cn/business/flightInfo.jspx?action=list&language=en&pageInfo.pageSize=1000"
BASEURL="http://www.gbiac.net/en/hbxx/flightquery?p_p_id=flightindex_WAR_flightqueryportlet&flight_date=-1&_flightindex_WAR_flightqueryportlet_delta=200"

cd gz

for ft in `seq 4 5`
do
    SUMLAST=""
    for i in `seq ${PAGES}`
    do
        I=`printf "%02d" "${i}"`
        FO="${D}_${ft}_${I}.html"
        curl -s "${BASEURL}&begin_flight_date=${DATE}+00%3A00%3A00&end_flight_date=${DATE}+23%3A59%3A59&flight_route=${ft}&cur=${i}" -o "${FO}"
        SUM=`stat -c %s ${FO} | cut -d" " -f1`
        if [ `stat -c %s "${FO}"` -le 36000 ]
        then
            rm ${FO}
            break
        fi
        if [ "${SUMLAST}" == "${SUM}" ]
        then
            rm ${FO}
            if [ ${i} -gt 2 ] # remove before last, if same as first page
            then
                let BEF=$i-1
                F0="${D}_${ft}_01.html"
                FB="${D}_${ft}_`printf "%02d" "${BEF}"`.html"
                if [ "`stat -c %s ${F0} | cut -d' ' -f1`" == "`md5sum ${FB} | cut -d' ' -f1`" ]
                then
                    rm ${FB}
                fi
            fi
            break
        fi
        SUMLAST="${SUM}"
    done
done

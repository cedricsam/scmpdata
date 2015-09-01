#!/bin/bash

DIR="http://www.bd.gov.hk/english/documents/statistic/"
SUBDESTDIR="summaries"
FI="index_statistics_`date +%Y%m%d-%H%M`.html"
curl -s "http://www.bd.gov.hk/english/documents/index_statistics.html" -o ${FI}
#DMY=`grep '<td valign="top" align="center" bgcolor="#FFE8DD" width="80"><font size="2" face="Arial">' ${FI} | cut -d">" -f3 | cut -d"<" -f1 | head -1`
DMY=`grep '<td class="hCenter">' ${FI} | cut -d">" -f2 | cut -d"<" -f1 | tail -4 | head -1`
M=`echo ${DMY} | cut -d/ -f1`
Y=`echo ${DMY} | cut -d/ -f2`
#Y=`date +%Y`
#M=`date +%m`
if [ `echo ${M} | wc -m` -le 2 ]
then
    M="0$M"
fi
echo $Y$M

for i in 11 12 13 14 15 16 17 21 22 23 24 25 31 41 51 52 53 54 55 56
do
    F="Md${i}.xls"
    F0="Md${Y}${M}_${i}.xls"
    if [ ! -s ${SUBDESTDIR}/${F0} ]
    then
        echo ${i}
        curl -s "${DIR}${F}" -o ${SUBDESTDIR}/${F0}
    else
        ls -l ${SUBDESTDIR}/${F0}
    fi
done

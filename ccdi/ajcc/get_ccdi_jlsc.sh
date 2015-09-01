#!/bin/bash

MINROWS=0 # To prevent accidental deletions
FTID="1pTfu9MsLgrWxfSy_jLowe3-0K0lxxnGTdlteszdc"
FILEPRE="ccdi_jlsc"
FTMASTER="${FILEPRE}.ftmaster"
URLBASE="http://www.ccdi.gov.cn/jlsc/"

cd indexes

rm index*.html 2> /dev/null

# get the first page
wget -q ${URLBASE}/index.html
if [ ! -s index.html ] # exit if no page
then
    exit
fi
NBPAGES=`grep createPageHTML index.html | cut -d\( -f2 | cut -d, -f1`
let INDEXPAGES=$NBPAGES-1
for i in `seq $INDEXPAGES`
do
    #echo $i
    wget -q ${URLBASE}/index_${i}.html
done
cd - > /dev/null

# download all pages
cd pages
rm *.html
grep -hoE '<a href="./2[^"]+' ../indexes/index*.html | cut -d. -f2- > pages.txt
while read i
do
    wget -q ${URLBASE}${i}
done < pages.txt
cd - > /dev/null

# get a copy from Fusion Tables
${HOME}/bin/ft2csv.py "${FTID}" > ${FTMASTER}.full.csv
${HOME}/bin/csvextract.py 1-4 ${FTMASTER}.full.csv > ${FTMASTER}.partial.csv
if [ ! -s ${FTMASTER}.partial.csv ] || [ `wc -l ${FTMASTER}.partial.csv | cut -d" " -f1` -lt ${MINROWS} ] # exit if master file is below the safe minimum size length
then
    exit
fi

# parse, keep new entries and put in database
D=`date +%Y%m%d-%H%M`
FO="${FILEPRE}.${D}.csv"
#./parse_ccdi_jlsc_pages.py > ${FO}
for i in `find pages -name t*.html -type f | sort -r`
do
    R="`./parse_ccdi_jlsc_pages.py ${i}`"
    RPART=`echo "${R}" | ${HOME}/bin/csvextract.py 1-3 | sed 's/[\n\r]\+//g'`
    if [ "`grep -EL "^${RPART}" ${FTMASTER}.partial.csv`" ] # verify it's not in the master file
    then
        echo "${R}"        
    fi
done > ${FO}

if [ -s "${FO}" ]
then
    ${HOME}/bin/ftimportrowsfromcsv.sh "${FO}" "${FTID}"
fi

mv ${FO} ${FO}.out archive > /dev/null 2> /dev/null

rm ${FILEPRE}.latest_added.csv > /dev/null 2> /dev/null
ln -s archive/${FO} ${FILEPRE}.latest_added.csv

#!/bin/bash

D=`date +%Y%m%d-%H%M%S`

toc_max=1

if [ $# -ge 1 ]
then
    toc_max=$1
fi

let MAX_TRIES=${toc_max}*10
let MAX_TRIES=${MAX_TRIES}+10
tries=0
SLEEPSECS=5

BASEURL="http://www.gld.gov.hk/egazette/english/gazette/"
TOC="http://www.gld.gov.hk/egazette/english/gazette/toc.php"
VOL="http://www.gld.gov.hk/egazette/english/gazette/volume.php"

toc_i=0

echo "Processing table of contents..."

VOLS="vols.${D}.csv"
echo "date,volume,number,type,rev,link" > ${VOLS}
while true
do
    #COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "PHPSESSID=(\w+)" `
    COOKIE=`curl -sI "http://www.gld.gov.hk/egazette/english/gazette/toc.php?Submit=accept" | grep -Eo "Set-Cookie: ([^;]+);" | sed 's/Set-Cookie: //g' | sed ':a;N;$!ba;s/\n/ /g'`
    # Get the TOC page
    IN="toc.${D}.${toc_i}.html"
    curl -sb "${COOKIE}" "${TOC}?page=${toc_i}" -o ${IN}
    echo FILE: ${IN}
    if [ ! -s ${IN} ]
    then
        let tries=${tries}+1
        if [ ${tries} -gt ${MAX_TRIES} ]
        then
            echo "Tried maximum times (${MAX_TRIES}). Now exiting process..."
            rm ${VOLS}
            exit
        fi
        echo "file empty: ${IN} (try #${tries})"
        sleep ${SLEEPSECS}
        continue
    fi
    # Retain the part we want
    echo ${IN}
    LEN=`wc -l ${IN} | cut -d" " -f1`
    TOP=`grep -n "<table" ${IN} | cut -d: -f1`
    let TAIL=${LEN}-${TOP}
    let TAIL=${TAIL}+1
    tail -${TAIL} ${IN} > ${IN}.tail
    BOTTOM=`grep -n "</table>" ${IN}.tail | cut -d: -f1`
    let BOTTOM=${BOTTOM}+1
    let HEAD=${BOTTOM}
    echo "<div>" > ${IN}.out
    head -${HEAD} ${IN}.tail >> ${IN}.out
    # Change entities
    sed -i 's/&nbsp;/ /g' ${IN}.out
    # Send through the parser
    ./parse_toc.py ${IN}.out >> ${VOLS}
    let toc_i=${toc_i}+1
    rm ${IN} ${IN}.tail ${IN}.out
    if [ ${toc_i} -gt ${toc_max} ]
    then
        break
    fi
done
dos2unix -q ${VOLS}

sleep ${SLEEPSECS}

VOLS_URLS="vols.urls.${D}.csv"
GAZETTES="gazettes.${D}.csv"
GAZETTES_URLS="gazettes.urls.${D}.csv"
cut -d, -f6 ${VOLS} > ${VOLS_URLS}
if [ ! -r ${VOLS_URLS} ] || [ `wc -l ${VOLS_URLS} | cut -d" " -f1` -le 0 ]
then
    echo "Volumes file ${VOLS_URLS} not found. Exiting..."
    rm ${VOLS}
    exit
fi
dos2unix -q ${VOLS_URLS}
./getvol.sh ${VOLS_URLS} >> ${GAZETTES}
dos2unix -q ${GAZETTES}

echo "Processing volume pages..."
while read IN
do
    echo ${IN}
    if [ ! -s ${IN} ]
    then
        let tries=${tries}+1
        if [ ${tries} -gt ${MAX_TRIES} ]
        then
            echo "Tried maximum times (${MAX_TRIES}). Now exiting process..."
            rm ${VOLS}
            exit
        fi
        continue
    fi
    LEN=`wc -l ${IN} | cut -d" " -f1`
    TOP=`grep -n '<p class="h2">' ${IN} | cut -d: -f1`
    let TAIL=${LEN}-${TOP}
    let TAIL=${TAIL}+1
    tail -${TAIL} ${IN} > ${IN}.tail
    BOTTOM=`grep -n '<script type="text/javascript">var last_revision_date' ${IN}.tail | cut -d: -f1`
    let BOTTOM=${BOTTOM}+1
    let HEAD=${BOTTOM}
    echo "<div>" > ${IN}.out
    head -${HEAD} ${IN}.tail >> ${IN}.out
    sed -i 's/&/\&amp;/g' ${IN}.out
    sed -i 's/<img [^>]\+>//g' ${IN}.out
    # Send through the parser
    ./parse_gaz.py ${IN}.out >> ${GAZETTES_URLS}
    dos2unix -q ${GAZETTES_URLS}
    rm ${IN} ${IN}.tail ${IN}.out
done < ${GAZETTES}

PDFLISTS="pdflists.${D}.csv"
PDFLISTS_URLS="pdflists.urls.${D}.csv"
#if [ ! -r ${GAZETTES_URLS} ] || [ `wc -l ${GAZETTES_URLS} | cut -d" " -f1` -le 0 ]
if [ ! -s ${GAZETTES_URLS} ]
then
    echo "Gazette file ${GAZETTES_URLS} not found. Exiting..."
    rm ${VOLS} ${VOLS_URLS} ${GAZETTES}
    exit
fi
./getlinks.sh ${GAZETTES_URLS} >> ${PDFLISTS}
dos2unix -q ${PDFLISTS}

echo "Processing PDF listing pages..."
while read IN
do
    echo ${IN}
    if [ ! -s ${IN} ]
    then
        continue
    fi
    LEN=`wc -l ${IN} | cut -d" " -f1`
    TOP=`grep -n '<p class="h2">' ${IN} | cut -d: -f1`
    let TAIL=${LEN}-${TOP}
    let TAIL=${TAIL}+1
    tail -${TAIL} ${IN} > ${IN}.tail
    if [ `grep '<script type="text/javascript">var last_revision_date' ${IN}.tail | wc -l` -ge 1 ]
    then
        BOTTOM=`grep -n '<script type="text/javascript">var last_revision_date' ${IN}.tail | cut -d: -f1`
    else
        BOTTOM=`grep -n '</table>' ${IN}.tail | cut -d: -f1`
    fi
    let BOTTOM=${BOTTOM}
    let HEAD=${BOTTOM}
    echo "<root>" > ${IN}.out
    head -${HEAD} ${IN}.tail >> ${IN}.out
    dos2unix -q ${IN}.out
    sed -i 's/&nbsp;/ /g' ${IN}.out
    sed -i 's/<br>/ \n/gi' ${IN}.out
    sed -i 's/&/\&amp;/g' ${IN}.out
    sed -i 's/<img [^>]\+>//g' ${IN}.out
    if [ `echo ${IN}.out | grep "^ls6-" | wc -l` -ge 1 ]
    then
        sed -i 's/Insurance Companies Ordinance/Insurance Companies Ordinance<\/td>/g' ${IN}.out
    fi
    echo "</root>" >> ${IN}.out
    # Send through the parser
    ./parse_pdflist.py ${IN}.out 2>> error.${D}.log >> ${PDFLISTS_URLS}
    #rm ${IN} ${IN}.tail ${IN}.out
    rm ${IN} ${IN}.tail
    if [ `grep "${IN}.out" error.${D}.log | wc -l` -eq 0 ]
    then
        rm ${IN}.out
    else
        mv ${IN}.out errors
    fi
done < ${PDFLISTS}

# Get the PDFs (first pass)
if [ ! -r ${PDFLISTS_URLS} ] || [ `wc -l ${PDFLISTS_URLS} | cut -d" " -f1` -le 0 ]
then
    echo "PDF lists file ${PDFLISTS_URLS} not found. Exiting..."
    rm ${VOLS} ${VOLS_URLS} ${GAZETTES} ${PDFLISTS} ${GAZETTES_URLS} #${PDFLISTS_URLS}
    exit
fi
PDFS="pdfs.${D}.csv"
PDFS_OUT="pdfs.files.${D}.csv"
dos2unix -q ${PDFLISTS_URLS}
sed -i 's/&amp;/\&/g' ${PDFLISTS_URLS}
grep -oE ",pdf\.php\?[^,]*$" ${PDFLISTS_URLS} | cut -d, -f2 > ${PDFS}
./getpdfs.sh ${PDFS} 2> /dev/null >> ${PDFS_OUT}

# Other sub-pages
VOLS_PDFS="vols.pdfs.${D}.csv"
grep -oE ",volume\.php\?[^,]*$" ${PDFLISTS_URLS} | cut -d, -f2 > ${VOLS_PDFS}
grep -E ",,$" ${PDFS_OUT} | cut -d, -f1 >> ${VOLS_PDFS}
./getlinks.sh ${VOLS_PDFS} 2 >> ${PDFLISTS}.1
#if [ `wc -l ${PDFLISTS}.1 | cut -d" " -f1` -ge 1 ]
if [ -s ${PDFLISTS}.1 ]
then
    echo "Second pass PDF listing pages..."
    while read IN
    do
        REF_IN=`echo "${IN}" | cut -d\| -f1`
        IN=`echo "${IN}" | cut -d\| -f2`
        #echo "${REF_IN}" >> secondpass.${D}.log
        #echo "${IN}" >> secondpass.${D}.log
        echo ${REF_IN} ${IN}
        if [ ! -s ${IN} ]
        then
            continue
        fi
        LEN=`wc -l ${IN} | cut -d" " -f1`
        TOP=`grep -n '<p class="h2">' ${IN} | cut -d: -f1`
        if [ "${TOP}" == "" ]
        then
            continue
        fi
        let TAIL=${LEN}-${TOP}
        let TAIL=${TAIL}+1
        tail -${TAIL} ${IN} > ${IN}.tail
        if [ `grep '<script type="text/javascript">var last_revision_date' ${IN}.tail | wc -l` -ge 1 ]
        then
            BOTTOM=`grep -n '<script type="text/javascript">var last_revision_date' ${IN}.tail | cut -d: -f1`
        else
            BOTTOM=`grep -n '</table>' ${IN}.tail | cut -d: -f1`
        fi
        let BOTTOM=${BOTTOM}
        let HEAD=${BOTTOM}
        echo "<root>" > ${IN}.out
        head -${HEAD} ${IN}.tail >> ${IN}.out
        dos2unix -q ${IN}.out
        sed -i 's/&nbsp;/ /g' ${IN}.out
        sed -i 's/<br>/ \n/gi' ${IN}.out
        sed -i 's/&/\&amp;/g' ${IN}.out
        sed -i 's/<img [^>]\+>//g' ${IN}.out
        if [ `echo ${IN}.out | grep "^ls6-" | wc -l` -ge 1 ]
        then
            sed -i 's/Insurance Companies Ordinance/Insurance Companies Ordinance<\/td>/g' ${IN}.out
        fi
        echo "</root>" >> ${IN}.out
        # Send through the parser
        ./parse_pdflist.py ${IN}.out "${REF_IN}" 2>> error.${D}.log >> ${PDFLISTS_URLS}.1
        rm ${IN} ${IN}.tail ${IN}.out
        #rm ${IN} ${IN}.tail
    done < ${PDFLISTS}.1
    dos2unix -q ${PDFLISTS_URLS}.1
    sed -i 's/&amp;/\&/g' ${PDFLISTS_URLS}.1
    grep -oE ",pdf.php\?[^,]*$" ${PDFLISTS_URLS}.1 | cut -d, -f2 > ${PDFS}.1
    grep -vE ",,$" ${PDFS_OUT} > foo.${D}.csv
    #mv ${PDFS_OUT} pdfs.files.secondpass/
    rm ${PDFS_OUT}
    mv foo.${D}.csv ${PDFS_OUT}
    ./getpdfs.sh ${PDFS}.1 2 2> /dev/null >> ${PDFS_OUT}
    rm ${PDFLISTS}.1 ${PDFLISTS_URLS}.1 ${PDFS}.1 ${PDFS_OUT}.1
fi

find pdfs -name \*.txt -exec mv {} text \;

# Put the headers
## gazette.docs
mv ${PDFLISTS_URLS} ${PDFLISTS_URLS}.out
echo "gazdate,vol,no,extra,typeid,typedesc,section,rev,notice_no,subject,dept,deptemail,officer,group,classification,link" > ${PDFLISTS_URLS}
cat ${PDFLISTS_URLS}.out >> ${PDFLISTS_URLS}
rm ${PDFLISTS_URLS}.out
./insert_by_row.py gazette.docs ${PDFLISTS_URLS}
mv ${PDFLISTS_URLS} pdflists
## gazette.pdfs
mv ${PDFS_OUT} ${PDFS_OUT}.out
echo "link,filename,filehash" > ${PDFS_OUT}
cat ${PDFS_OUT}.out >> ${PDFS_OUT}
rm ${PDFS_OUT}.out
./insert_by_row.py gazette.pdfs ${PDFS_OUT}
mv ${PDFS_OUT} pdfs.files.csvs

mv error.${D}.log errors

rm ${VOLS} ${VOLS_URLS} ${GAZETTES} ${PDFLISTS} ${GAZETTES_URLS} ${PDFS} ${VOLS_PDFS} ${PDFLISTS_URLS} 2> /dev/null

echo SUCCESS

#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Missing file with PDF links"
    exit
fi

PRE="pdfscraperfile"

split -d -a 6 -l 200 $1 ${PRE}.

rm pdfscraper/${PRE}.* 2> /dev/null
mv ${PRE}* pdfscraper

for i in `ls pdfscraper/${PRE}.*`
do
    echo $i
    SP=`echo $i | sed 's/\([^\/]\+\)$/to2ndpass.\1/'`
    echo "link,filename,filehash" > $i.out
    ./getpdfs.sh $i >> $i.out
    ./getpdfs.sh $SP 2 >> $i.out
    ./insert_by_row.py gazette.pdfs $i.out
    sleep 5
done

rm pdfscraper/${PRE}.*

#!/bin/bash

DY=`date -d"1 week ago" +%Y%m%d`
D=`date +%Y%m%d`

scp -q csam@lamma.jmsc.hku.hk:/var/data/hongkong/gazette/all.gazette.*.${D}.csv .

if [ -s all.gazette.docs.${D}.csv ]
then
    rm all.gazette.docs.${DY}.csv all.gazette.pdfs.${DY}.csv
    psql -q -h 127.0.0.1 -U  scmp -c "truncate table gazette.docs"
    psql -q -h 127.0.0.1 -U  scmp -c "truncate table gazette.pdfs"
    psql -q -h 127.0.0.1 -U  scmp -c "\\copy gazette.docs from all.gazette.docs.${D}.csv csv header"
    psql -q -h 127.0.0.1 -U  scmp -c "\\copy gazette.pdfs from all.gazette.pdfs.${D}.csv csv header"
fi

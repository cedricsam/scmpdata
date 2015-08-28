#!/bin/bash

mv all.gazette.20*.csv allgazette

D=`date +%Y%m%d-%H%M%S`

SQL="\\copy (select *, 'http://data.jmsc.hku.hk/hongkong/gazette/pdfs/'||filename archive_url from gazette.gazette order by gazdate desc, dept) to 'all.gazette.${D}.csv' csv header "

psql -h 127.0.0.1 -U scmp -c "${SQL}"

rm all.gazette.csv

ln -s all.gazette.${D}.csv all.gazette.csv

#FTID="1kvM7P1E7wr8aISyr7qvTcqBkDyzyF2TkyinmITU"

#${HOME}/bin/ftsql.py POST "DELETE FROM ${FTID}"

#sleep 60

#${HOME}/bin/ftimportrowsfromcsv.sh all.gazette.${D}.csv ${FTID}

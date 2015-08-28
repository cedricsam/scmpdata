#!/bin/bash

while read line
do
    echo $line | sed 's/POLYGON/SRID=2326;POLYGON/' | psql -U scmp -h 127.0.0.1 -c "\\copy ozp_identify from stdin csv"
done < $1

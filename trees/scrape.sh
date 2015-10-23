#!/bin/bash
# Scrapes the tree register's data
# Original site: http://www.trees.gov.hk/treeregister/map/treeindex.aspx

# Change N to the latest max number of trees in database, but will automatically stop
N=3800

for i in `seq ${N}`
do
    FO="${i}.json"
    if [ -s ${FO} ]
    then
        continue
    fi
    curl "http://www.trees.gov.hk/treeregister/map/iTreeService.asmx/GetTreeMapInfo" -H 'Content-Type: application/json' --data-binary $"{id:${i},lang:'en-US'}" -o "${FO}"
    if [ `wc -m "${FO}" | cut -d" " -f1` -le 10 ]
    then
        rm "${FO}"
    fi
done

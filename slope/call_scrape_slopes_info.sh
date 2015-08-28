#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
D=`date +%Y%m%d`
DR="archive/${D}.infos"
mkdir -p ${DR}
cd ${DR}

while read i
do
    ${DIR}/scrape_slopes_info.sh "${i}"
done < ${DIR}/slopes.txt

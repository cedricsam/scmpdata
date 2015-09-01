#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DD=`date +%Y%m%d-%H%M`
D=`date +%Y%m%d`
if [ $# -gt 0 ]
then
    D=$1
fi

fo=${DIR}/data/${DD}

for f in `ls -v archive/${D}/*.json 2> /dev/null`
do
    ${HOME}/bin/parse_esri.py $f $fo.slopegeo.csv
done

for i in `seq 16`
do
    for f in `ls -v archive/${D}.infos/${i}[A-Z]*.slopeinfo.json 2> /dev/null`
    do
        ${HOME}/bin/parse_json.py `cat cols.slopeinfo.csv` $f $fo.slopeinfo.csv
    done
    for f in `ls -v archive/${D}.infos/${i}[A-Z]*.techinfo.json 2> /dev/null`
    do
        ${HOME}/bin/parse_json.py `cat cols.techinfo.csv` $f $fo.techinfo.csv
        ${HOME}/bin/parse_json.py -sa SPI -fk SLOPE_TI_ID,SLOPE_NO `cat cols.techinfo.spi.csv` $f $fo.techinfo.spi.csv
        ${HOME}/bin/parse_json.py -sa WPI -fk SLOPE_TI_ID,SLOPE_NO `cat cols.techinfo.wpi.csv` $f $fo.techinfo.wpi.csv
    done
done

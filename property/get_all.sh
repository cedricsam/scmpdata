#!/bin/bash

for i in `seq 9800`
do
    DATA="plxf=getlatest_land&plxa[]=0&plxa[]=${i}&plxa[]=100&plxa[]=0"
    FCH="all_ch/${i}.html"
    FEN="all_en/${i}.html"
    if [ ! -s "${FCH}" ]
    then
        curl "http://data.28hse.com/" -d "${DATA}" --compressed -o "${FCH}"
    fi
    if [ ! -s "${FEN}" ]
    then
        curl "http://data.28hse.com/en/" -d "${DATA}" --compressed -o "${FEN}"
    fi
done

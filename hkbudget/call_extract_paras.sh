#!/bin/bash

if [ -z $1 ]
then
    exit
fi

for i in `ls -tr $1*.extract.htm*`
do
    ../extract_paras.py $i
done | sort -n

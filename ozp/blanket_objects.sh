#!/bin/bash

D=`date +%Y%m%d`

mkdir objects_$D
cd objects_$D

for i in `seq 0 100000`
do
    ../get_objects.sh $i
done

for i in `seq 0 100000`
do
    ../get_objects.sh $i
done

for i in `ls *.json`
do
    ../parse_objects.py $i
done > ../ozp_objects_${D}.csv

cd -

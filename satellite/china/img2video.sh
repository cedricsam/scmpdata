#!/bin/bash

d=`date +%Y%m%d-%H%M`
BRANDING="/var/data/satellite/china/scmp_40px.png"

# Usage: timelapse.sh [nb of minutes]

if [ $# -lt 1 ]
then
    exit
fi

t=1
if [ $# -gt 0 ]
then
    t=`echo $1`
fi
f=${d}.${t}

find images -name sevp_nsmc_wxcl_asc_e99_achn_lno_py_\* -type f -mtime -${t} -size +0c | sort > timelapses/${f}.txt
mkdir -p timelapses/${f}
n=0
while read i
do
    I=`printf %04d $n`
    let n=$n+1
    cp -p $i timelapses/${f}/frame${I}.jpg
done < timelapses/${f}.txt

ffmpeg -f image2 -i timelapses/${f}/frame%04d.jpg -r 60 timelapses/out/${f}_60fps.nobrand.mp4 #> /dev/null 2> /dev/null

ffmpeg -i timelapses/out/${f}_60fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=10:10" timelapses/out/${f}_60fps.mp4 #> /dev/null 2> /dev/null

ffmpeg -i timelapses/out/${f}_60fps.mp4 timelapses/out/${f}_60fps.webm #> /dev/null 2> /dev/null

rm timelapses/out/latest_60fps.nobrand.mp4 timelapses/out/latest_60fps.mp4 timelapses/out/latest_60fps.webm

ln -s ${f}_60fps.nobrand.mp4 timelapses/out/latest_60fps.nobrand.mp4
ln -s ${f}_60fps.mp4 timelapses/out/latest_60fps.mp4

ln -s ${f}_60fps.webm timelapses/out/latest_60fps.webm

#!/bin/bash

d=`date +%Y%m%d-%H%M`
BRANDING="/var/data/webcams/tdcctv/scmp_30px.png"

# Usage: timelapse.sh [webcam code] [nb of minutes]

if [ $# -lt 1 ]
then
    exit
fi

c=${1}
t=3600
if [ $# -gt 1 ]
then
    t=$2
fi
f=${c}.${t}.${d}

find img -name ${c}_\* -type f -cmin -${t} | sort > timelapses/${f}.txt
mkdir -p timelapses/${f}
n=0
while read i
do
    I=`printf %04d $n`
    let n=$n+1
    cp -p $i timelapses/${f}/frame${I}.jpg
done < timelapses/${f}.txt

ffmpeg -f image2 -i timelapses/${f}/frame%04d.jpg -r 30 timelapses/out/${f}_30fps.nobrand.mp4 > /dev/null 2> /dev/null
ffmpeg -f image2 -i timelapses/${f}/frame%04d.jpg -r 60 timelapses/out/${f}_60fps.nobrand.mp4 > /dev/null 2> /dev/null

ffmpeg -i timelapses/out/${f}_30fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=283:2" timelapses/out/${f}_30fps.mp4 > /dev/null 2> /dev/null
ffmpeg -i timelapses/out/${f}_60fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=283:2" timelapses/out/${f}_60fps.mp4 > /dev/null 2> /dev/null

ffmpeg -i timelapses/out/${f}_30fps.mp4 timelapses/out/${f}_30fps.webm > /dev/null 2> /dev/null
ffmpeg -i timelapses/out/${f}_60fps.mp4 timelapses/out/${f}_60fps.webm > /dev/null 2> /dev/null

rm timelapses/out/${c}.${t}.latest_30fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_60fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_30fps.mp4 timelapses/out/${c}.${t}.latest_60fps.mp4
rm timelapses/out/${c}.${t}.latest_30fps.webm timelapses/out/${c}.${t}.latest_60fps.webm

ln -s ${f}_30fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_30fps.nobrand.mp4
ln -s ${f}_60fps.nobrand.mp4 timelapses/out/${c}.${t}.latest_60fps.nobrand.mp4
ln -s ${f}_30fps.mp4 timelapses/out/${c}.${t}.latest_30fps.mp4
ln -s ${f}_60fps.mp4 timelapses/out/${c}.${t}.latest_60fps.mp4

ln -s ${f}_30fps.webm timelapses/out/${c}.${t}.latest_30fps.webm
ln -s ${f}_60fps.webm timelapses/out/${c}.${t}.latest_60fps.webm

scp -i ~/.ssh/multimedia.pem timelapses/out/${f}_30fps.mp4 timelapses/out/${f}_60fps.mp4 timelapses/out/${c}.${t}.latest_30fps.mp4 timelapses/out/${c}.${t}.latest_60fps.mp4 mumopr@multimedia.scmp.com:www/occupylapse/media > /dev/null 2> /dev/null
scp -i ~/.ssh/multimedia.pem timelapses/out/${f}_30fps.webm timelapses/out/${f}_60fps.webm timelapses/out/${c}.${t}.latest_30fps.webm timelapses/out/${c}.${t}.latest_60fps.webm mumopr@multimedia.scmp.com:www/occupylapse/media > /dev/null 2> /dev/null

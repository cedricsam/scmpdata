#!/bin/bash

BRANDING="/var/data/webcams/tdcctv/scmp_30px.png"
DIR="timelapses"

# Usage: timelapse.retro.sh [webcam code] [date of end] [nb of minutes]

if [ $# -lt 2 ]
then
    exit
fi

c=${1}
t=1440
if [ $# -gt 1 ]
then
    d=$2
fi
if [ $# -gt 2 ]
then
    t=$3
fi
f=${c}.${t}.${d}
df=`echo $d | grep -Eo "[0-9]{8}-[0-9]{4}" | sed 's/-/ /'`
now=`date +%s`
let secsend=${now}-`date -d"${df}" +%s`
let minsend=${secsend}/60
let minsstart=${minsend}+${t}

find img -name ${c}_\* -type f -cmin -${minsstart} -cmin +${minsend} | sort > ${DIR}/${f}.txt
mkdir -p ${DIR}/${f}
n=0
while read i
do
    I=`printf %04d $n`
    let n=$n+1
    cp -p $i ${DIR}/${f}/frame${I}.jpg
done < ${DIR}/${f}.txt

ffmpeg -f image2 -i ${DIR}/${f}/frame%04d.jpg -r 30 ${DIR}/out/${f}_30fps.nobrand.mp4 > /dev/null 2> /dev/null
ffmpeg -f image2 -i ${DIR}/${f}/frame%04d.jpg -r 60 ${DIR}/out/${f}_60fps.nobrand.mp4 > /dev/null 2> /dev/null

ffmpeg -i ${DIR}/out/${f}_30fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=283:2" ${DIR}/out/${f}_30fps.mp4 > /dev/null 2> /dev/null
ffmpeg -i ${DIR}/out/${f}_60fps.nobrand.mp4 -i ${BRANDING} -filter_complex "overlay=283:2" ${DIR}/out/${f}_60fps.mp4 > /dev/null 2> /dev/null

scp -qi ~/.ssh/multimedia.pem ${DIR}/out/${f}_30fps.mp4 ${DIR}/out/${f}_60fps.mp4 mumopr@multimedia.scmp.com:www/occupylapse/media > /dev/null 2> /dev/null

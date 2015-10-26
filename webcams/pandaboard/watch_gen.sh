#!/bin/bash

TARGETDIR="/var/www/mobilewebcam"

while true
do
    video=`find -cmin -1 -type f -name capture.20\*[0-9].mp4 | sort -n | tail -1`
    audio=`echo $video | sed 's/\.mp4$/.mp3/g'`
    outfile=`echo $video | sed 's/\.mp4$/.out.mp4/g'`
    if [ -s $outfile ]
    then
        sleep 15
        continue
    fi
    ffmpeg -i $video -i $audio -y -c:v copy -c:a copy $outfile
    ls -al $outfile
    ln -s `pwd`/${outfile} ${TARGETDIR}/${outfile} 
    sleep 15
done

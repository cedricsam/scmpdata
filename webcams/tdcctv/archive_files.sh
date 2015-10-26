#!/bin/bash

if [ $# -lt 1 ]
then
    exit
fi

FA="archive/archive_${1}.tar.gz"
OUTDIR="/s3fs/webcams/tdcctv/archive/"
ARCHIVEDIR="/var/data/tmp/video.multimedia.scmp.com/webcams/tdcctv"

if [ -s ${FA} ] # don't overwrite the archive
then
    exit
fi

re='^[0-9]+$'
if [[ $1 =~ ${re} ]]
then
    FL="filelist_${1}.txt"
    find img -name "*_${1}-*.jpg" -type f > ${FL}
    tar czf ${FA} -T ${FL} 2> /dev/null
    rm ${FL}
else
    exit
fi

FA_SIZE_MIN=102400000
FA_SIZE=$(wc -c "${FA}" | cut -f 1 -d ' ')

if [ ${FA_SIZE} -ge ${FA_SIZE_MIN} ]
then
    find img -name "*_${1}-*.jpg" -type f -exec rm {} \;
fi

mv ${FA} ${OUTDIR}
rm ${ARCHIVEDIR}/${FA}

if [ -a ${FL} ]
then
    rm ${FL}
fi

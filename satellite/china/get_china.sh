#!/bin/bash

D=`date +%Y-%m-%d`

INDEX="pages/img_${D}.html"

wget -q "http://www.weather.com.cn/static/en_product.php?class=JC_YT_DL_WXZXCSYT" -O "${INDEX}"
grep -Eo 'http://i.weather.com.cn/i/product/pic/m/[^"]+' ${INDEX}  | sort -u > latest_links_china.txt

cd images

while read i
do
    wget -qN "${i}"
done < ../latest_links_china.txt

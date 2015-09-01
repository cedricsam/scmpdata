#!/bin/bash

if [ -z $1 ]
then
    exit
fi

for i in `find -name $1\*.htm\* | grep -E "$1.*[0-9]+[a-z]?.html?" | sort`
do
    FO=`echo $i | sed 's/\.htm/.extract.htm/'`
    echo $FO $i
    case "$1" in
    2014)
        sed -n '/              <td width="694">/I,/<\/td>/p' $i > ${FO}
        ;;
    2014)
        sed -n '/              <td width="667">/I,/<\/td>/p' $i > ${FO}
        ;;
    201*)
        sed -n '/InstanceBeginEditable name="content"/I,/<\/td>/p' $i > ${FO}
        ;;
    2009)
        sed -n '/InstanceBeginEditable name="editregion2"/I,/<\/td>/p' $i > ${FO}
        ;;
    2008)
        sed -n '/InstanceBeginEditable name="contents"/I,/<\/div>/p' $i > ${FO}
        ;;
    2007)
        sed -n '/<td width="500" align="left" valign="top" class="content">/I,/<\/td>/p' $i > ${FO}
        ;;
    2006)
        sed -n '/                          <table width="95%" align="center" cellpadding="0" cellspacing="0">/I,/<\/table>/p' $i > ${FO}
        ;;
    2006)
        sed -n '/                  <table width="95%" align="center" cellpadding="0" cellspacing="0">/I,/<\/table>/p' $i > ${FO}
        ;;
    esac
done

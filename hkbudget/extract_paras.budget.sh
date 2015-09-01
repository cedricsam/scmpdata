#!/bin/bash

if [ -z $1 ]
then
    exit
fi

for i in `find www.budget.gov.hk/$1/ -regex .*/budget[0-9]+.html? | sort -n`
do
    FO=`echo $i | sed 's/\.htm/.extract.htm/'`
    echo $FO $i
    case "$1" in
    2014|2013)
        #sed -n '/<div class=WordSection[0-9]\+>/I,/<!--FooterNoteStart-->/p' $i > ${FO}
        sed -n '/InstanceBeginEditable name="editregion6"/I,/<!-- InstanceEndEditable -->/p' $i > ${FO}
        ;;
    2012)
        sed -n '/InstanceBeginEditable name="editregion3"/I,/<!-- InstanceEndEditable -->/p' $i > ${FO}
        ;;
    2011)
        sed -n '/InstanceBeginEditable name="editregion1"/I,/<!-- InstanceEndEditable -->/p' $i > ${FO}
        ;;
    2010|2009)
        sed -n '/InstanceBeginEditable name="editregion1"/I,/<!-- InstanceEndEditable -->/p' $i > ${FO}
        ;;
    2008)
        sed -n '/InstanceBeginEditable name="editregion5"/I,/<!-- InstanceEndEditable -->/p' $i > ${FO}
        ;;
    2007)
        sed -n '/<td width="560" height="[0-9]\{3\}" align="left" valign="top">/I,/<\/td>/p' $i > ${FO}
        ;;
    2006)
        sed -n '/<div id="content">/I,/<\/div>/p' $i > ${FO}
        ;;
    esac
done

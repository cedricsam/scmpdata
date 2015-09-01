#!/bin/bash

Y=$1

for i in `find www.budget.gov.hk/${Y} -name head*.txt`
do
    HEAD=`grep "Head" $i | head -1`
    PROVISION=`grep "Provision of " $i | grep "salaries" | head -1`
    NONDIRECTORATE=`grep "non-directorate posts " $i | head -1`
    NOTEXCEED=`grep "must not exceed" $i | head -1`
    HEAD_NB=`echo $HEAD | grep -oE "[0-9]+"`
    HEAD_NAME=`echo $HEAD | sed 's/Head //' | cut -d" " -f3- | sed 's/^\b//'`
    echo -n $HEAD_NB,\"$HEAD_NAME\",
    ND_POSTS=`echo $NONDIRECTORATE | grep -oE ".+ non-directorate" | sed 's/ non-directorate.*//' | sed 's/[,. ]//'`
    ND_POSTS_TO=`echo $NONDIRECTORATE | grep -oE "to .+ [a-z]" | grep -oE "[0-9., ]+" | sed 's/[,. ]//g'`
    FOO=`echo -n $PROVISION | grep -oE 'Provision of [$0-9., ]+' | cut -d$ -f2 | sed 's/[,. \\n\\r]//g'`
    echo -n $FOO
    echo -n ,$ND_POSTS,$ND_POSTS_TO,
    echo ""
done

#!/bin/bash

P=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

S1=`date +%N`
X=`rand -s ${S1} -M 70000`
let X=800000+$X
S11=`date +%N`
R1=`rand -s ${S11} -M 999999999`
X="${X}.`printf %09d ${R1}`"

S2=`date +%N`
Y=`rand -s ${S2} -M 48000`
let Y=800000+$Y
S22=`date +%N`
R2=`rand -s ${S22} -M 999999999`
Y="${Y}.`printf %09d ${R2}`"

${P}/identify_points.sh $Y $X

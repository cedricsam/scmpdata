#!/bin/bash

Y=$1

for i in `find www.budget.gov.hk/${Y} -name head\*.txt | sort -n`
do
    ./parse_budget_subheads.py $i | sed "s/^/${Y},/g"
done

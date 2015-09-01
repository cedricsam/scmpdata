#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv

if len(sys.argv) <= 1:
    sys.exit()

f = open(sys.argv[1], "r")

i = 1
l_cumul = list()
paras = list()
for line in f:
    l = line.strip()
    new = False
    if l.startswith(str(i)+"."):
        new = True
        if len(l_cumul) > 0:
            paras.append([" ".join(l_cumul)])
            l_cumul = list()
        i += 1
    l_cumul.append(l)
    if line.startswith("\t"):
        print line
#print paras[1:len(paras)-1]

cw = csv.writer(sys.stdout)
cw.writerows(paras[1:len(paras)-1])

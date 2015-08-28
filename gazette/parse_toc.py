#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv
import datetime
import xml.etree.ElementTree as ET

if len(sys.argv) <= 1:
    sys.exit()

tree = ET.parse(sys.argv[1])
root = tree.getroot()

isheader = True
toc = list()
rev = root[1].text
rev = rev.split(" = ")[1].split('"')[1]
drev = datetime.datetime.strptime(rev, "%d %b %Y")
rev = drev.strftime("%Y-%m-%d")
for tr in root[0]:
    if isheader:
        isheader = False
        continue
    rows = len(tr)
    i = 0
    gazette = dict()
    d = datetime.datetime.strptime(tr[0][0].text, "%d %b %Y")
    gazette["date"] = d.strftime("%Y-%m-%d")
    gazette["volume"] = int(tr[2][0].text)
    gazette["number"] = int(tr[3][0].text)
    gazette["link"] = tr[0][0].get("href")
    gazette["rev"] = rev
    if tr[1].text is None or len(tr[1].text.strip()) <= 0:
        gazette["type"] = "ordinary"
    else:
        gazette["type"] = tr[1].text.strip(" ()").lower()
    toc.append(gazette)

fields = ["date", "volume", "number", "type", "rev", "link"]
cw = csv.DictWriter(sys.stdout, fields)

for r in toc:
    cw.writerow(r)

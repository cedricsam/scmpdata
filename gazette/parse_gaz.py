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

gaz = list()
rev = root[2].text
rev = rev.split(" = ")[1].split('"')[1]
drev = datetime.datetime.strptime(rev, "%d %b %Y")
rev = drev.strftime("%Y-%m-%d")
for li in root[1]:
    section = dict()
    #section["desc"] = li[0].text
    section["link"] = li[0].get("href")
    #section["rev"] = rev
    gaz.append(section)

#fields = ["desc", "rev", "link"]
fields = [ "link" ]
cw = csv.DictWriter(sys.stdout, fields)

for r in gaz:
    cw.writerow(r)

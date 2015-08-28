#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv

if len(sys.argv) <= 1:
    sys.exit()

fields = ["date", "vol", "no", "extra", "typeid", "typedesc", "section", "rev", "notice_no", "subject", "dept", "deptemail", "officer", "group", "classification", "link"]

cr = csv.DictReader(open(sys.argv[1], "r"), fields)

out = dict()

for r in cr:
    if r["link"] not in out:
        out[r["link"]] = r

cw = csv.DictWriter(sys.stdout, fields)

for r in out.values():
    cw.writerow(r)

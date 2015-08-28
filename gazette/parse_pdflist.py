#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import csv
import datetime
import pprint
import xml.etree.ElementTree as ET

if len(sys.argv) <= 1:
    sys.exit()
ref_in = ""
if len(sys.argv) > 2:
    ref_in = "|" + sys.argv[2]

try:
    tree = ET.parse(sys.argv[1])
except Exception as e:
    sys.stderr.write("Found error and exiting while processing PDF list: " + sys.argv[1] + "\n")
    sys.stderr.write(str(e) + "\n")
    sys.exit()
root = tree.getroot()

fields = ["date", "vol", "no", "extra", "typeid", "typedesc", "section", "rev", "notice_no", "subject", "dept", "deptemail", "officer", "group", "classification", "link"]
textfields = ["section", "subject", "dept", "officer", "group", "classification"]

pdfs = list()

# Parse header infos
head = root[0].text
date_re = re.search(r"\d{2}/\d{2}/\d{4}", head)
if date_re is not None:
    d = datetime.datetime.strptime(date_re.group(0), "%d/%m/%Y")
    d = d.strftime("%Y-%m-%d")
no_re = re.search(r"No\. (\d+)", head)
if no_re is not None:
    no = no_re.group(1)
vol_re = re.search(r"Vol\. (\d+)", head)
if vol_re is not None:
    vol = vol_re.group(1)
extra_re = re.search(r"Gazette Extraordinary", head)
if extra_re is not None:
    extra = 1
else:
    extra = 0
typedesc_re = re.search(r"- (.*)$", head)
if typedesc_re is not None:
    typedesc = typedesc_re.group(1)
section = None

# Parse revision date
if len(root) > 2:
    rev = root[2].text
    rev = rev.split(" = ")[1].split('"')[1]
    drev = datetime.datetime.strptime(rev, "%d %b %Y")
    rev = drev.strftime("%Y-%m-%d")
else:
    rev = None

table = root[1]
if table[0].tag == "tbody":
    table = table[0]
isheader = True
isls6 = False
cols = list()
for tr in table:
    if isheader:
        isheader = False
        if tr[0].tag == "th":
            for x in tr:
                cols.append(x.text.lower())
        if len(cols) >= 2 and cols[0] == "group" and cols[1] == "classification":
            isls6 = True
        continue
    if len(tr) <= 1 and tr[0].get("class") == "category": # sub-header
        section = tr[0].text
        continue
    row = dict()
    row["date"] = d
    row["vol"] = vol
    row["no"] = no
    row["extra"] = extra
    row["section"] = section
    row["rev"] = rev
    #row["desc"] = tr[0].text
    row["subject"] = row["notice_no"] = row["group"] = row["classification"] = None
    if len(tr) > 1 and not isls6:
        try:
            row["notice_no"] = int(tr[0][0].text)
        except:
            if tr[0][0].text == "--":
                row["notice_no"] = None
            else:
                row["notice_no"] = tr[0][0].text
        row["subject"] = tr[1][0].text
    elif isls6:
        row["group"] = tr[0][0].text
        if tr[0][0].tail is not None:
            row["group"] += "\r" + tr[0][0].tail
        row["classification"] = tr[1].text
    elif len(tr) == 1:
        row["notice_no"] = None
        row["subject"] = tr[0][0].text
    if len(tr) > 2:
        if len(tr[2]) > 0:
            row["dept"] = tr[2][0].text
            row["deptemail"] = tr[2][0].get("href").split(":")[1]
        else:
            row["dept"] = tr[2].text
            row["deptemail"] = None
    else:
        row["dept"] = None
        row["deptemail"] = None
    if len(tr) > 3:
        if len(tr[3]) > 0:
            row["officer"] = tr[3][0].text
        else:
            row["officer"] = tr[3].text
    else:
        row["officer"] = None
    row["link"] = tr[0][0].get("href") + ref_in
    typeid_re = re.search(r"&type=(\d+)", row["link"])
    if typeid_re is not None:
        row["typeid"] = int(typeid_re.group(1))
    else:
        row["typeid"] = 0
    for a in textfields:
        if row[a] is not None:
            row[a] = re.sub(r"[ \t]+\n", "\n", re.sub(r"\n[ \t]+", "\n", row[a].encode("utf8").strip()))
    pdfs.append(row)

cw = csv.DictWriter(sys.stdout, fields)

for r in pdfs:
    cw.writerow(r)

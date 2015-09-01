#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import csv
import json
import types
import copy

cols = ["head_no", "programme_no", "programme_name", "programme_aim"]
numcols = ["actual", "original", "revised", "estimate"]
cols.extend(numcols)

cw = csv.DictWriter(sys.stdout, cols)

if len(sys.argv) <= 1:
    cw.writeheader()
    sys.exit()

fn = sys.argv[1]

try:
    f = open(fn, "r")
except IOError:
    sys.exit()

inside = False
inside_count = 0
inside_programmes = False
head_no = None
head_name = None
aims = list()

index = 0

programme_no = None
programme_name = ""
getting_programme = False
one_programme = ""
is_one_programme = False
getting_aim = False

rows = list()

for line in f:
    if head_no is None and line.strip().startswith("Head"):
        m = re.match(r"Head (\d{1,3}) — (.*)", line.strip())
        if m is not None:
            head_no = m.group(1)
    if line.strip() == "Aim":
        getting_aim = True
        aim = ""
    elif getting_aim:
        if re.match(r"Head (\d{1,3})", line.strip()) and not aim.endswith("."):
            continue
        if len(line.strip()) == 0 or line.strip() == "Brief Description" or re.match(r"Head (\d{1,3})", line.strip()):
            getting_aim = False
            aims.append(aim.strip("0123456789 "))
        else:
            aim += " " + line.strip()
    if not inside and line.strip().startswith("ANALYSIS OF FINANCIAL PROVISION"):
        if head_no is None:
            head_no = fn.split("/")[len(fn.split("/"))-1].replace("head", "").split(".")[0].lstrip("0")
        inside = True
        r = dict()
        inside_count += 1
    if inside and line.strip().startswith("Programme"):
        inside_programmes = True
    if line.strip().startswith("Analysis of Financial and Staffing Provision"):
        inside = False
    if line.strip().startswith("Sub-"):
        inside = False
    if not inside or inside_count > 1:
        continue
    if "—————" in line:
        continue
    if "($m)" in line:
        continue
    if len(line.strip()) <= 0:
        continue
    line_split = re.split(r"( *\.{2,} *| {2,})", line.rstrip())
    m = re.match(r"\((\d{1,2})\)", line)
    if m is not None:
        r = dict()
        programme_no = m.group(1)
        programme_name = ""
        getting_programme = True
    if getting_programme and len(line_split) != 4 and len(line_split) > 1:
        programme_name += " " + re.sub(r"\.{2,}", "", line_split[2].strip())
    if inside_programmes and not getting_programme and len(line_split) >= 1 and len(line_split) < 5 and line.strip() != "Programme":
        one_programme += " " + re.sub(r"\.{2,}", "", line_split[len(line_split)-1].strip()) + ""
    if len(line_split) == 11 or (len(line_split) == 9 and len(line_split[0].strip()) > 0 and "..." in line_split[1]):
        try:
            if programme_no is None:
                is_one_programme = True
                programme_no = "1"
                programme_name = one_programme + " " + line_split[0].strip()
            r["head_no"] = head_no
            r["programme_no"] = programme_no.strip()
            r["programme_name"] = programme_name.strip()
            r["programme_aim"] = aims[index]
            if len(r["programme_name"]) == 0: r["programme_name"] = line_split[1].strip(" \.")
            if len(r["programme_name"]) == 0: r["programme_name"] = line_split[0].strip(" \.")
        except Exception as e:
            print str(e)
            print fn
            print line_split
            continue
        incr = 4
        if len(line_split) == 9: incr = 2
        for i in range(len(numcols)):
            r[numcols[i]] = line_split[(i*2)+incr]
            #if r[numcols[i]] is not None: r[numcols[i]] = re.sub(r"[,—#β†±^φμ]+", "", r[numcols[i]]).strip()
            r[numcols[i]] = re.sub(r"[^0-9\.]+", "", r[numcols[i]]).strip()
            if r[numcols[i]] is not None:
                r[numcols[i]] = r[numcols[i]].strip(" —").replace(",","")
        rows.append(copy.copy(r))
        #cw.writerow(r)
        index += 1
        programme_name = ""
        getting_programme = False
    if (not getting_programme and len(line_split) == 9 and len(rows) > 0) or (len(line_split) == 11 and is_one_programme):
        r = dict()
        r["head_no"] = head_no
        r["programme_no"] = "0"
        r["programme_name"] = "total"
        incr = 2
        if len(line_split) == 11: incr = 4
        for i in range(len(numcols)):
            r[numcols[i]] = line_split[(i*2)+incr]
            #if r[numcols[i]] is not None: r[numcols[i]] = re.sub(r"[,—#β†±^φμ]+", "", r[numcols[i]]).strip()
            r[numcols[i]] = re.sub(r"[^0-9\.]+", "", r[numcols[i]]).strip()
            if r[numcols[i]] is not None:
                r[numcols[i]] = r[numcols[i]].strip(" —").replace(",","")
        rows.append(copy.copy(r))
        #cw.writerow(r)
        getting_programme = False
    #print len(line_split), line_split
cw.writerows(rows)

#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import csv
import json
import types
import copy

cols = ["head_no", "subhead_name", "subhead_no", "item_no", "title", "note_actual", "note_original", "note_revised", "note_estimate", "reimbursement"]
numcols = ["actual", "original", "revised", "estimate"]
title_words = ["Recurrent", "Non-Recurrent", "Operating Account", "Capital Account", "Plant, Equipment and Works", "Subventions"]
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
head_no = None
head_name = None


subhead_no = subhead_name = title_name = ""
getting_subhead = False
getting_note = False
notes_marks = list()
notes_marks_indexes = list()
notes_marks_types = list()
index = 0
note_index = -1
note = ""
rows = list()

for line in f:
    if head_no is None and line.strip().startswith("Head"):
        m = re.match(r"Head (\d{1,3}) — (.*)", line.strip())
        if m is not None:
            head_no = m.group(1)
    if not inside and line.strip().startswith("Sub-"):
        inside = True
        r = dict()
        inside_count += 1
    if line.strip().startswith("Details of Expenditure by Subhead"):
        inside = False
    if line.strip().startswith("Description of Revenue Source"):
        inside = False
    if not inside or inside_count > 1:
        continue
    if "—————" in line:
        continue
    if "$’000" in line or "$,000" in line:
        continue
    if len(line.strip()) <= 0:
        continue
    line_split = re.split(r" {2,}", line.rstrip())
    m = re.match(r"\d{3}", line)
    if m is not None:
        r = dict()
        subhead_no = m.group(0)
        subhead_name = ""
        getting_subhead = True
    if len(line_split) != 4 and len(line_split) > 1:
        subhead_name += " " + re.sub(r"\.{2,}", "", line_split[1].strip())
    if len(line_split) > 1 and line_split[1].strip() in title_words:
        title_name = line_split[1].strip()
        subhead_name = ""
        item_no = ""
    if subhead_name.endswith("—"):
        title_name = subhead_name.strip("—")
        subhead_name = ""
    if subhead_name.strip().startswith("Total"):
        title_name = ""
        subhead_no = ""
    if len(line_split) == 2:
        foo = line_split[1]
        note_mark = foo.decode("utf8")[0]
        if foo.endswith("."):
            if getting_note:
                rows[note_index]["note_"+note_type] += foo
            getting_note = False
        if note_mark in notes_marks:
            getting_note = True
            note_index = notes_marks_indexes[notes_marks.index(note_mark)]
            note_type = notes_marks_types[notes_marks.index(note_mark)]
            rows[note_index]["note_"+note_type] = foo
    if len(line_split) == 6:
        try:
            m = re.match(r"\((\d{3})\)", subhead_name.strip())
            if m is not None:
                item_no = m.group(1)
                subhead_name = subhead_name.strip().replace("(%s)"%item_no,"").strip()
                r["item_no"] = item_no
            r["head_no"] = head_no
            r["subhead_no"] = subhead_no.strip()
            r["subhead_name"] = subhead_name.strip()
            if len(r["subhead_name"]) == 0: r["subhead_name"] = line_split[1].strip(" \.")
            if len(title_name) > 0: r["title"] = title_name.strip()
            elif r["subhead_name"].strip().startswith("Total"): r["title"] = ""
        except Exception as e:
            #print str(e)
            #print fn
            #print line_split
            continue
        for i in range(len(numcols)):
            r[numcols[i]] = line_split[i+2]
            #if r[numcols[i]] is not None: r[numcols[i]] = re.sub(r"[,—#β†±^φμ]+", "", r[numcols[i]]).strip()
            if r[numcols[i]] is not None:
                r[numcols[i]] = r[numcols[i]].strip(" —").replace(",","")
                if len(r[numcols[i]]) > 0:
                    try:
                        foo = r[numcols[i]].decode("utf8")
                    except:
                        continue
                    last_char = foo[len(foo)-1]
                    if re.search(r"[0-9]$", last_char) is None:
                        #print r[numcols[i]], last_char
                        notes_marks.append(last_char)
                        notes_marks_indexes.append(index)
                        notes_marks_types.append(numcols[i])
                r[numcols[i]] = re.sub(r"[^0-9\.]+", "", r[numcols[i]]).strip()
        if "Deduct reimbursements" in r["subhead_name"]:
            r["reimbursement"] = r["subhead_name"].split(")")[1].strip().split(" ")[0].replace(",","")
            r["subhead_name"] = r["subhead_name"].split(")")[0] + ")"
        else:
            r["reimbursement"] = ""
        rows.append(copy.copy(r))
        #cw.writerow(r)
        index += 1
        subhead_name = ""
        getting_subhead = False
    #print len(line_split), line_split
cw.writerows(rows)

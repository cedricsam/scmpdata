#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import re
import csv
import json
import types
import copy


cols = ["head_no", "establishment_directorate", "establishment_nondirectorate"]
numcols = ["actual", "original", "revised", "estimate"]
#cols.extend(numcols)

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

inside_establishment = False
establishment_line = []

rows = []
out = {}

for line in f:
    line_stripped = line.strip()
    if head_no is None and line_stripped.startswith("Head"):
        m = re.match(r"Head (\d{1,3}) — ?(.*)", line.strip())
        if m is not None:
            head_no = m.group(1)
            out["head_no"] = head_no
        continue
    if (line_stripped.startswith("Establishment") and "establishment_nondirectorate" not in out) or (line_stripped.startswith("In addition") and "establishment_directorate" not in out):
        inside_establishment = True
    if inside_establishment:
        establishment_line.append(line_stripped)
    if "Commitment balance" in line or len(line_stripped) <= 0 or ".." in line:
        inside_establishment = False
        if len(establishment_line) > 0:
            outstr = re.sub(r"\.+", " ", re.sub(r"[ ]+", " ", " ".join(establishment_line))).strip()
            if outstr.startswith("Establishment"):
                out["establishment_nondirectorate"] = outstr
            elif outstr.startswith("In addition"):
                out["establishment_directorate"] = outstr
            establishment_line = []
if "establishment_nondirectorate" in out or "establishment_directorate" in out:
    cw.writerow(out)

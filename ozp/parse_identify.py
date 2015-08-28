#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import re
import time
import stat
import csv
import json
import types
import argparse

cols_attr = ["objectid", "dpo", "ozp_schm", "shape", "shape.area", "shape.len"]
cols_othr = ["layerId", "layerName", "value", "displayFieldName", "geometryType", "geometry"]
cols_0 = ["plan_type", "ura_planno", "zon.cspuse", "zon.label", "zon.spcode", "zon.spuse", "zon.sspuse"]
cols_1 = ["gaz_date", "planno", "section", "ver"]

cols_out_tmp = cols_attr + cols_othr
cols_out = []
for c in cols_out_tmp:
    cols_out.append(c.replace(".","_").lower())

ap = argparse.ArgumentParser(description='Parse JSON file from identify function on OZP TPB site.')
ap.add_argument('infile', nargs='?', type=argparse.FileType('r'), const=sys.stdin, default=sys.stdin)
ap.add_argument('outfile', nargs='?', type=argparse.FileType('a'), const=sys.stdout, default=sys.stdout)

args = ap.parse_args()

outrows = []
js = json.loads(args.infile.read())

(mode, ino, dev, nlink, uid, gid, size, atime, mtime, ctime) = os.stat(sys.argv[1])
time_fetched = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(mtime))

for res in js["results"]:
    out = {}
    for a in cols_attr:
        out[a.replace(".","_")] = res["attributes"][a.upper()]
    for a in cols_othr:
        if a == "geometry":
            #print res[a]["rings"]
            out[a] = re.sub(r" +", " ", re.sub(r"\], ?\[","|", re.sub(r"\]\], ?\[\[", ")|(", re.sub(r"\]\]\]$", "))", re.sub(r"^\[\[\[","POLYGON((",str(res[a]["rings"]))))).replace("[","").replace("]","").replace(","," ").replace("|",","))
            #out[a] = res[a]
        elif res[a] == "Null":
            out[a.lower()] = None
        else:
            out[a.lower()] = res[a]
    for a in cols_out:
        if out[a] is not None and (type(out[a]) is types.StringType or type(out[a]) is types.UnicodeType):
            out[a] = out[a].encode("utf8")
    out["time_fetched"] = time_fetched
    outrows.append(out)
cols_out.append("time_fetched")

cw = csv.DictWriter(args.outfile, cols_out)
#cw.writeheader()
cw.writerows(outrows)

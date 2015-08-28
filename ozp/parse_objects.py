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

cols = ["planNo", "planName", "zoneCode", "zoneDesc", "area", "noteLink", "amendment"]

cols_out = []
for c in cols:
    cols_out.append(c.lower())

ap = argparse.ArgumentParser(description='Parse JSON file from OZPZone function on OZP TPB site.')
ap.add_argument('infile', nargs='?', type=argparse.FileType('r'), const=sys.stdin, default=sys.stdin)
ap.add_argument('outfile', nargs='?', type=argparse.FileType('a'), const=sys.stdout, default=sys.stdout)

args = ap.parse_args()

js = json.loads(args.infile.read())

(mode, ino, dev, nlink, uid, gid, size, atime, mtime, ctime) = os.stat(sys.argv[1])
time_fetched = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(mtime))

out = {}
for a in cols:
    if js[a] == "Null":
        out[a.lower()] = None
    else:
        out[a.lower()] = js[a]
    if a == "noteLink":
        out[a.lower()] = re.sub(r"^\.\.", "", out[a.lower()])
    elif a == "amendment":
        out[a.lower()] = json.dumps(out[a.lower()])
for a in cols_out:
    if out[a] is not None and (type(out[a]) is types.StringType or type(out[a]) is types.UnicodeType):
        out[a] = out[a].encode("utf8")
cols_out.insert(0,"objectid")
cols_out.append("time_fetched")

out["objectid"] = int(re.sub(r"^0+", "", os.path.splitext(os.path.basename(sys.argv[1]))[0]))
out["time_fetched"] = time_fetched

cw = csv.DictWriter(args.outfile, cols_out)
if out["objectid"] == 2:
    cw.writeheader()
cw.writerow(out)

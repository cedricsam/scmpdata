#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv
import pg
import mypass

if len(sys.argv) < 2:
    print "Required: table and file"
    sys.exit()

doupdate = False
if len(sys.argv) > 3 and sys.argv[3] == "-u":
    doupdate = True

f = open(sys.argv[2])

headers = f.readline().replace("\n","")
headers = headers.split(",")

cr = csv.DictReader(f, headers)

pgconn = mypass.getConn()

for r in cr:
    try:
        pgconn.insert(sys.argv[1], r)
    except pg.ProgrammingError as e:
        if not doupdate:
            continue
        if "duplicate" not in str(e):
            print str(e)
        r["dbupdated"] = 'now()'
        try:
            pgconn.update(sys.argv[1], r)
        except Exception as e:
            print str(e)
            continue

#pgconn.insert(sys.argv[1])

#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv
import time
import re
import bs4
import os

pre = "scmp_"

cols = ["id", "url", "pubdate", "filetimestamp", "source", "title", "authors", "body"]#, pre + "location", pre + "personname", pre + "organisation", pre + "positionparty", pre + "positiongovt", pre + "faction", pre + "accusations", pre + "notes", pre + "hidden"]

URLBASE = "http://www.ccdi.gov.cn/ajcc/"

if len(sys.argv) <= 1:
    print ",".join(cols)
    sys.exit()

fpathname = sys.argv[1]

fname = os.path.basename(fpathname)

fhtml = open(fpathname,"r")

soup = bs4.BeautifulSoup(fhtml.read())

r = dict()

try:
    r["id"] = re.sub(r".\w{2,4}$", "", fname)
    r["url"] = URLBASE + fname[1:7] + "/" + fname
    r["title"] = soup.select("h2.tit")[0].text.strip()
    r["source"] = soup.select("h3.daty em.e1")[0].text.replace(u"来源：","").strip()
    r["pubdate"] = soup.select("h3.daty em.e2")[0].text.replace(u"发布时间：", "").strip()
    r["filetimestamp"] = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(os.path.getmtime(fpathname)))
    #r["body"] = soup.find_all("div", class_="TRS_Editor")[1].contents # re.sub(r"</div>$","",re.sub(r'^<div class="TRS_Editor">', "", soup.find_all("div", class_="TRS_Editor")[1])).strip()
    r["body"] = soup.select("div.TRS_Editor")[min(len(soup.select("div.TRS_Editor"))-1,1)].text.strip()
    r["authors"] = None
    authors = re.search(u"（([^）]+)）$", r["body"], re.U)
    if authors is not None: r["authors"] = authors.group(1)
except Exception as e:
    print >> sys.stderr, "Error in processing %(fname)s [%(err)s] " % {"fname": fpathname, "err": str(e)}
    sys.exit()

for a in ["source", "title", "authors", "body"]:
    if a in r and r[a] is not None:
        r[a] = r[a].encode("utf8")
for a in cols:
    if a.startswith(pre):
        r[a] = None

cr = csv.DictWriter(sys.stdout, cols)
cr.writerow(r)

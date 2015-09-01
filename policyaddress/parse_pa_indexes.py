#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv
import bs4
import re

cols = ["id", "link", "level", "heading", "paras"]

if len(sys.argv) <= 1:
    sys.exit()

f = open(sys.argv[1], "r")

s = bs4.BeautifulSoup(f.read().replace("&nbsp;"," "))

trs = s.select("#toc tr")

cw = csv.DictWriter(sys.stdout, cols)

for tr in trs:
    try:
        tds = tr.select("td")
        tds_paras = tr.select("td.paragraph")
        a = tr.select("a")
        if len(a) > 0:
            r = dict()
            r["link"] = a[0]["href"]
            m = re.match(r"[ep]([0-9]+[a-z]?)\.html?", r["link"])
            if m is not None:
                r["id"] = m.group(1)
            else:
                continue
            try:
                r["level"] = a[0].parent["class"][0]
            except:
                r["level"] = None
            r["heading"] = re.sub(r"[\r\n\t ]{2,}", " ", a[0].text.strip().encode("utf8"))
            if len(r["heading"]) <= 0:
                r["heading"] = re.sub(r"[\r\n\t ]{2,}", " ", a[0].parent.text.strip().encode("utf8"))
            r["paras"] = None
            for i_tds_paras in range(0,len(tds_paras)):
                if len(tds_paras[i_tds_paras].text.strip()) > 0:
                    r["paras"] = tds_paras[i_tds_paras].text
                    break
            if r["paras"] is None:
                for i_tds in range(0,len(tds)):
                    if len(tds[i_tds].text.strip()) > 0:
                        m = re.match(r"([0-9]+-?[0-9]*)", tds[len(tds)-1].text.strip())
                        if m is not None:
                            r["paras"] = m.group(1)
            cw.writerow(r)
    except Exception as e:
        print str(e)
        continue

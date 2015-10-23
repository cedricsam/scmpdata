#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv
import types
import datetime
import xml.etree.ElementTree as ET

cols = ["id", "region", "dt", "dist", "id_dist", "estate", "id_estate", "price", "price_num", "price_sqft", "area", "rooms", "gain", "gainloss_pct", "address", "contract_form", "lang"]#, "deal_details"]
cols_text = ["dist", "price", "estate", "address", "contract_form"]
cw = csv.DictWriter(sys.stdout, cols)

if len(sys.argv) <= 1:
    cw.writeheader()
    sys.exit()

tree = ET.parse(sys.argv[1])
root = tree.getroot()

first = True
for tr in root:
    if first:
        first = False
        firstcell = tr[1].text
        if firstcell == "Date": # English
            is_chinese = False
            million = "M"
            million_multiplier = 1000000
            url = "http://data.28hse.com/en/"
            gain_str = "Gain"
            loss_str = "Loss"
        elif firstcell == u"日期": # Chinese
            is_chinese = True
            million = u"萬"
            million_multiplier = 10000
            url = "http://data.28hse.com/"
            gain_str = u"賺"
            loss_str = u"蝕"
        continue
    l = len(tr)
    if l < 10:
        pass
        continue
    row = dict()
    row["lang"] = "ch" if is_chinese else "en"
    row["id"] = tr.get("id").replace("row_","")
    firstcellcolor = tr[0].get("bgcolor")
    if firstcellcolor == "#FF0000":
        row["region"] = "HK"
    elif firstcellcolor == "#008000":
        row["region"] = "KL"
    elif firstcellcolor == "#000080":
        row["region"] = "NT"
    else:
        row["region"] = "NT"
    row["dt"] = tr[1].text
    row["dist"] = tr[2].find("a").text
    row["id_dist"] = tr[2].find("a").get("href").replace(url + "datarecord","").replace(".html","")
    row["estate"] = tr[3].find("a").text
    row["id_estate"] = tr[3].find("a").get("href").replace(url + "datarecord","").replace(".html","")
    #row["sellbuy"] = tr[4].find("font").text
    row["price"] = tr[4][0].tail.replace("$","")
    row["price_num"] = int(float(row["price"].replace(million,"")) * million_multiplier) if million in row["price"] else row["price"]
    row["price_sqft"] = tr[5].text.replace("@$","")
    row["area"] = tr[6].text
    if u"呎" in row["area"] or u"房" in row["area"]:
        if u"房)" in row["area"]:
            row["rooms"] = row["area"].split("(")[1].replace(u"房)","")
            row["area"] = row["area"].split("(")[0].replace(u"呎","")
        else:
            row["area"] = row["area"].replace(u"呎","")
    row["gain"] = tr[7].find("font").text if tr[7].find("font") is not None else None
    row["gain"] = 1 if row["gain"] == gain_str else 0 if row["gain"] == loss_str else None
    row["gainloss_pct"] = None if row["gain"] is None else tr[7][0].tail.replace("%","")
    row["address"] = tr[8].text
    if is_chinese:
        row["contract_form"] = tr[9].text
    #row["deal_details"] = tr[9].find("a").get("href").replace("javascript:show_tr_dealdetail(","").replace(")","")
    for a in cols:
        if a in cols_text and a in row and row[a] is not None and (type(row[a]) is types.StringType or type(row[a]) is types.UnicodeType):
            row[a] = row[a].encode("utf8")
        if a in row and row[a] == "--":
            row[a] = None
    cw.writerow(row)

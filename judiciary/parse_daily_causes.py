#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import bs4
import re
import csv
import types

def fixText (txt):
    txt = re.sub(r"[\r\n ]+"," ", txt.strip()).encode("utf8")
    return txt

cats = ["cfa", "cacfi", "hcmc", "mcl", "lands", "dc", "dcmc", "fmc", "allmag", "etnmag", "kcmag", "ktmag", "twmag", "stmag", "flmag", "tmmag", "crc", "lt", "smt", "oat"]
cols_cats = {
    "cfa":["court*","officer*","time_openchambers*","casenb","parties","nature","representation"],
    "cacfi":["court*","officer*","time_openchambers*","casenb","parties","nature","representation"],
    "cfi":["court*","officer*","time_openchambers*","casenb","parties","nature","representation"],
    "ca":["court*","officer*","time_openchambers*","casenb","parties","nature","representation"],
    "hcmc":["court*","officer*","time_openchambers*","casenb","nature","representation"],
    "mcl":["time_openchambers*","casenb","nature","representation"],
    "lands":["court*","officer*","time*","casenb","parties","nature","representation"],
    "dc":["court*","officer*","time_openchambers*","casenb","parties","nature","representation"],
    "dcmc":["court*","officer*","time_openchambers*","casenb","parties","nature","representation"],
    "fmc":["court*","officer*","time_openchambers*","casenb","nature","representation"],
    "fmc_special":[None,"time*","order","casenb","representation",None],
    "allmag":["time*","casenb","parties","nature","hearing"],
    "etnmag":["time*","casenb","parties","nature","hearing"],
    "kcmag":["time*","casenb","parties","nature","hearing"],
    "ktmag":["time*","casenb","parties","nature","hearing"],
    "twmag":["time*","casenb","parties","nature","hearing"],
    "stmag":["time*","casenb","parties","nature","hearing"],
    "flmag":["time*","casenb","parties","nature","hearing"],
    "tmmag":["time*","casenb","parties","nature","hearing"],
    "allmag":["time*","casenb","parties","nature","hearing"],
    "crc":["court*","officer*","time_openchambers*","casenb","deceased"],
    "crc_hearing":["time*","casenb","parties","nature","hearing"],
    "lt":["casenb","parties","time"],
    "smt":["time*","casenb*","claimant*","defendant*","nature","hearing"],
    "oat":[None,"time","casenb1_casenb2_parties"]
}
cols = ["cat","date","casenb"]
for ccs in cols_cats:
    for cc in cols_cats[ccs]:
        if cc is None:
            continue
        cc_arr = cc.split("_")
        for c in cc_arr:
            c = c.strip("*0123456789")
            if c not in cols:
                cols.append(c)

cw = csv.DictWriter(sys.stdout, cols)

if len(sys.argv) <= 1:
    cw.writeheader()
    sys.exit()
test = ""
if len(sys.argv) > 2:
    test = sys.argv[2]

fpath = sys.argv[1]
f = open(fpath)
fname = fpath.split("/")[len(fpath.split("/"))-1]

cat = fname.split("_")[0]
cat_i = cats.index(cat)
if cat_i < 0:
    sys.exit()
nb_cols_data = len(cols_cats[cat])
cols_data = cols_cats[cat]

s = bs4.BeautifulSoup(f.read().replace("&nbsp;"," "))

trs = s.select(".MsoNormalTable tr")
title = s.head.title

#cw.writeheader()
cpersistent = dict()
for tr in trs:
    c = dict()
    c["cat"] = cat
    c["date"] = fname.split("_")[1].split(".")[0]
    row = dict()
    if tr is None:
        continue
    tds = tr.select("td")
    # Special cases
    if cat.endswith("mag") and len(tds) == 3:
        if "court" in tds[1].text.lower():
            cpersistent["court"] = fixText(tds[2].text)
        if "magistrate" in tds[1].text.lower():
            cpersistent["officer"] = fixText(tds[2].text)
    elif cat.endswith("mag") and len(tds) == nb_cols_data:
        for a in ["court", "officer"]:
            c[a] = cpersistent[a]
    elif cat in ["cfa","crc"] and len(tds) > nb_cols_data:
        tds_raw = tds
        tds = list()
        for td in tds_raw:
            if "mso-cell-special" not in td["style"]:
                tds.append(td)
    elif cat.startswith("crc") and len(tds) == 5:
        cell_i = 0
        for td in tds:
            if cell_i == 4:
                if fixText(td.text.strip()).endswith("Hearing"):#and fixText(td.text).startswith("聆訊"):
                    cat = "crc_hearing"
            cell_i += 1
    elif cat in ["fmc"] and len(tds) == 1:
        for td in tds:
            if "Special Procedure List" in fixText(td.text):
                cat = "fmc_special"
                cols_data = cols_cats[cat]
    elif cat in ["cacfi","ca","cfi"] and len(tds) == 6:
        cell_i = 0
        for td in tds:
            if cell_i == 1:
                if "The Court of Appeal" == fixText(td.text):
                    cat = "ca"
                if "The Court of First Instance" == fixText(td.text):
                    cat = "cfi"
                break
            cell_i += 1
    cols_data = cols_cats[cat]
    # Matches column width
    if len(tds) == nb_cols_data:
        #print re.sub('<[^<]+?>', '', str(tds))
        cell_i = 0
        for td in tds:
            if cols_data[cell_i] is None:
                cell_i += 1
                continue
            is_persistent = False
            if cols_data[cell_i].endswith("*"):
                is_persistent = True
            #print str(cell_i) + str(td.text.encode("utf8")).strip()
            cols_cell_names = cols_data[cell_i].strip("*").split("_")
            split_cell_raw = td.select("p")
            split_cell = list()
            for sc in split_cell_raw:
                if len(fixText(sc.text)) > 1:
                    split_cell.append(sc)
            split_cell_i = 0
            split_cell_n = len(split_cell)
            split_cell_x = len(split_cell) / len(cols_cell_names)
            for cols_cell_name in cols_cell_names:
                if is_persistent and len(fixText(td.text)) <= 1:
                    try:
                        c[cols_cell_name] = cpersistent[cols_cell_name]
                    except Exception as e:
                        sys.stderr.write(fpath+"\n")
                        sys.stderr.write(str(e)+"\n")
                        continue
                else:
                    if "_" in cols_data[cell_i]:
                        #c[cols_cell_name] = " ".join(split_cell[split_cell_x*split_cell_i:split_cell_x*(split_cell_i+1)])
                        split_cell_a = split_cell[split_cell_x*split_cell_i:split_cell_x*(split_cell_i+1)]
                        c[cols_cell_name] = ""
                        for split_cell_a_item in split_cell_a:
                            c[cols_cell_name] += fixText(split_cell_a_item.text) + " "
                        c[cols_cell_name] = c[cols_cell_name].strip()
                    else:
                        c[cols_cell_name] = fixText(td.text)
                    cpersistent[cols_cell_name] = c[cols_cell_name]
                split_cell_i += 1
            cell_i += 1
        cc = dict()
        for a in c:
            if re.search(r"[0-9]$", a) is not None:
                actual_cell_name = a.strip("0123456789")
                sub_cell_index = int(a[len(a)-1])
                if actual_cell_name not in cc or cc[actual_cell_name] is None:
                    cc[actual_cell_name] = list()
                cc[actual_cell_name].append(c[a])
            else:
                cc[a] = c[a]
        for a in cc:
            if type(cc[a]) is types.ListType:
                cc[a] = ",".join(cc[a])
        if "casenb" in cc and len(cc["casenb"]) > 0:
            cw.writerow(cc)


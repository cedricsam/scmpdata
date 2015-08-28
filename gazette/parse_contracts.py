#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import csv
import datetime
import re
import pprint
from curses.ascii import iscntrl
import os.path

use_head = False # Toggle to either use the heads or not (and then use the first row of an entry)

tendering_opts = ["Open", "Limited", "Selective", "Prequa", "Pre- "]
header_starts = ["Tender", "Reference", "Procedure", "Tender Reference", "of Award", "Award", "Number", "Date ", "Gazette"]
header_hierarchy = [["Tender ","Reference"],["Tendering","Procedure"],["Particulars"],["Contractor","Address"],["Item","Quantity"],["Amount"],["Date","of Award","Award"],["Number"]]
#header_words = header_starts + ["Contractor", "Particulars", "Quantity", "Item", "Amount", "Address"]

headers_csv = []
for h in header_hierarchy:
    headers_csv.append("_".join(h[:2]).replace(" ","_").replace("__","_").lower())
headers_csv.insert(0,"gaznum")
headers_csv.insert(0,"gazdate")
headers_csv.insert(0,"filename")

if len(sys.argv) <= 1:
    cw = csv.DictWriter(sys.stdout,headers_csv)
    cw.writeheader()
    sys.exit()

pp = pprint.PrettyPrinter(indent=4,width=100)

path = sys.argv[1]
f = open(path, "r")

fname = os.path.basename(path)

# First pass, reading the file line by line and finding whitespace
ws = list()
lines = list()
for line in f:
    line = line.rstrip("\r\n").strip("\x0c").decode("utf-8")
    #print str(len(line)) + "\t" + line
    wsa = list()
    try:
        for m in re.finditer(r"\s{2,}",line):
            wsa.append([m.start(), len(m.group(0))])
    except:
        continue
    ws.append(wsa)
    lines.append(line)
    #print line.ljust(130) + str(wsa)
#pp.pprint(ws)

gazdate = re.split(r" {2,}",lines[len(lines)-2])[0].strip()
gaznum = re.split(r" {2,}",lines[0])[0].strip()

max_ws = max(ws,key = lambda item: len(item))
#print fname + " --- " + str(len(max_ws))

# Second pass
printed_most_ws = False
ready_to_start = False
in_header = False
wsa_first = list() # whitespace of the first row of an entry per tender ref
wsa_head = list() # whitespace of the header
header_line = "" # latest line of header
header_pos = [] # position of header words in header line
procedure_pos = 0
entry = None
entries = list()
started_infos = False
tendering_opt = None
sticky_procedure = False # if the tendering procedure sticks to the previous row (usually tender ref)
previous_line_empty = True
previous_line_header = False

for i in range(len(lines)):
    if i < 1:
        continue
    if i + 2 >= len(lines):
        continue
    wsa = ws[i]
    line = lines[i]
    if line.startswith("Notes") or line.startswith("It is hereby notified that"):
        break
    if re.match(r"\d{1,2} [A-z]+ 20\d{2}",line):
        started_infos = False
        #print line
    #print line.ljust(130) + str(wsa)
    if len(wsa) == 0 or (ready_to_start and len(wsa) > 0 and wsa[0][0] > 0):
        ready_to_start = True
    for a in header_starts:
        if line.startswith(a):
            #print line
            ready_to_start = True
            in_header = True
            header_line = line
            wsa_head = wsa
            if not previous_line_header:
                header_pos = []
            for hh in header_hierarchy: # place the positions of the header words, if found
                for h in hh:
                    try:
                        hdr = "_".join(hh[:2]).replace(" ","_").replace("__","_").lower()
                        already_in_header_pos = False
                        pos = header_line.index(h)
                        for hp in header_pos:
                            if hp["header"] == hdr:
                                already_in_header_pos = True
                                hp["name"] = h
                                hp["pos"] = pos
                                break
                        if not already_in_header_pos:
                            header_pos.append({"name":h,"pos":pos,"header":hdr})
                            if h in ["Procedure", "Tendering Procedure"]:
                                procedure_pos = pos
                            if entry is None:
                                use_head = True
                                #print "using head"
                        break
                    except:
                        continue
            break
    header_pos = sorted(header_pos,key=lambda hp: hp["pos"])
    #print header_pos
    if in_header:
        previous_line_header = True
        in_header = False
        if len(wsa_head) == len(wsa_first):
            #print wsa_head
            wsa_first = wsa_head
        continue
    else:
        previous_line_header = False
    if len(line) > 0 and iscntrl(line[0]):
        continue
    # check if line contains a tendering option at beginning or under "Procedure"
    for opt in tendering_opts:
        if procedure_pos < 20 and opt in line[0:procedure_pos+16] or opt in line[procedure_pos:procedure_pos+16]:
            tendering_opt = opt
            break
    # If this line starts with text, but the previous is empty or starts with space or contains a tendering opts word in the first 20
    if len(wsa) > 0 and wsa[0][0] > 0 and (len(ws[i-1]) == 0 or (len(ws[i-1]) > 0 and ws[i-1][0][0] == 0) or tendering_opt is not None):
        if not started_infos:
            started_infos = True
        #print str(i) + " " + line + " " + str(wsa)
        if entry is None or entry is not None and len(entry) > 0:
            if entry is not None:
                e_not_empty = 0
                for e in entry:
                    try:
                        if entry[e] is not None and len(entry[e]) > 0:
                            e_not_empty += 1
                    except:
                        pass
                if False and e_not_empty < 4:
                    sys.stderr.write(fname + " " + str(entry) + "\n")
                else:
                    entries.append(entry)
            if use_head:
                entry = dict()
            else:
                entry = list()
            sticky_procedure = False
        # If not enough columns, use the ones from the page
        #if len(wsa) < 4:
        #    use_head = True
        #    #wsa = wsa_head[:]
        wsa_first = wsa[:]
        if len(entry) == 0:
            firstcell_a = re.split(r" {2,}", line)
            #print firstcell_a
            if len(firstcell_a) > 0:
                firstcell = firstcell_a[0]
            else:
                firstcell = line[:wsa_first[0][0]+wsa_first[0][1]-1].strip()
            if use_head:
                entry[header_pos[0]["header"]] = firstcell
            else:
                entry.append(firstcell)
            # Check if a Tendering Procedure snucked in the first cell
            if use_head:
                firstentry = entry[header_pos[0]["header"]]
            else:
                firstentry = entry[0]
            for opt in tendering_opts:
                if use_head:
                    if opt in firstentry and firstentry.index(opt) > 3: # found and not at beginning of the cell
                        entry[header_pos[0]["header"]] = firstentry.replace(" "+opt,"",1).strip()
                        entry[header_pos[1]["header"]] = opt
                        sticky_procedure = True
                        break
                else:
                    if not use_head and opt in firstentry and firstentry.index(opt) > 3: # found and not at beginning of the cell
                        entry[0] = firstentry.replace(" "+opt,"",1).strip()
                        entry.append(opt)
                        wsa_first.insert(0,None) # first row only, but use the None to insert space
                        sticky_procedure = True
                        break
                        #print str(wsa) + str(wsa_first) + " " + line
            # If not found in the first cell, check if second cell is a tendering procedure
            if use_head and not sticky_procedure and len(firstcell_a) > 1:
                for opt in tendering_opts:
                    if firstcell_a[1] == opt:
                        entry[header_pos[1]["header"]] = opt
                        sticky_procedure = True
                        break
        if use_head:
            #print header_pos
            #print line
            previous_cell_has_large_gaps = False
            for j in range(len(entry),len(header_pos)):
                h = header_pos[j]
                bounds = [max(0,h["pos"]-1),None]
                if (j + 1 < len(header_pos)):
                    bounds[1] = header_pos[j+1]["pos"]-1
                entry[h["header"]] = line[bounds[0]:bounds[1]].strip()
                if previous_cell_has_large_gaps:
                    if bounds[0] is not None: bounds[0] += -2
                    entry[h["header"]] = line[bounds[0]:bounds[1]]
                    previous_cell_has_large_gaps = False
                s = re.search(r" {5,}[^ ]{1,2}$", entry[h["header"]])
                if s is not None:
                    previous_cell_has_large_gaps = True
                    #print entry[h["header"]]
                    if bounds[1] is not None: bounds[1] += -2
                    entry[h["header"]] = line[bounds[0]:bounds[1]].strip()
                    #print entry[h["header"]]
                else:
                    previous_cell_has_large_gaps = False
                #print entry
        else:
            for j in range(len(wsa)):
                if (j + 1 < len(wsa)):
                    entry.append(line[wsa[j][0]+wsa[j][1]:wsa[j+1][0]+wsa[j+1][1]-1].strip())
                else:
                    entry.append(line[wsa[j][0]+wsa[j][1]:].strip())
        tendering_opt = None # reset the tendering opt
        continue
    # inside infos, not the top row
    elif started_infos:
        '''
        print entry
        print line
        print wsa_first
        print wsa_head
        print header_line
        '''
        if use_head:
            for j in range(len(header_pos)):
                h = header_pos[j]
                bounds = [max(0,h["pos"]-1),None]
                if (j + 1 < len(header_pos)):
                    bounds[1] = header_pos[j+1]["pos"]-1
                separator_entry = " "
                new_part = line[bounds[0]:bounds[1]]
                if len(entry[h["header"]]) > 0 and entry[h["header"]][len(entry[h["header"]])-1] in "/-(":
                    separator_entry = ""
                if sticky_procedure and h["header"] == "tendering_procedure" and j > 0 and len(new_part.strip()) < 4:
                    entry[header_pos[j-1]["header"]] += new_part.strip()
                    continue
                entry[h["header"]] += separator_entry + new_part.strip()
                entry[h["header"]] = entry[h["header"]].strip()
        else:
            for j in range(len(entry)):
                bounds = [None,None]
                if j == 0:
                    if wsa_first[j] is None:
                        bounds[1] = wsa_first[j+1][0] + wsa_first[j+1][1] - 1
                    else:
                        bounds[1] = wsa_first[j][0] + wsa_first[j][1] - 1
                if j > 0:
                    if wsa_first[j-1] is None:
                        continue
                    bounds[0] = wsa_first[j-1][0] + wsa_first[j-1][1] - 2
                    if j < len(wsa_first):
                        if wsa_first[j] is None:
                            bounds[1] = wsa_first[j+1][0] + wsa_first[j+1][1] - 1
                        else:
                            bounds[1] = wsa_first[j][0] + wsa_first[j][1] - 1

                if bounds[0] is not None and bounds[0] + 2 > len(line):
                    continue

                colname = header_line[bounds[0]:bounds[1]].strip()
                separator_entry = " "
                if len(entry[j]) > 0 and entry[j][len(entry[j])-1] in "/-(":
                    separator_entry = ""
                elif previous_line_empty:
                    separator_entry = "\n"
                new_part = line[bounds[0]:bounds[1]]
                if len(new_part) > 3 and re.search(r" {4,}[^ ]{1}$",new_part) is not None:
                    new_part = line[bounds[0]:bounds[1]-1]
                    if re.search(r" {4,}[^ ]{1}$",new_part) is not None:
                        new_part = line[bounds[0]:bounds[1]-2]
                entry[j] += separator_entry + new_part.strip(" \n\r")
                entry[j] = entry[j].strip()
    #if len(wsa) >= (len(max_ws)-1) and not printed_most_ws:
    if len(line.strip()) == 0:
        previous_line_empty = True
    else:
        previous_line_empty = False
    pass
if entry is not None and len(entry) > 0:
    e_not_empty = 0
    for e in entry:
        try:
            if entry[e] is not None and len(entry[e]) > 0:
                e_not_empty += 1
        except:
            pass
    if False and e_not_empty < 4:
        sys.stderr.write(fname + " " + str(entry) + "\n")
    else:
        entries.append(entry)

if use_head:
    cw = csv.DictWriter(sys.stdout,headers_csv)
    for entry in entries:
        entry["filename"] = fname.split(".")[0]
        entry["gazdate"] = gazdate
        entry["gaznum"] = gaznum
        if len(gazdate) <= 0 or not gazdate[0].isdigit():
            sys.exit()
        for a in headers_csv:
            if a in entry and entry[a] is not None:
                try:
                    entry[a] = entry[a].encode("utf8")
                except:
                    entry[a] = entry[a]
        cw.writerow(entry)
else:
    cw = csv.writer(sys.stdout)
    for entry in entries:
        entry.insert(0,gaznum)
        entry.insert(0,gazdate)
        entry.insert(0,fname.split(".")[0])
        for a in range(len(entry)):
            if entry[a] is not None:
                try:
                    entry[a] = entry[a].encode("utf8")
                except:
                    entry[a] = entry[a]
        cw.writerow(entry)
    #print entries
#pp.pprint(entries)
#pp.pprint(ws)

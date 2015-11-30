#!/usr/bin/python
import csv
from __future__ import division


f = open("../pageRank/data/wi_cardi2.tab")
reader = csv.reader(f, delimiter="\t")

hospitals = {}
for line in reader:
    h = line[-2]
    if (hospitals.has_key(h)):
        hospitals[h] += 1
    else:
        hospitals[h] = 1

f.close()

f = open("../pageRank/data/wi_cardi2.tab")
f2 = open("../pageRank/data/wi_AURORA.tab", "w+")
reader = csv.reader(f, delimiter="\t")
for line in reader:
    h = line[-2]
    if (h == "AURORA MEDICAL GROUP INC"):
        f2.write("\t".join(line) + "\n")

f.close()
f2.close()

auro = open("../pageRank/data/wi_AURORA.tab")
reader = csv.reader(auro, delimiter="\t")
generic_counts = {}
for line in reader:
    brand = line[7]
    generic = line[8]
    if (generic_counts.has_key(generic)):
        generic_counts[generic][1] += 1
    else:
        generic_counts[generic] = [0, 1]
    if (brand != generic):
        generic_counts[generic][0] += 1
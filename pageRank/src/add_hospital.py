#!/usr/bin/python

import csv

f = open("../data/ny_dem.tab")
reader = csv.reader(f, delimiter="\t")

dic_npi = {} #key: npi, value: state
for row in reader:
	dic_npi[row[0]] = row[4]

f.close()

f2 = open("../data/National_Downloadable_File.csv")
reader2 = csv.reader(f2, delimiter=",")
a = reader2.next() #skip the header row

for row in reader2:
	if dic_npi.has_key(row[0]) and row[25] == dic_npi[row[0]]:
		dic_npi[row[0]] = [row[17], row[26]] #Organization legal name, Zip code

f2.close()

f = open("../data/ny_dem.tab")
f3 = open("../data/ny_dem2.tab", "w+")
reader = csv.reader(f, delimiter="\t")

for row in reader:
    add = dic_npi[row[0]]
    if type(add) == list:
        for word in add: row.append(word)
        f3.write("\t".join(row) + "\n")

f.close()
f3.close()
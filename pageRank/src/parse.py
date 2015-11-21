#!/usr/bin/python
##parse the partD prescription data and then intersect the npi with the 
##physician referral data

from __future__ import division # floating number division
import csv

f1 = open("PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab")
reader_partd = csv.reader(f1, delimiter="\t")
a = reader_partd.next() #skip the header row

partD = {} # stores the unique npi's appeared in partD data

for row in reader_partd:
    npi = row[0]
    if not partD.has_key(npi):
        partD[npi] = 1

f1.close()

f2 = open("physician-referrals-2014-days365.txt")
reader_referral = csv.reader(f2, delimiter=",")

# write referrals where two npi's are both in partD data in this file
f3 = open("physician_referrals13-14_inPARTD.csv", "w+")

missed_refs = 0 # counts the number of rows that were filtered
total_refs = 0 # counts the total number of referrals
for row in reader_referral:
    npi1 = row[0]
    npi2 = row[1]
    total_refs += 1
    # keep referrals where two npi's are both in partD data
    if partD.has_key(npi1) and partD.has_key(npi2): 
        f3.write(",".join(row) + "\n")
        # mark the npi's that appeared in referral data: appeared = 0, missed = 1
        partD[npi1] = 0 
        partD[npi2] = 0
    else:
        missed_refs += 1

f2.close()
f3.close()

## write partD prescription data where 
# f4 = open("partD_has_referrals.csv", "w+")
# f1 = open("PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab")
# reader_partd = csv.reader(f1, delimiter="\t")
# a = reader_partd.next() #skip the header row
# for row in reader_partd:
#     npi = row[0]
#     if partD[npi] == 0:
#         f4.write(",".join(row))

# f1.close()
# f4.close()

# see how much the two datasets overlapped
missed_npis = 0
total_npis = len(partD.keys())
for key in partD.keys():
    missed_npis += partD[npi]

print("total unique npi's in partD data: " + str(total_npis))
print("npi's that were not in referral data: " + str(missed_npis))
print("percentage of npi's not covered in referral data: " + 
    str(100 * missed_npis / total_npis) + "%")
print("")
print("total referrals made in 2013-2014: " + str(total_refs))
print("number of referrals that have npi's not in partD: " + str(missed_refs))
print("percentage of referrals that have npi's not in partD: " + 
    str(100 * missed_refs / total_refs) + "%")

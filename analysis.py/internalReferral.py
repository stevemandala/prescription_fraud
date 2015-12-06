__author__ = 'zongyan wang'
## This file output the referral data which the first column is the NPI whose physician is
## Internal Medicine
from string import *
import csv


k = []
NPI = []
kk = []
Referral =[]
dic = {}   # dictionary of referral npi
not_dic = {}  # dictionary of referral npi not Internal medicine
# filter the npi is valid
def isInt(value):
  try:
    float(value)
    return True
  except:
    return False

## load NPI in python
with open("F:/Academic/Stat 992/group project/prescription_fraud/analysis.py/InternalNPI.csv") as f:
    k.extend(f.readlines())
    for i in range(len(k)):
        if isInt(k[i]):
            index = str.find(k[i], "\n")
            npi = k[i][0:index].strip()
            NPI.append(npi)

print("Reading NPI completely")

#### Search NPI in referral data
with open("internal_referral.csv", "a") as inter_refer:
    writer = csv.writer(inter_refer)
    with open("F:/Academic/Stat 992/group project/physician_referrals13-14_inPARTD.csv") as ref:
        kk.extend(ref.readline() for j in ref)
        for j in range(len(kk)):
            referral = kk[j].strip().split(",")
            if isInt(referral[0]):
                if int(referral[0]) in not_dic:
                    continue
                if int(referral[0]) in dic:   # referral can be found in previous
                    writer.writerows([referral])
                else:
                    if referral[0] in NPI:
                        writer.writerows([referral])
                        dic[int(referral[0])] = referral[0]
                    else:
                        not_dic[int(referral[0])] = referral[0]

print("the referral data contains the physician who gives referral is Internal Medicine "
      "is written to 'internal_referral.csv'")


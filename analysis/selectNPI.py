__author__ = 'zongyan wang'
from string import *
import csv

# This document select the physician who is from "Internal Medicine" in PartD
col = []
colnames = []
lines = []
NPI = []

# filter the npi is valid
def isInt(value):
  try:
    float(value)
    return True
  except:
    return False

with open("internal.csv", "a") as ex:
    writer = csv.writer(ex)
    with open("F:/Academic/Stat 992/group project/PartD_Prescriber_PUF_NPI_DRUG_13/"
          "PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab") as f:
#    with open("F:/Academic/Stat 992/group project/toy_data/wi_dem2.tab") as f:

        col.extend(f.readline() for i in range(1))
        colnames.append(col[0].strip().split("\t"))
        writer.writerows(colnames)
        lines.extend(f.readline() for i in f)
        for i in range(len(lines)):
#        print(lines[i])
            if(str.find(lines[i], "Internal Medicine") != -1):
                k = lines[i].strip().split("\t")
                npi = k[0]
                if(isInt(npi)):
                    internal = []
                    NPI.append([npi])
                    internal.append(k)
                    writer.writerows(internal)


with open("InternalNPI.csv", "w") as iex:
    writer = csv.writer(iex)
    writer.writerows([["NPI"]])
    writer.writerows(NPI)
print("The file has been written to 'internal.csv', it has ", str(len(NPI)), "observations")
print("The file has been written to 'InternalNPI.csv'")



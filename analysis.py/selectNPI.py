__author__ = 'zongyan wang'
from string import *
import csv

# This document select the physician who is from "Internal Medicine" in PartD
col = []
colnames = []
lines = []
NPI = {}

# filter the npi is valid
def isInt(value):
  try:
    float(value)
    return True
  except:
    return False
with open("InternalNPI.csv", "a") as iex:
    writer1 = csv.writer(iex)
    writer1.writerows([["NPI"]])
    with open("internal.csv", "a") as inter:
        writer2 = csv.writer(inter)
        with open("F:/Academic/Stat 992/group project/PartD_Prescriber_PUF_NPI_DRUG_13/"
               "PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab") as f:
#        with open("F:/Academic/Stat 992/group project/toy_data/wi_dem2.tab") as f:

            col.extend(f.readline() for i in range(1))
            colnames.append(col[0].strip().split("\t"))
            writer2.writerows(colnames)
            lines.extend(f.readline() for i in f)
            for i in range(len(lines)):
#            print(lines[i])
                if(str.find(lines[i], "MI") != -1):
                    k = lines[i].strip().split("\t")
                    npi = k[0]
                    if(isInt(npi)):
                        npi = int(npi)
                        internal = []
                        internal.append(k)
                        writer2.writerows(internal)
                        if not npi in NPI:
                            NPI[npi] = npi
                            writer1.writerows([[npi]])



print("The file has been written to 'internal.csv', it has ", str(len(NPI)), "observations")
print("The file has been written to 'InternalNPI.csv'")



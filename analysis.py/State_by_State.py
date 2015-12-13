__author__ = 'zongyan wang'
## This document calculate the b/g ratio for the whole data by physician NPI
import csv
import string

rt = []
data = {}
data_new = []
with open("F:/Academic/Stat 992/group project/"
          "PartD_Prescriber_PUF_NPI_DRUG_13/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab") as file:
#with open("F:/Academic/Stat 992/group project/toy_data/wi_dem2.tab") as file:
    rt.extend(file.readline() for i in file)
    for i in range(len(rt)):
        rows = rt[i].strip().split("\t")
        if(len(rows) > 8):
            if rows[0] in data:  # if the physician is in the dictionary created
                data[rows[0]][1] += 1
            else: # create a new dictionary for this physician
                data[rows[0]] = [0, 1]
                data[rows[0]].extend(rows)
            if rows[7] == rows[8]: # physician use a brand_name
                data[rows[0]][0] += 1

print("The data has been worked out")
#for key,value in data.items():
#    print([key, value])

##################################
#print the data
with open("NPI_bg.csv", "a") as output:
    writer = csv.writer(output)
    for i in data:
        data[i][0] = data[i][0]/data[i][1]
        data[i].pop(1)
        data[i].pop(8)
        data[i].pop(8)
        writer.writerows([data[i]])

print("The data has been written to NPI_bg.csv")

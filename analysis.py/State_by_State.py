__author__ = 'zongyan wang'
## This document calculate the b/g ratio for the whole data by physician NPI
import csv
import string


# filter the npi is valid
def isInt(value):
  try:
    float(value)
    return True
  except:
    return False



#rt = []
data = {}
data_new = []
with open("NPI_bg.csv", "w", newline = "") as output:
    writer = csv.writer(output)
    with open("F:/Academic/Stat 992/group project/"
              "PartD_Prescriber_PUF_NPI_DRUG_13/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab") as file:
    #with open("F:/Academic/Stat 992/group project/toy_data/wi_dem2.tab") as file:
        #rt.extend(file.readline() for i in range(5))
        ### Write the file
        #for i in rt:
        for rt in file:
            rows = rt.strip().split("\t")
            if(isInt(rows[0])):
                if rows[0] in data:  # if the physician is in the dictionary created
                    data[rows[0]][1] += 1
                    data[rows[0]][3] += int(rows[10])   ## add total_claim to total_claim
                    data[rows[0]][15] += float(rows[11])  ## total day supply
                    data[rows[0]][16] += float(rows[12])  ## total drug cost
                else: # create a new dictionary for this physician
                    data[rows[0]] = [0, 1, 0, int(rows[10])] # add total_claim to general count
                    data[rows[0]].extend(rows)
                    data[rows[0]][15] = float(data[rows[0]][15])
                    data[rows[0]][16] = float(data[rows[0]][16])
                if rows[7] == rows[8]: # physician use a brand_name
                    data[rows[0]][0] += 1
                    data[rows[0]][2] += int(rows[10])   ## add total_claim to brand-name count
            else:
                if(len(rows) > 8):
                    ##### Write the header
                    head = ["b/g"]
                    head.append("b/g with claim")
                    head.extend(rows)
                    head.pop(10)
                    head.pop(9)
                    writer.writerows([head])
    print("The data has been worked out")
    #for key,value in data.items():
    #    print([key, value])

    ##################################
    #print the data

    for i in data:
        data[i].pop(12) # delete the brand_name column
        data[i].pop(11) # delete the generic_name column
        data[i][0] = data[i][0]/data[i][1]  # calculate b/g
        data[i][1] = data[i][2]/data[i][3]  # calculate b/g with total_claim
        data[i][12] = data[i][3]  ## Total claim
        data[i].pop(3)
        data[i].pop(2)
        writer.writerows([data[i]])

print("The data has been written to NPI_bg.csv")

__author__ = 'zongyan wang'
import csv
import string


# filter the npi is valid
def isInt(value):
  try:
    float(value)
    return True
  except:
    return False

npi = {}
lines = []
with open("F:/Academic/Stat 992/group project/"
          "prescription_fraud/analysis.py/NPI_bg.csv") as file_npi:
    # lines.extend(file_npi.readline() for i in range(10))
    for rows_npi in file_npi:
        rows = rows_npi.strip().split(",")
        if(isInt(rows[0])):  # if valid row
            if(rows[6] == "WI"):    # if physician is from WI
                npi[rows[2]] = rows[2]  # append this.npi to npi

print("NPIs have been extracted from NPI_bg.csv")

with open("referral_wi.csv", "w", newline = "") as ref_wi:
    writer = csv.writer(ref_wi)
    last = ""
    with open("F:/Academic/Stat 992/group project/physician_referrals13-14_inPARTD.csv") as ref:
        # lines.extend(ref.readline() for i in range(10))
        for rows_ref in ref:
            rows = rows_ref.strip().split(",")
            rows.extend([0,0])   # both of NPI are not WI
            if(rows[0] == last):
                rows[5] = 1
                writer.writerows([rows])
            else:
                if(rows[0] in npi):
                    rows[5] = 1
                    writer.writerows([rows])
                    last = rows[0]
                if(rows[1] in npi):
                    rows[6] = 1
                    writer.writerows([rows])
print("referral in WI has been picked out")
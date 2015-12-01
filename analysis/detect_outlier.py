#!/usr/bin/python
from __future__ import division
import csv
import operator
import numpy as np
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
import pandas as pd


def getHospitalPresHist(filename):
    f = open(filename)
    reader = csv.reader(f, delimiter="\t")

    hospitals = {}
    for line in reader:
        h = line[-2]
        if (hospitals.has_key(h)):
            hospitals[h] += 1
        else:
            hospitals[h] = 1

    f.close()
    #list of tuples, sorted by value
    hospitals_sorted = sorted(hospitals.items(), key=operator.itemgetter(1)) 
    keys = []
    for x in hospitals_sorted: keys.append(x[0])

    vals = []
    for x in hospitals_sorted: vals.append(x[1])

    keys = np.array(keys)
    vals = np.array(vals)
    # plotting:
    fig, ax = plt.subplots()
    counts, bins, patches = ax.hist(vals, facecolor='green', edgecolor='gray')
    #width = 0.1
    #bins = map(lambda x: x-width/2,range(1,len(vals)+1))
    #ax.set_xticklabels(keys,rotation=45)
    plt.title("Numbers of prescription made by each hospital")
    plt.show()

    return keys, vals

### helper function for getBGCountsForAHospital. Screens the whole infile, 
### and get only the entries of hospital.
def writeAHospital(infile, outfile, hospital):
    f = open(infile)
    f2 = open(outfile, "w+")
    reader = csv.reader(f, delimiter="\t")
    for line in reader:
        h = line[-2]
        if (h == hospital):
            f2.write("\t".join(line) + "\n")

    f.close()
    f2.close()

### return: {generic_name:[num_brand_names, _num_generics_plus_brand_names]), ...}
def getBGCountsForAHospital(infile, hospital):
    outfile = infile + '_'.join(hospital.split(" "))
    writeAHospital(infile, outfile, hospital)
    hospital_data = open(outfile)
    reader = csv.reader(hospital_data, delimiter="\t")
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

    return generic_counts

### for a given hospital, calcs b/g ratio for each generic
def getBGRatiosForGenerics(generic_counts):
    sorted_generic_counts = sorted(generic_counts.items(), key=lambda x: x[1][1])
    bg_ratios = {}
    for tup in sorted_generic_counts:
        generic_name = tup[0]
        count_brand_name = tup[1][0]
        count_both = tup[1][1]
        ratio = count_brand_name / count_both
        bg_ratios[generic_name] = ratio

    return sorted_generic_counts, bg_ratios

### given a generic, calcs the b/g ratio for other hospitals except the given one
def getBGRatioOthers(df, generic, hospital):
    not_hospital = np.array(df[[19]] != hospital)
    others = df[not_hospital]
    is_generic = np.array(others[[8]] == generic)
    others_thisDrug = others[is_generic][[7,8]]
    others_thisDrug.columns = ["drug_name", "generic_name"]
    brands = sum(others_thisDrug["drug_name"] != others_thisDrug["generic_name"])
    total = len(others_thisDrug["drug_name"])
    return brands / total


if __name__ == '__main__':
    filename = "../pageRank/data/wi_cardi2.tab"
    hospitals, prescriptions = getHospitalPresHist(filename)

    while True:
        print hospitals
        print prescriptions

        hospitalName = raw_input("Enter a hospital's name: ")
        generic_counts = getBGCountsForAHospital(filename, hospitalName)
        sorted_generic_counts, bg_ratios = getBGRatiosForGenerics(generic_counts)
        print sorted_generic_counts

        genericName = raw_input("Enter a generic's name: ")
        df = pd.read_csv(filename, sep='\t')
        others_bgratio = getBGRatioOthers(df, genericName, hospitalName)

        print hospitalName, "\b's bg_ratio on", genericName, "\b:", bg_ratios[genericName]
        print "Other hospitals' bg_ratio on", genericName, "\b: ", others_bgratio

        is_continue = raw_input("CONTINUE? ")
        if not (is_continue == 'yes' or is_continue == 'y'):
            break


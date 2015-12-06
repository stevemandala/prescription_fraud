#!/usr/bin/python
import csv


def addNpiToSet(s, filename):
    f = open(filename)
    reader = csv.reader(f, delimiter="\t")
    for line in reader:
        s.add(line[0]) #in-place modification

    f.close()

def filterRefs(npi_set, ref_filename, outfilename):
    f2 = open(ref_filename)
    f3 = open(outfilename, "w+")
    reader = csv.reader(f2, delimiter=",")
    for line in reader:
        if (line[0] in npi_set) and (line[1] in npi_set):
            f3.write(",".join(line[:3]) + "\n")
    
    f2.close()
    f3.close()

if __name__ == "__main__":
    cardi_filename = "../pageRank/data/wi_cardi2.tab"
    im_filename = "../pageRank/data/wi_im2.tab"
    ref_filename = "../pageRank/data/physician_referrals13-14_inPARTD.csv"
    
    npi_set = set()

    addNpiToSet(npi_set, cardi_filename)
    cardi_refs = "../pageRank/data/wi_cardi_referrals.csv"
    filterRefs(npi_set, ref_filename, cardi_refs)

    addNpiToSet(npi_set, im_filename)
    cardi_im_refs = "../pageRank/data/wi_cardi_im_referrals.csv"
    filterRefs(npi_set, ref_filename, cardi_im_refs)
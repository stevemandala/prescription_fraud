## This file goes back to the whole PartD data, and find the 
## ratio of brandname and generic name of those physicians who have 
## used new drugs proved by FDA from 2011 to 2013

## Load packages
require(data.table)



## Load data
partD <- fread("../PartD_Prescriber_PUF_NPI_DRUG_13/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab",
               sep = "\t")
partD.new <- fread("partD_mergeWith_drug.list.csv")

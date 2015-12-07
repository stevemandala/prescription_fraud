## The function of this .R document is to pick the new drugs in the PartD dataset out.

## Load packages
require(data.table)
require(plyr)
require(dplyr)

## Load our drug list data
drugused2011_2013 <- fread("drugused2011-2013.csv")

## Load PartD data
partD <- fread("../PartD_Prescriber_PUF_NPI_DRUG_13/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab"
               , sep = "\t")
names(partD)


## change the drug name format and all to upperCase
drugUse <- function(medicineData){
  med <- gsub(pattern = " (\\(.*\\))", replacement = "", x= medicineData$name)
  med <- toupper(med)
  return(med)
}

# change all the names using the function
drug <- drugUse(drugused2011_2013)

table <- partD[which(partD$DRUG_NAME %in% drug),]

# Check everything is allright
tableDrug <- table$DRUG_NAME
drug %in% tableDrug

# Save the file to "PartD_newDrug.csv"
write.csv(table, file = "PartD_newDrug.csv", row.names = F)

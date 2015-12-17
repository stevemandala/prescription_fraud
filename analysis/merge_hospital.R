## merge npi and hospital
require(data.table)
require(plyr)
require(dplyr)
## load data
hospital <- fread("F:/Academic/Stat 992/group project/National_Downloadable_File.csv", header = T)
partD_npi <- read.csv("F:/Academic/Stat 992/group project/prescription_fraud/analysis.py/NPI_bg.csv", header = T)


## select hospital and zip
hospital <- as.data.frame(hospital)
hospital1 <-  data.frame(NPI = hospital[,1], hospital = hospital[,18], zip = hospital[,27])
## merge with NPI
full <- plyr::join(partD_npi, hospital1, by = "NPI")

## write csv file
write.csv(full, file = "npi_full.csv", row.names = F)


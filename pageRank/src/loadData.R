library(data.table)  # so fast!
library(igraph)  # all the basic graph operations.
library(zipcode)
library(plotrix)

Et = fread("../data/physician-referrals-2015-days365.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Et, V1)
head(Et)
b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("../data/National_Downloadable_File.csv",colClasses = b)
names(DT)[1] <- c("NPI")
setkey(DT, NPI)
rm(b)

# Inpatient data
InCharge = fread("../data/Medicare_Provider_Charge_Inpatient_DRG100_FY2013.csv",sep = ",",  
                 colClasses = c("character","numeric", "character","character","character","character", "numeric","character", "numeric", "numeric", "numeric", "numeric"))
setkey(InCharge, 'Provider Id')
head(InCharge)

#Physician Billing data
PhyPay = fread("../data/Medicare_Provider_Util_Payment_PUF_a_2013.csv", 
               colClasses = c(rep("character", 19),rep("numeric",3),rep("character", 6)))
setkey(PhyPay,npi)

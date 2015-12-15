# Data Parsing
library(data.table)

Et = fread("physician-referrals-2014-days365.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Et, V1)
head(Et)
b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("National_Downloadable_File.csv",colClasses = b)
names(DT)[1] <- c("NPI")
setkey(DT, NPI)
rm(b)
wi = DT[State == "WI"]
tmp = Et[unique(wi$NPI)]  # so cool! and fast!
Ewi = tmp[complete.cases (tmp)]  #lots of NA's.  Have not inspected why.

write.table(wi, file = "wi_DT.txt", sep=",", col.names = T, row.names = F)
write.table(Ewi, file = "wi_Et.txt", sep=",", col.names = T, row.names = F)


b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
wi = fread("wi_DT.txt",colClasses = b)
setkey(wi, NPI)
Ewi = fread("wi_Et.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Ewi, V1)
 
wi = wi[City == "MADISON"]
tmp = Ewi[unique(wi$NPI)]  # so cool! and fast!
Ewi = tmp[complete.cases (tmp)]  #lots of NA's.  Have not inspected why.

cc = c(rep("character",46))
phy_drug_sum = fread("PARTD_PRESCRIBER_PUF_NPI_13.tab", colClasses = cc)

phy_drug_total = fread("PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab", sep="\t")
phy_drug_total = phy_drug_total[NPPES_PROVIDER_STATE == "WI"]
write.table(phy_drug_total, file = "wi_card_all.txt", sep=",", col.names = T, row.names = F)


# Bipartite network on companies and physicians
library(data.table)
library(zipcode)

#Load open payments data
opDT = fread("PGYR13_P063015/OP_DTL_GNRL_PGYR2013_P06302015.csv")
#opDT$Recipient_Zip_Code = substr(opDT$Recipient_Zip_Code, start = 1, stop = 5)
opDT$Recipient_Zip_Code = clean.zipcodes(opDT$Recipient_Zip_Code)

#Load physician data table
b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("National_Downloadable_File.csv", colClasses = b)
colnames(DT)[1] = "NPI"
DT$`Zip Code` = substr(DT$`Zip Code`, start = 1, stop = 5)
setkey(DT,"Zip Code")

#Match NPIs to entries, since using NPI-compatable data values
opDT$NPI <- NA
for (i in 1:length(opDT$Physician_Profile_ID)) {
  opDT[i]$NPI <- DT[`Zip Code`==opDT[i]$Recipient_Zip_Code
                   & `First Name`==opDT[i]$Physician_First_Name
                   & `Last Name`==opDT[i]$Physician_Last_Name
                   ,"NPI"][1]
}

#Aggregation of data on different regions


#Aggregated totals across agent (e.g. company) IDs
idMoney = data.table(opDT$Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,opDT$Total_Amount_of_Payment_USDollars)
total_by_id = idMoney[,lapply(.SD,sum), by=V1]

#Aggregated totals across NPIs

#Aggregate on zip code data
tmp = data.table(ID = opDT$Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID, 
                 zip = opDT$Recipient_Zip_Code,trans_amt = opDT$Total_Amount_of_Payment_USDollars)
ID_to_zip = tmp[,lapply(.SD,sum),by=list(ID, zip)]
total_by_zip = ID_to_zip[,lapply(.SD,sum),by=zip, .SDcols = c("trans_amt")]
setkey(total_by_zip,zip)

toatl#Gets payments to a specific hospital
op_get_payments_by_zip <- function(zip) {
  zip_trans = opDT[i]$NPI <- DT[`Zip Code`== zip]
  return(zip_trans)
}

# Bipartite network on companies and physicians

#tablb = c()
gen = fread("PGYR13_P063015/OP_DTL_GNRL_PGYR2013_P06302015.csv")
b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("physician_compare/National_Downloadable_File.csv", colClasses = b)
setkey(DT,"Zip Code")

#Match NPIs to entries, since using NPI-compatable data values
gen$NPI <- NAs
#TODO: Parse zipcodes in DT, shorten
for (i in 1:length(gen$Physician_Profile_ID)) {
  gen[i]$NPI <- DT[`Zip Code`==gen[i]$Recipient_Zip_Code
                & `First Name`==gen[i]$Physician_First_Name
                & `Last Name`==gen[i]$Physician_Last_Name
                ,"NPI"][1]
}

#Aggregate on zip code data
zip_trans = data.table(ID = gen$Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID, 
                       zip = gen$Recipient_Zip_Code,trans_amt = gen$Total_Amount_of_Payment_USDollars)
total_by_zip = zip_trans[,lapply(.SD,sum),by=list(ID, zip)]
#Supplementary physician data
sup = fread("PHPRFL_P063015/OP_PH_PRFL_SPLMTL_P06302015.csv")

#Aggregated totals across agent IDs
idMoney = data.table(gen$Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name,gen$Total_Amount_of_Payment_USDollars)
total_by_id = idMoney[,lapply(.SD,sum), by=V1]

#Aggregated totals across NPIs

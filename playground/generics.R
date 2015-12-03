library(data.table)
partD = fread("PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab")
setkey(partD,NPI)

b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("National_Downloadable_File.csv",colClasses = b)
setkey(DT, NPI)
rm(b)
colnames(DT)[1] <- NPI
wi = DT[State == "WI"]
wi = wi[City == "Madison"]
setkey(wi,NPI)

wiPartD = partD[NPPES_PROVIDER_STATE=="WI"]
wiPartD = wiPartD[NPPES_PROVIDER_CITY=="MADISON"]

#Pick a hospital, most common 
hospital = sort(table(wi[as.character(unique(wiPartD$NPI))]$`Organization DBA name`),decreasing=TRUE)[3]
dean = subset(wiPartD, NPI %in% unique(wi[`Organization DBA name`=="DEAN CLINIC"]$NPI))
 
# Get generic to brandname score

LL <- c()
for (npi in unique(dean$NPI)) {
  tmp = dean[NPI==npi]
  ratio = sum(tmp[DRUG_NAME==GENERIC_NAME]$TOTAL_CLAIM_COUNT)/sum(tmp$TOTAL_CLAIM_COUNT)
  LL = append(LL,ratio)
}

# Plot

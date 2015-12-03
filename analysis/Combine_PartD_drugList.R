## This file read the "partD_newDrug.csv" and "drugused2011-2013.csv" and combine these
## two .csv into one


## load packages and files
require(data.table)
require(plyr)
require(dplyr)
require(ggplot2)

setwd("F:/Academic/Stat 992/group project/prescription_fraud")
partD.new <- fread("PartD_newDrug.csv")
drug.list <- fread("drugused2011-2013.csv")
#names(partD.new)
#names(drug.list)

######################################################
# convert the format of drug column in drug.list
drugUse <- function(medicineData){
  med <- gsub(pattern = " (\\(.*\\))", replacement = "", x= medicineData$name)
  med <- toupper(med)
  return(med)
}
med <- drugUse(drug.list) 
drug.list$name <- med
#############################################################
# add "year" and "company" columns
## check the overlap
cat("check the overlap")
length(drug.list$name)
length(unique(drug.list$name))
# There are lots of overlap here. Find them
cat("There are lots of overlap here. Merge the rows")
overlapDrug <- which(table(drug.list$name) > 1)

c.drug <- function(data){
  category.c = paste(unique(as.character(data$category)), collapse=", ")
  company.c = paste(unique(as.character(data$company)), collapse=", ")
  year.c = paste(unique(as.character(data$year)), collapse=", ")
  k <- data.frame(name = unique(data$name), category = category.c, 
                  company = company.c, year = year.c)
  return(k)
}


df1 <- drug.list %>% ddply(~name, c.drug)

<<<<<<< HEAD
# Output the merged data as "combine_drugList.csv"
write.csv(df1, file = "combine_drugList.csv", row.names = F)

# merge the partD.new with combine_drugList
colnames(df1)[1] <- "DRUG_NAME" 
df2 <- merge(partD.new, df1, by = "DRUG_NAME")
#head(df2)


# Output the merge partD as "partD_mergeWith_drug.list.csv"
write.csv(df2, file = "partD_mergeWith_drug.list.csv", row.names = F)
=======
# Output the combine data as "combine_drugList.csv"
write.csv(df1, file = "combine_drugList.csv", row.names = F)
>>>>>>> b0c5307cb9b3bacf7814a8ae3e0da0b9c009ad1e

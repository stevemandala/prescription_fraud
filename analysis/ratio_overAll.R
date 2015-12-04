# This document create a map for the ratio of brandName and generic name over States.
# This document also create a map for ratio counts the weight of column TOTAL_CLAIM_COUNT  

# Load package
require(data.table)
require(plyr)
require(dplyr)
require(ggplot2)

# Load data

partD <- fread("../PartD_Prescriber_PUF_NPI_DRUG_13/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab",
               sep = "\t")


# function for the ratio
#' @param x: data from one particular State
#' @param weight: count the weight of column TOTAL_CLAIM_COUNT 

ratio <- function(x, weight = F){
  if(weight){
    x$weight = x$TOTAL_CLAIM_COUNT
  }else{
    x <- x %>%dplyr::mutate(weight = 1)
  } 
  x <- x %>% 
    summarize(bNotG = sum((DRUG_NAME != GENERIC_NAME)*weight)/ sum(weight))
}

ratio_withoutWeight <- partD %>% ddply("NPPES_PROVIDER_STATE", function(x){ratio(x)})
ratio_withWeight <- partD %>% ddply("NPPES_PROVIDER_STATE", 
                                    function(x){ratio(x, weight = T)})

# Output those two data frame in "ratio_withoutWeight.csv" and "ratio_withWeight.csv"
write.csv(ratio_withoutWeight, file = "ratio_withoutWeight.csv", row.names = F)
write.csv(ratio_withWeight, file= "ratio_withWeight.csv", row.names = F)


## This file read the "partD_newDrug.csv" and "drugused2011-2013.csv" and combine these
## two .csv into one


## load packages and files
require(data.table)
require(plyr)
require(dplyr)
require(tidyr)
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
drug.list$DRUG_NAME <- med
#############################################################
# add "year" and "company" columns
## check the overlap
cat("check the overlap")
length(drug.list$DRUG_NAME)
length(unique(drug.list$DRUG_NAME))
# There are lots of overlap here. Find them
cat("There are lots of overlap here. Merge the rows")
overlapDrug <- which(table(drug.list$DRUG_NAME) > 1)

c.drug <- function(data){
  category.c = paste(unique(as.character(data$category)), collapse=", ")
  company.c = paste(unique(as.character(data$company)), collapse=", ")
  year.c = paste(unique(as.character(data$year)), collapse=", ")
  name.c = paste(unique(as.character(data$name)), collapse=", ")
  k <- data.frame(DRUG_NAME = unique(data$DRUG_NAME), name = name.c,
                  category = category.c, 
                  company = company.c, year = year.c)
  return(k)
}


df1 <- drug.list %>% ddply(~DRUG_NAME, c.drug)


# Output the merged data as "combine_drugList.csv"
write.csv(df1, file = "combine_drugList.csv", row.names = F)

# merge the partD.new with combine_drugList

df2 <- merge(partD.new, df1, by = "DRUG_NAME")
#head(df2)


# Output the merge partD as "partD_mergeWith_drug.list.csv"
write.csv(df2, file = "partD_mergeWith_drug.list.csv", row.names = F)

# Recall where the physician from?
############################################################
# Where are those physicians from? Usage

#usage <- partD.new %>% ddply(~NPPES_PROVIDER_STATE, function(x){length(x$NPI)})
usage <- df2 %>%
  group_by(NPPES_PROVIDER_STATE, year) %>% 
  summarise(usage = length(.$NPI))

# Arrange and reorder the data
usage <- usage %>%
  group_by(year) %>%
  dplyr::mutate(state.reorder = reorder(x = NPPES_PROVIDER_STATE,
                                        X = usage, FUN = min)) %>%
  dplyr::arrange(., desc(usage))

usage <- usage %>%
  dplyr::mutate(state.reorder = reorder(x = NPPES_PROVIDER_STATE,
                                        X = usage, FUN = min)) %>%
  dplyr::arrange(., desc(usage))


usagePlotYear <- ggplot(usage, aes(x = state.reorder, y = usage)) +
  geom_point(aes(color = state.reorder)) +
  geom_text(aes(label = paste0(state.reorder), x = state.reorder, y = usage, 
               color = state.reorder), size = 3) +
  ggtitle("New Drug usage over States and years") +
  facet_wrap(~year)

cat("The total new drug total usage over States and years \n")
print(usagePlotYear)
## Save the plot as "newDrug_Usage_plot_state.png"
ggsave(filename = "newDrug_Usage_plot_state_year.png", plot = usagePlotYear, path = ".",  
       width = 10, height = 10, dpi = 600)


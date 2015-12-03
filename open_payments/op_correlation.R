# Codes for analyzing the correlation of company influence 
# with brand name to generic ratios
#Needs: DT from physician compare

#TODO: 
# Study over more data sets
# Focus on subset of transactions (drugs, etc)


library(dplyr)
phy_drugs = read.csv("wi_cardi2.tab", sep="\t", header=FALSE)
hospitals = unique(wi_dem2[, 20])

setkey(DT,NPI)

phy_drugs$zip = DT[as.character(phy_drugs$V1), mult = "first"]$`Zip Code`

grouped_by_zip = phy_drugs %>% 
  group_by(zip) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

#Calculates ratios based on number of brand name vs total claims
zip_bg_ratios = summarise(grouped_by_zip, 
                           bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
)

hist(zip_bg_ratios$bg_ratio)
 
plot(zip_bg_ratios$bg_ratio,log(total_by_zip[zip_bg_ratios$zip]$trans_amt))

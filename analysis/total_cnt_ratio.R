# Calculates the 

#Note: While the metric of brand_name != generic_name is generally affective, there are some 
# outliers to consider, such as when a substring of the total name is used as "brand name"

library(dplyr)
phy_drugs = fread("wi_cardi2.tab", sep="\t", header=FALSE)
hospitals = unique(phy_drugs[, 20])
setkey(phy_drugs,V1)
#phy_drugs$zip = DT[as.character(phy_drugs$V1), mult = "first"]$`Zip Code` 
#phy_drugs = phy_drugs[`V9`=="METOPROLOL SUCCINATE"]

#First aggregate ratios over physicians 
grouped_by_physician = phy_drugs %>% 
  group_by(V1) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

#Calculates ratios based on number of brand name vs total claims
phy_bg_ratios = summarise(grouped_by_physician, 
      bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
)

phy_bg_ratios$hospital <- phy_drugs[.(phy_bg_ratios$V1), mult = "first"]$V20

grouped_by_hospital = phy_bg_ratios %>% 
  group_by(hospital) %>%
  select(ratio = bg_ratio) 

#Calculates ratios based on number of brand name vs total claims
hosp_bg_ratios = summarise(grouped_by_hospital, 
      average_ratio = mean(ratio),
      ratio_std = sd(ratio)
      )
   
hist(hosp_bg_ratios$average_ratio)
hist(hosp_bg_ratios$ratio_std/hosp_bg_ratios$average_ratio)

# Ratio variance by hospital


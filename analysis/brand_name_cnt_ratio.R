#Note: While the metric of brand_name != generic_name is generally affective, there are some 
# outliers to consider, such as when a substring of the total name is used as "brand name"

library(dplyr)
phy_drugs = read.csv("wi_cardi2.tab", sep="\t", header=FALSE)
hospitals = unique(wi_dem2[, 20])

grouped_by_hospital = phy_drugs %>% 
  group_by(V20) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

#Calculates ratios based on number of brand name vs total claims
hosp_bg_ratios = summarise(grouped_by_hospital, 
      bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
      )
   
hist(hosp_bg_ratios$bg_ratio)

grouped_by_physician = phy_drugs %>% 
  group_by(V1) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

#Calculates ratios based on number of brand name vs total claims
phy_bg_ratios = summarise(grouped_by_physician, 
                      bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
)

hist(phy_bg_ratios$bg_ratio)


#Note: While the metric of brand_name != generic_name is generally affective, there are some 
# outliers to consider, such as when a substring of the total name is used

library(dplyr)
wi_dem2 = read.csv("wi_dem2.tab", sep="\t", header=FALSE)
hospitals = unique(wi_dem2[, 20])

grouped_by_hospital = wi_dem2 %>% 
  group_by(V20) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

#Calculates ratios based on number of brand name vs total claims
bg_ratios = summarise(grouped_by_hospital, 
      bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
      )
   
hist(bg_ratios$bg_ratio)




library(dplyr)
wi_dem2 = read.csv("wi_dem2.tab", sep="\t", header=FALSE)
hospitals = unique(wi_dem2[, 20])

grouped_by_hospital = wi_dem2 %>% 
  group_by(V20) %>%
  select(drug_name = V8, generic_name = V9) 

bg_ratios = summarise(grouped_by_hospital, 
          bg_ratio = 
            sum(as.vector(drug_name) != as.vector(generic_name)) / length(drug_name))

hist(bg_ratios$bg_ratio)

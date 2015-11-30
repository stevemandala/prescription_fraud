library(dplyr)
toy_data = read.csv("../pageRank/data/wi_cardi2.tab", sep="\t", header=FALSE)
hospitals = unique(toy_data[, 20])

grouped_by_hospital = toy_data %>% 
  group_by(V20) %>%
  select(drug_name = V8, generic_name = V9) 

bg_ratios = summarise(grouped_by_hospital, 
          bg_ratio = 
            sum(as.vector(drug_name) != as.vector(generic_name)) / length(drug_name))

hist(bg_ratios$bg_ratio)

# number of prescriptions made by each hospital
hostpital_pres = c(16, 19, 23, 24, 27, 27, 27, 29, 33, 36, 37, 40, 41, 44, 48, 50, 54, 54, 74, 83, 84, 84, 86, 86, 88, 89, 89, 90, 92, 98, 105, 106, 107, 116, 122, 135, 137, 138, 156, 168, 173, 184, 190, 219, 233, 237, 276, 303, 306, 312, 319, 320, 321, 323, 324, 359, 384, 517, 521, 560, 1693)
hist(hostpital_pres)
### Well, it seems AURORA MEDICAL GROUP INC is a huge outlier of prescription number
out = toy_data[toy_data$V20=="AURORA MEDICAL GROUP INC", ]
bg_ratio = sum(as.vector(out$V8) != as.vector(out$V9)) / length(out$V8)
# about 0.439 -- totally normal
aurora = read.csv("../pageRank/data/wi_AURORA.tab", sep="\t", header=FALSE)

names(table(aurora$V8)[1])

others = toy_data[which(toy_data$V20 != "AURORA MEDICAL GROUP INC"), ]
others_thisDrug = others[others$V9=="METOPROLOL SUCCINATE", 8:9]
(total_ratio = sum(as.vector(others_thisDrug$V8) != as.vector(others_thisDrug$V9)) / 
  dim(others_thisDrug)[1])

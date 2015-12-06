library(dplyr)
toy_data = read.csv("../pageRank/data/wi_cardi2.tab", sep="\t", header=FALSE)
hospitals = unique(toy_data[, 20])

grouped_by_hospital = toy_data %>% 
  group_by(V20) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

bg_ratios = summarise(grouped_by_hospital, 
 bg_ratio = 
  sum(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]) / 
   sum(total_claim_cnt))

hist(bg_ratios$bg_ratio, main = "Overall b/g ratios in each hospital, WI cardi")

# number of prescriptions made by each hospital
hostpital_pres = c(345,    583,    891,    907,   1015,   1018,   1294,   1339,   1546,   1603,
                       1679,   1783,   1927,   2159,   2282,   2507,   3513,   3760,   3905,   4026,
                       4181,   4504,   4584,   5028,   5095,   5208,   5336,   5629,   6351,   6558,
                       6570,   6596,   6703,   6862,   8241,   8599,   9405,  10178,  10726,  11179,
                       11211,  13023,  14222,  14509,  15540,  16048,  16442,  16821,  17261,  17745,
                       20220,  22150,  23099,  23574,  24256,  29151,  31161,  31579,  32015,  34093,
                       137068)
hist(hostpital_pres)
### Well, it seems AURORA MEDICAL GROUP INC is a huge outlier of prescription number
out = toy_data[toy_data$V20=="AURORA MEDICAL GROUP INC", ]
( bg_ratio = sum(out$V11[as.vector(out$V8) != as.vector(out$V9)]) / sum(out$V11) )
# about 0.2836402 -- totally normal
aurora = read.csv("../pageRank/data/wi_AURORA.tab", sep="\t", header=FALSE)

aurora_METSUC = aurora[aurora$V9=="METOPROLOL SUCCINATE", c(8,9,11)]

names(table(aurora$V8)[1])

others = toy_data[which(toy_data$V20 != "AURORA MEDICAL GROUP INC"), ]
others_thisDrug = others[others$V9=="METOPROLOL SUCCINATE", c(8,9,11)]
( total_ratio = sum(others_thisDrug$V11[as.vector(others_thisDrug$V8) != as.vector(others_thisDrug$V9)]) / 
  sum(others_thisDrug$V11) )
hist(bg_ratios$bg_ratio)

## Doing T-test

## Create an treatment record for HSD test
data <-grouped_by_hospital
data <- cbind(data,trt=factor(data$V20,labels=1:length(unique(data$V20))))
## Do LSD & HSD test
model <- aov(as.numeric(as.vector(drug_name)==as.vector(generic_name)) ~ trt, 
             data = data)
lsd.out <- LSD.test(model, "trt", p.adj = "bonferroni")
hsd.out <- HSD.test(model,"trt", group = T)

bar.group(lsd.out$groups,ylim=c(0,45),density=4,border="blue")
bar.group(hsd.out$groups,ylim=c(0,45),density=4,border="blue")

lsd.out$groups
hsd.out$groups

## You can match the group number with hospital with the data we use
id.group <- data %>% 
  select(V20, trt) %>%
  unique()
hsd.out$groups.id <- merge(id.group, hsd.out$groups, by = "trt")
hsd.out$groups.id


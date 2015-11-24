library(dplyr)
library(agricolae)

# Load data
wi_dem2 = read.csv("wi_dem2.tab", sep="\t", header=FALSE)
hospitals = unique(wi_dem2[, 20])

grouped_by_hospital = wi_dem2 %>% 
  group_by(V20) %>%
  select(drug_name = V8, generic_name = V9) 

bg_ratios = summarise(grouped_by_hospital, 
          bg_ratio = 
            sum(as.vector(drug_name) != as.vector(generic_name)) / length(drug_name))

hist(bg_ratios$bg_ratio)

## Doing T-test

## Create an treatment record for HSD test
data <-grouped_by_hospital
data <- cbind(data,id=factor(data$V20,labels=1:length(unique(data$V20))))
## Do LSD & HSD test
model <- aov(as.numeric(as.vector(drug_name)==as.vector(generic_name)) ~ id, 
             data = data)
lsd.out <- LSD.test(model, "id", p.adj = "bonferroni")
hsd.out <- HSD.test(model,"id", group = T)

bar.group(lsd.out$groups,ylim=c(0,45),density=4,border="blue")
bar.group(hsd.out$groups,ylim=c(0,45),density=4,border="blue")

lsd.out$groups
hsd.out$groups

## You can match the group number with hospital with the data we use
id.group <- data %>% 
  select(V20, id) %>%
  unique()

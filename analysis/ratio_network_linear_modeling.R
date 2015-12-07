#Linear modelling on data

library(data.table)
library(dplyr)
library(agricolae)
library(igraph)

#Import data
phy_drugs = fread("wi_cardi2.tab", sep="\t", header=FALSE)
hospitals = unique(phy_drugs[, 20])
setkey(phy_drugs,V1)
phy_drugs = phy_drugs[`V9`=="METOPROLOL SUCCINATE"]

#First aggregate ratios over physicians 
grouped_by_physician = phy_drugs %>% 
  group_by(V1) %>%
  select(drug_name = V8, generic_name = V9, total_claim_cnt = V11) 

#Calculates ratios based on number of brand name vs total claims
phy_bg_ratios = summarise(grouped_by_physician, 
                          bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
)

phy_bg_ratios$hospital <- phy_drugs[.(phy_bg_ratios$V1), mult = "first"]$V20

#Consider graph and its corresponding adjacency matrix
wi_card = wi[unique(as.character(phy_drugs$V1))]
setkey(Ewi,V1)
Ewi = Ewi[unique(wi_card$NPI)]  # so cool! and fast!
setkey(Ewi,V2)
tmp = Ewi[unique(wi_card$NPI)]  # so cool! and fast!
Ewi = tmp[complete.cases (tmp)]  #lots of NA's.  Have not inspected why.
el=as.matrix(Ewi)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.

# Fit model of rr to Av, where rr correlates NPI[i] to NPI[j]'s ratio
Av = as.vector(get.adjacency(graph = g))
r = as.vector(phy_bg_ratios[.(as.integer(V(g)$name))]$bg_ratio)
rr = as.vector(outer(r,r))
model = lm(rr ~ Av)

#For P value calculations
if (FALSE) {
  rrb = as.vector(outer(sample(r)))
  lm(rrb ~ Av)
}
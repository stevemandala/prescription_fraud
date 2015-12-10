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
E(g)$weight=as.numeric(Ewi$V3)

# Fit model of rr to Av, where rr correlates NPI[i] to NPI[j]'s ratio
Av = as.matrix(get.adjacency(graph = g, attr="weight")) #
L = as.matrix(graph.laplacian(g))
D = matrix(data=0,nrow = length(r),ncol = length(r))
for (i in 1:length(r)){
  D[i,i] = sum(Av[i,])
} 
D = solve(D)

r = as.vector(phy_bg_ratios[.(as.integer(V(g)$name))]$bg_ratio)
#rr = as.vector(outer(r,r))
rr = matrix(nrow = length(r),ncol = length(r))
for (i in 1:length(r)){
  for (j in 1:length(r)){
    #rr[i,j] = (r[i]-r[j])^2
    rr[i,j] = (r[i]-r[j])^2
  }
}
D = matrix(data=0,nrow = length(r),ncol = length(r))
for (i in 1:length(r)){
  D[i,i] = sum(Av[i,])
  if (D[i,i]==0) {
    D[i,i]=1
  }
} 
Di = solve(D)
Lsym = sqrt(Di)%*%L%*%sqrt(Di)
rr = as.matrix(rr)
model = lm(as.vector(rr) ~ as.vector(Av))
modelL = lm(as.vector(rr) ~ as.vector(Lsym))

peerR = Di%*%Av%*%r
modelM = lm(r ~ peerR)

#For P value calculations
if (FALSE) {
  rrb = as.vector(outer(sample(r)))
  lm(rrb ~ Av)
}
#


# Load package
require(ggplot2)

## An example of how to visualize lm model

## plot with basic package
plot(as.vector(r) ~ as.vector(peerR))
abline(modelM)

## plot withm ggplot
ggplot(model, aes(x = as.vector(peerR), y = as.vector(r))) +
  geom_point() +
  stat_smooth(method = "lm") + ggtitle("B/G Ratio vs Weighted Mean Peer B/G Ratio (for MS)") +
  labs(x="Mean Peer B/G Ratio",y="Physician Ratio")
  

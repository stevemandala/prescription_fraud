#Linear modelling on data
# Load package
library(ggplot2)
library(data.table)
library(dplyr)
library(agricolae)
library(igraph)

b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
wi = fread("wi_DT.txt",colClasses = b)
setkey(wi, NPI)
Ewi = fread("wi_Et.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Ewi, V1)

#Import data
phy_drugs = fread("wi_cardi2.tab", sep="\t", header = FALSE)
hospitals = unique(phy_drugs[, 20])
setkey(phy_drugs,V1)
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

#Consider graph and its corresponding adjacency matrix
wi_card = wi[unique(as.character(phy_drugs$V1))]
setkey(Ewi,V1)
Ewi = Ewi[unique(as.character(phy_drugs$V1))]  # so cool! and fast!
setkey(Ewi,V2)
Ewi = Ewi[unique(as.character(phy_drugs$V1))]  # so cool! and fast!
Ewi = Ewi[complete.cases (Ewi)]  #lots of NA's.  Have not inspected why.
el=as.matrix(Ewi)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.
E(g)$weight=as.numeric(Ewi$V3)

# Calculate models over npis and peers
# Graph matrices (weighted)
numNPI = length(V(g))
A_w = as.matrix(get.adjacency(graph = g)) #, attr="weight"
L_w = as.matrix(graph.laplacian(g))
D_w = matrix(data=0,nrow = numNPI,ncol = numNPI)
for (i in 1:numNPI){
  D_w[i,i] = sum(A_w[i,])
  if (D_w[i,i]==0) {
    D_w[i,i]=1
  }
} 
D_w = solve(D_w)

#Weighted sum of peer ratios matrix
r = as.vector(phy_bg_ratios[.(as.integer(V(g)$name))]$bg_ratio)
peerR_w = D_w%*%A_w%*%r
model_peerR_w = lm(r ~ peerR_w)

## An example of how to visualize lm model

## plot with basic package
plot(as.vector(r) ~ as.vector(peerR_w))
abline(model_peerR_w)


#Calculate matrices (unweighted)
A_u = as.matrix(get.adjacency(graph = g)) #
L_u = as.matrix(graph.laplacian(g), weight = NA)
D_u = matrix(data=0,nrow = numNPI,ncol = numNPI)
for (i in 1:numNPI){
  D_u[i,i] = sum(A_u[i,])
  if (D_u[i,i]==0) {
    D_u[i,i]=1
  }
} 
D_u = solve(D_u)

#Weighted sum of peer ratios matrix
r = as.vector(phy_bg_ratios[.(as.integer(V(g)$name))]$bg_ratio)
peerR_u = D_u%*%A_u%*%r
model_peerR_u = lm(r ~ peerR_u)

## An example of how to visualize lm model

## plot with basic package
plot(as.vector(r) ~ as.vector(peerR_u))
abline(model_peerR_u)

#rr = as.vector(outer(r,r))
rr = matrix(nrow = length(r),ncol = length(r))
for (i in 1:length(r)){
  for (j in 1:length(r)){
    #rr[i,j] = (r[i]-r[j])^2
    rr[i,j] = (r[i]-r[j])^2
  }
}

Lsym = sqrt(Di)%*%L%*%sqrt(Di)
rr = as.matrix(rr)
model = lm(as.vector(rr) ~ as.vector(Av))
modelL = lm(as.vector(rr) ~ as.vector(Lsym))


modelM = lm(r ~ peerR)

#For P value calculations
if (FALSE) {
  rrb = as.vector(outer(sample(r)))
  lm(rrb ~ Av)
}
#

## plot with basic package
plot(as.vector(r) ~ as.vector(peerR))
abline(modelM)

## plot withm ggplot
ggplot(model, aes(x = as.vector(peerR), y = as.vector(r))) +
  geom_point() +
  stat_smooth(method = "lm") + ggtitle("B/G Ratio vs Weighted Mean Peer B/G Ratio (for MS)") +
  labs(x="Mean Peer B/G Ratio",y="Physician Ratio")
  

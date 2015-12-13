#Linear modelling on data
# Load package
library(ggplot2)
library(data.table)
library(dplyr)
library(agricolae)
library(igraph)

b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
wi = fread("ny_DT.txt",colClasses = b)
setkey(wi, NPI)
Ewi = fread("ny_Et.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Ewi, V1)
wi_card = wi[like(`Primary specialty`,"CARDIOLOGY")] 

#Import data
cc = c(rep("character",46))
phy_drugs_sum = fread("PARTD_PRESCRIBER_PUF_NPI_13.tab", colClasses = cc)
phy_drugs_sum = phy_drugs_sum[NPI %in% unique(wi$NPI)]
# phy_bg_ratios = phy_drugs_sum %>% 
#   group_by(NPI) %>%
#   select(brand_cnt = as.numeric(BRAND_CLAIM_COUNT), generic_cnt = GENERIC_CLAIM_COUNT, total_cnt = TOTAL_CLAIM_COUNT) 

phy_bg_ratios = data.table(NPI=phy_drugs_sum$NPI,
                brand_cnt = as.numeric(phy_drugs_sum$BRAND_CLAIM_COUNT),
                generic_cnt = as.numeric(phy_drugs_sum$GENERIC_CLAIM_COUNT),
                total_cnt = as.numeric(phy_drugs_sum$TOTAL_CLAIM_COUNT))
tmp = is.na(phy_bg_ratios$brand_cnt)
phy_bg_ratios[tmp]$brand_cnt <- phy_bg_ratios[tmp]$total_cnt - phy_bg_ratios[tmp]$generic_cnt
phy_bg_ratios$bg_ratio = phy_bg_ratios$brand_cnt/phy_bg_ratios$total_cnt
setkey(phy_bg_ratios, NPI)
phy_bg_ratios=phy_bg_ratios[!is.na(phy_bg_ratios$bg_ratio)]


#Consider graph and its corresponding adjacency matrix
phy_bg_ratios = phy_bg_ratios[NPI %in% unique(wi_card$NPI)]
wi_card = wi[NPI %in% unique(as.character(phy_bg_ratios$NPI))]
setkey(Ewi,V1)
Ewi = Ewi[unique(wi_card$NPI)]  # so cool! and fast!
setkey(Ewi,V2)
tmp = Ewi[unique(wi_card$NPI)]  # so cool! and fast!
Ewi = tmp[complete.cases (tmp)]  #lots of NA's.  Have not inspected why.
el=as.matrix(Ewi)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.
E(g)$weight=as.numeric(Ewi$V3)

# Calculate models over npis and peers
# Graph matrices (weighted)
numNPI = length(V(g))
A_w = as.matrix(get.adjacency(graph = g, attr="weight")) #
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
r = as.vector(phy_bg_ratios[as.character(V(g)$name)]$bg_ratio)
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
r = as.vector(phy_bg_ratios[as.character(V(g)$name)]$bg_ratio)
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
  


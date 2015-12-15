#Spectral Clustering

rm(list = ls())
library(Matrix)
library(igraph)
library(data.table)
library(rARPACK)
library(zipcode)

#Loads the referral data if necessary
if (FALSE) {
  source("load_wi_data.R")
}


b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
wi = fread("wi_DT.txt",colClasses = b)
setkey(wi, NPI)
Ewi = fread("wi_Et.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Ewi, V1)

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


# Create matrix and graph
set.seed(1)
el=as.matrix(Ewi)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.
# set.seed(1)
# el=as.matrix(Ewi)[,1:2] #igraph needs the edgelist to be in matrix format
# g=graph.edgelist(el,directed = F) # this creates a graph.

#Coreness pruning (optional)
if (FALSE) {
  core = graph.coreness(g, mode = "all")
  g = induced.subgraph(g,vids = V(g)[core>=5])
  clust = clusters(g, mode = "weak")
  table(clust$csize)
}

#Generates adjacency matrix and eigenvectors
A = get.adjacency(g)
vec = eigs(A,k = 50)  # So fast!

locs = layout.auto(g)

r = as.vector(phy_bg_ratios[.(as.integer(V(g)$name))]$bg_ratio)

colorEig = as.numeric(vec$vec[,2]>0)+2*as.numeric(vec$vec[,3]>0)

plot(g, vertex.label = NA, vertex.color = as.factor(colorEig), layout = locs)

A = get.adjacency(g, attr="weight")
A = A + t(A) # make it symmetric, but get rid of direction
vec = eigs(A,k = 50)  # So fast!

locs = layout.auto(g)
npiInRef = unlist(get.vertex.attribute(g), use.names = F)
# mark out the nodes in AURORA
plot(g, vertex.label = NA, vertex.color = as.factor(npiInRef %in% npi_aurora), layout = locs, vertex.size=3)
# mark out the nodes according to eigen vector
plot(g, vertex.label = NA, vertex.color = as.factor(vec$vec[,4]>0), layout = locs, vertex.size=3)

#TODO: Gray scale the data on bg ratio

# data(zipcode)
# zipcode = as.data.table(zipcode); setkey(zipcode, zip)
# loc = zipcode[rownames(A), c("longitude", "latitude"), with  =F]
# for(i in 2:10) plot(loc, col=as.factor(vec$vec[,i]>0),
#                     xlim = c(-125, -65), ylim = c(24, 50), main = i)
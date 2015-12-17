## Wi_referral
## Load packages
require(data.table)
require(Matrix)
require(igraph)
require(plyr)
require(dplyr)
## Load data
setwd("F:/Academic/Stat 992/group project/prescription_fraud/")
wi <- fread("analysis.py/referral_wi.csv")
wi <- as.data.frame(wi)
nrow(wi)
sum(wi[,7] == 1)
wi[,1] <- as.character(wi[,1])
wi[,2] <- as.character(wi[,2])
wi <- wi %>% select(-V4, - V5)
names(wi) <- c("npi1", "npi2", "weight", "wi1", "wi2")

## Create graph
el <- wi %>% filter(wi2 == 1) 
el=as.matrix(el)
g=graph.edgelist(el[,1:2], directed = TRUE)
E(g)$weight=as.numeric(el[,3])
core = graph.coreness(g)  # core.
g1 = induced.subgraph(graph = g,vids = V(g)[core>10])  # induced subgraphs.
#plot(g1, vertex.label = NA)

el1 <- wi
el1 <- as.matrix(el1)
g = graph.edgelist(el1[,1:2], directed = T)
E(g)$weight = as.numeric(el1[,3])
core1 = graph.coreness(g)
g2 = induced.subgraph(graph = g, vids = V(g)[core > 10])

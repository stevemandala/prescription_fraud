#Spectral Clustering

library(Matrix)
library(igraph)
library(data.table)
library(rARPACK)
library(zipcode)

# Data Parsing
Et = fread("physician-referrals-2014-days365.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Et, V1)
head(Et)
b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("National_Downloadable_File.csv",colClasses = b)
names(DT)[1] <- c("NPI")
setkey(DT, NPI)
rm(b)
wi = DT[State == "WI"]
tmp = Et[unique(mad$NPI)]  # so cool! and fast!
Emad = tmp[complete.cases (tmp)]  #lots of NA's.  Have not inspected why.
el=as.matrix(Emad)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.
# original graph is directed.  For now, ignore direction.

set.seed(1)
rm(list = ls())
load(url("http://pages.stat.wisc.edu/~karlrohe/netsci/data/zipA.RData"))
dim(A)

g = graph.adjacency(A,mode = "directed", weighted = T)
clust = clusters(g, mode = "weak")
table(clust$csize)

#Coreness pruning (optional)
core = graph.coreness(g, mode = "all")
hist(core)
g = induced.subgraph(g,vids = V(g)[core>=5])
clust = clusters(g, mode = "weak")
table(clust$csize)

A = get.adjacency(g)
vec = eigs(A,k = 50)  # So fast!

data(zipcode)
zipcode = as.data.table(zipcode); setkey(zipcode, zip)
loc = zipcode[rownames(A), c("longitude", "latitude"), with  =F]
for(i in 2:10) plot(loc, col=as.factor(vec$vec[,i]>0),
                    xlim = c(-125, -65), ylim = c(24, 50), main = i)
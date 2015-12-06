#Spectral Clustering

library(Matrix)
library(igraph)
library(data.table)
library(rARPACK)
library(zipcode)

#Loads the referral data if necessary
if (FALSE) {
  source("load_wi_data.R")
}

# Create matrix and graph
set.seed(1)
el=as.matrix(Ewi)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.


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
plot(g, vertex.label = NA, vertex.color = as.factor(vec$vec[,3]>0), layout = locs)

#TODO: Gray scale the data on bg ratio

# data(zipcode)
# zipcode = as.data.table(zipcode); setkey(zipcode, zip)
# loc = zipcode[rownames(A), c("longitude", "latitude"), with  =F]
# for(i in 2:10) plot(loc, col=as.factor(vec$vec[,i]>0),
#                     xlim = c(-125, -65), ylim = c(24, 50), main = i)
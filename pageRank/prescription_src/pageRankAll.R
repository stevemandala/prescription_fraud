# Page Rank on prescription data
# Treats every drug entry in vector uniquely in vector

library(plotrix)
library(data.table)
library(igraph)
phy_drugs = read.csv("wi_dem2.tab", sep="\t", header=FALSE)
phy_drugs = as.data.table(phy_drugs)
setkey(phy_drugs, 'V1')
npis = unique(phy_drugs$V1)

edgel = matrix(ncol=2)
for (i in 1:length(npis)) {
  npi1 = npis[i]
  drug_list1 = phy_drugs[`V1`==npi1]
  setkey(drug_list1,'V8')
  norm1 = sqrt(sum(drug_list1$V11^2))
  for (j in 1:length(npis)) {
    if (i==j)
      next
    npi2 = npis[j]
    drug_list2 = phy_drugs[`V1`==npi2]
    setkey(drug_list2,'V8')
    norm2 = sqrt(sum(drug_list2$V11^2))
    commonDrugs1 = drug_list1[`V8` %in% drug_list2$V8]
    commonDrugs2 = drug_list2[`V8` %in% drug_list1$V8]
    sim = sum(commonDrugs1$V11 * commonDrugs2$V11)/(norm1*norm2)
    if (sim >= 0.85 && NROW(commonDrugs1) >= 2) {
      edgel <- rbind(edgel,c(as.character(npi1),as.character(npi2)))
    }
  }
}

edgel = edgel[-1,]
g = graph.edgelist(edgel)
loc  = layout.fruchterman.reingold(g)
#Plot colored on speciality
plot(g, vertex.label= NA, layout=loc, vertex.color = as.factor(phy_drugs[V(g), mult="first"]$V6))

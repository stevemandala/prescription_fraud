# Generates a similarity matrix based on the b/g prescribing ratio
# and applies clustering on this matrix, finding covariates tied to
# similar b/g ratios

library(plotrix)
library(data.table)
library(igraph)
library(rARPACK)
library(kernlab)

phy_drugs = fread("wi_cardi2.tab", sep="\t", header=FALSE)
phy_drugs = as.data.table(phy_drugs)
setkey(phy_drugs, 'V1')
npis = unique(phy_drugs$V1)

#Generates a cosine similarity matrix across all drugs
sim_matrix <- matrix(data=NA, nrow = length(npis), ncol = length(npis))
for (i in 1:length(npis)) {
  npi1 = npis[i]
  drug_list1 = phy_drugs[`V1`==npi1]
  setkey(drug_list1,'V8')
  norm1 = sqrt(sum(drug_list1$V11^2))
  for (j in 1:length(npis)) {
    if (i==j) {
      sim_matrix[i,j] = 1
      next
    }
    npi2 = npis[j]
    drug_list2 = phy_drugs[`V1`==npi2]
    setkey(drug_list2,'V8')
    norm2 = sqrt(sum(drug_list2$V11^2))
    commonDrugs1 = drug_list1[`V8` %in% drug_list2$V8]
    commonDrugs2 = drug_list2[`V8` %in% drug_list1$V8]
    sim_matrix[i,j] = sum(commonDrugs1$V11 * commonDrugs2$V11)/(norm1*norm2)
    
  }
}
write.matrix(sim_matrix,file="sim_mat_allDrugs.txt", sep=",")

lap = diag(x=length(npis),nrow = length(npis),ncol = length(npis)) - sim_matrix

eig_vecs = eigen(lap, symmetric = TRUE)

sc <- specc(sim_matrix,centers = 3)

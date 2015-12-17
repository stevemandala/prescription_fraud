## BPR in wi_referral
setwd("F:/Academic/Stat 992/group project/prescription_fraud/analysis")
source("wi_referral.R")

# Load BPR data
full <- fread("npi_full.csv", header = T)
locs = layout.fruchterman.reingold(g1)

# select the npi appears in g1(the induced.graph with core > 10)
npi_graph <- full %>% filter(NPI %in% as.integer(V(g1)$name))
BPR <- npi_graph$b.g.with.claim


gcolor = gray(1-(BPR-min(BPR))/(max(BPR)-min(BPR)))
BPR_wi_referral <- plot(g1, vertex.label = NA, vertex.color = gcolor,
                        layout = locs, main = "subgraph with coreness larger than 10")

## clust
clust = clusters(g1)
tmp = induced.subgraph(graph = g1,vids = (clust$mem ==2))
plot(tmp, vertex.label = NA, vertex.color = gcolor, layout = locs)





####################################################
#Further consideration

# use hospital as the color

#partD_npi <- read.csv("F:/Academic/Stat 992/group project/prescription_fraud/analysis.py/NPI_bg.csv", header = T)
# select the npi appears in g1(the induced.graph with core > 10)
npi_rank1 <- full %>% filter(NPI %in% as.integer(V(g1)$name))
gcolor.hos <- npi_rank1$hospital
BPR_wi_hos <- plot(g1, vertex.label = NA, vertex.color = as.factor(gcolor.hos), layout = locs)


## color with total drug cost
drug.cost <- npi_rank1$TOTAL_DRUG_COST
gcolor.cost = gray(1-(drug.cost-min(drug.cost))/(max(drug.cost)-min(drug.cost)))
BPR_wi_cost <- plot(g1, vertex.label = NA, vertex.color = gcolor.cost, layout = locs)

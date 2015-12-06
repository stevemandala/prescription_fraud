library(igraph)
library(data.table)

b= c(rep("character", 6),rep("factor",4), "numeric", rep("factor",6), "character", "character", "character", "numeric", rep("character",2), "factor", "character", "factor", "character", rep("character", 10), rep("factor", 6))
DT = fread("../data/National_Downloadable_File.csv",colClasses = b)
names(DT)[1] <- c("NPI")
setkey(DT, NPI)
DT_hosp = DT[`State`=="WI" & `Organization DBA name`=="UW MEDICAL FOUNDATION"]

phy_drug_main = fread("PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab")
# phy_drug = phy_drug_main[`NPPES_PROVIDER_STATE`=='WI' 
#                     & `NPPES_PROVIDER_CITY`== 'MADISON']
#                    # & (`SPECIALTY_DESC`=="Internal Medicine" | `SPECIALTY_DESC`=="Cardiology")]

phy_drug = phy_drug_main[`NPI` %in% DT_hosp$NPI]

Et = fread("physician-referrals-2014-days365.txt",sep = ",",  colClasses = c("character", "character","numeric", "numeric", "numeric"))
setkey(Et,V1)

Emad = Et[V1 %in% unique(phy_drug$NPI)]
Emad = Emad[V2 %in% unique(phy_drug$NPI)]

el=as.matrix(Emad)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F) # this creates a graph.
# original graph is directed.  For now, ignore direction.
g = simplify(g)
loc  = layout.fruchterman.reingold(g)
plot(g, vertex.label= NA, layout=loc, vertex.color = as.factor(phy_drug[V(g), mult="first"]$SPECIALTY_DESC))


grouped_by_physician = phy_drugs %>% 
  group_by(NPI) %>%
  select(drug_name = DRUG_NAME, generic_name = GENERIC_NAME, total_claim_cnt = TOTAL_CLAIM_COUNT) 

#Calculates ratios based on number of brand name vs total claims
phy_bg_ratios = summarise(grouped_by_physician, 
                          bg_ratio = (sum(as.vector(total_claim_cnt[as.vector(drug_name) != as.vector(generic_name)]))/sum(as.vector(total_claim_cnt)))
)

hist(phy_bg_ratios$bg_ratio)


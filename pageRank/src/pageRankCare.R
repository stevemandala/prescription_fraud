source("loadData.R")
library(plotrix)

PhyPay$line_srvc_cnt <- as.numeric(PhyPay$line_srvc_cnt)
PhyPay$average_Medicare_allowed_amt <- as.numeric(sub("\\$","", PhyPay$average_Medicare_allowed_amt))
PhyPay$average_submitted_chrg_amt <- as.numeric(sub("\\$","", PhyPay$average_submitted_chrg_amt))
PhyPay$average_Medicare_payment_amt <- as.numeric(sub("\\$","", PhyPay$average_Medicare_payment_amt))
PhyPay$diff <-PhyPay$average_submitted_chrg_amt - PhyPay$average_Medicare_allowed_amt
PhyPay$bene_day_srvc_cnt = as.numeric(PhyPay$bene_day_srvc_cnt)

# PhyPay = PhyPay[!is.na(PhyPay$bene_unique_cnt)]
# PhyPay = PhyPay[!is.na(PhyPay$hcpcs_code)]
# PhyPay = PhyPay[!is.na(PhyPay$provider_type)]
# PhyPay = PhyPay[!is.na(PhyPay$npi)]

PhyPay = PhyPay[complete.cases(PhyPay)]

#Only consider most commonly billed service
grp = unique(PhyPay$npi)
pts=PhyPay[order(PhyPay$npi, PhyPay$bene_day_srvc_cnt, decreasing = TRUE)]
setkey(pts, npi)
#pts=pts[!duplicated(pts$npi)]

el = matrix(ncol=2)
for (i in 1:length(grp[1:100])) {
  npi1 = grp[i]
  cpt_list = pts[`npi`==npi1]
  setkey(cpt_list,hcpcs_code)
  norm1 = sqrt(sum(cpt_list$bene_day_srvc_cnt^2))
  for (j in 1:length(grp[1:100])) {
    if (i==j)
      next
    npi2 = grp[j]
    cpt_list2 = pts[`npi`==npi2]
    setkey(cpt_list2,hcpcs_code)
    norm2 = sqrt(sum(cpt_list$bene_day_srvc_cnt^2))
    mapCPT = cpt_list2[cpt_list$hcpcs_code]
    mapCPT[is.na(mapCPT$bene_day_srvc_cnt)]$bene_day_srvc_cnt=0
    sim = sum(cpt_list$bene_day_srvc_cnt * mapCPT$bene_day_srvc_cnt)/(norm1*norm2)
    if (sim >= 0.85 && NROW(mapCPT) >= 2) {
     el <- rbind(el,c(npi1,npi2))
    }
  }
}
el = el[-1,]
g = graph.edgelist(el,directed = F)
loc  = layout.fruchterman.reingold(g)
#Plot colored on speciality
plot(g, vertex.label= NA, layout=loc, vertex.color = as.factor(pts[V(g), mult="first"]$provider_type))

specialities = unique(PhyPay[V(g)]$provider_type)
s =  specialities[3]
perVec = 1*((PhyPay[V(g)]$provider_type == s))
pageSol = page.rank(g, directed = F, personalized = perVec)
typeof(pageSol$vector[1])



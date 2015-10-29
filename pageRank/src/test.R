source("loadData.R")
library(plotrix)

PhyPay$line_srvc_cnt <- as.numeric(sub("\\$","", PhyPay$line_srvc_cnt))
PhyPay$average_Medicare_allowed_amt <- as.numeric(sub("\\$","", PhyPay$average_Medicare_allowed_amt))
PhyPay$average_submitted_chrg_amt <- as.numeric(sub("\\$","", PhyPay$average_submitted_chrg_amt))
PhyPay$average_Medicare_payment_amt <- as.numeric(sub("\\$","", PhyPay$average_Medicare_payment_amt))
PhyPay$diff <-PhyPay$average_submitted_chrg_amt
PhyPay[is.na(PhyPay$diff)] = 0
tmpMin = min(PhyPay$diff)
tmpMax = max(PhyPay$diff)
PhyPay$diffScale = 1-(PhyPay$diff-min(PhyPay$diff))/(max(PhyPay$diff)-min(PhyPay$diff))

# Physcician (non-institutional)
BosPay = PhyPay
BosPay = BosPay[nppes_provider_state=="MA"]
BosPay = BosPay[nppes_provider_city=="BOSTON"]
BosDT = DT[unique(BosPay$npi)]
setkey(BosDT,NPI)
BosEt = Et[unique(BosDT$NPI)]
BosEt = BosEt[complete.cases(BosEt)]


el=as.matrix(BosEt)[,1:2] #igraph needs the edgelist to be in matrix format
g=graph.edgelist(el,directed = F)
g= simplify(g)  # removes any self loops and multiple edges
core = graph.coreness(g)  # talk about core.
g1 = induced.subgraph(graph = g,vids = V(g)[core>1])  # talk about induced subgraphs.

locs = layout.fruchterman.reingold(g1)

#Color on cost
PhyCost = PhyPay[V(g1)]$average_Medicare_payment_amt 
PhyCost[is.na(PhyCost)] = 0
gcolor = gray(rescale(PhyCost,c(0,1)))
plot(g1, vertex.label = NA, vertex.color = gcolor , layout = locs)

#Color of diff scale
PhyPay[V(g1)]$diffScale[is.na(PhyPay[V(g1)]$diffScale)] = 0
gcolor = gray(PhyPay[V(g1)]$diffScale)
plot(g1, vertex.label = NA, vertex.color = gcolor , layout = locs)

clust = clusters(g)
tmp = induced.subgraph(g = g,vids = (clust$mem ==6))
PhyPay[V(tmp)]$diffScale[is.na(PhyPay[V(tmp)]$diffScale)] = 0
gcolor = gray(PhyPay[V(tmp)]$diffScale)
plot(tmp, vertex.label = NA, vertex.color = gcolor , layout = locs)

-sort(-table())[1:10]

#Graph colored on difference between allowed and average Medicare 
#Geographic overlay
library(maps); library(ggplot2)
library(ggmap)

zip = BosDT[BosPay$npi, mult='first']$"Zip Code"
zip = substr(zip, start = 1, stop = 5)

data(zipcode)  # this contains the locations of zip codes
zipcode = as.data.table(zipcode); setkey(zipcode, zip)  # thanks data.table for making things so fast!  
loc =  zipcode[zip, c("latitude", "longitude"), with = F]
loc = loc[complete.cases(loc)]
loc = as.matrix(loc)

#Plots data against aver medicare payment amt
PhyCost = BosPay$average_submitted_chrg_amt 
PhyCost[is.na(PhyCost)] = 0
gcolor = gray(rep(1,length(PhyCost))-rescale(PhyCost,c(0,1)))
#
library(maps); 
plot(loc[,2], loc[,1], col = gcolor, xlim = c(-71.1, -70.8), ylim = c(42.2,42.6))
map('state', region = c('massachusetts'), add = T)  # adds an outline

# or, you might like this version:
# install.packages("ggmap")
map <- get_map(location = 'Massachusetts',zoom=8)
df <- data.frame(lon=loc[,2], lat = loc[,2])
ggmap(map) + geom_point(aes(x = loc[,2], y = loc[,1]), data=df) + scale_fill_manual(values = gColor)

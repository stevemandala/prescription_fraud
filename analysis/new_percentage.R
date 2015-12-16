# This document gives how much percentage the new drug cost occupies.

## Load package
require(data.table)
require(plyr)
require(dplyr)
require(ggplot2)
## Load data
setwd("F:/Academic/Stat 992/group project/prescription_fraud")
partD.new <- fread("PartD_newDrug.csv")
partD_npi <- read.csv("analysis.py/NPI_bg.csv", header = T)

## Calculate the new drug cost over State
cost.new <- partD.new %>%
  group_by(NPPES_PROVIDER_STATE) %>%
  dplyr::summarize(cost.new = sum(TOTAL_DRUG_COST))
## Calculate the overall drug cost over State
cost.all <- partD_npi %>%
  group_by(NPPES_PROVIDER_STATE) %>%
  dplyr::summarize(cost.all = sum(TOTAL_DRUG_COST))
## merge those two data.frame
cost.new$NPPES_PROVIDER_STATE <- as.character(cost.new$NPPES_PROVIDER_STATE)
cost.all$NPPES_PROVIDER_STATE <- as.character(cost.all$NPPES_PROVIDER_STATE)
cost <- plyr::join(cost.new, cost.all, by = "NPPES_PROVIDER_STATE") %>%
  mutate(percentage = cost.new / cost.all) %>%
  mutate(NPPES_PROVIDER_STATE = reorder(x = NPPES_PROVIDER_STATE, 
                                        X = percentage, min)) %>%
  arrange(., desc(percentage))

## Plot a heatmap
######################################################
source("./analysis/heatmap.R")
## Plot USA map
heatmap <- function(x){
  states <- map_data("state")
  map.df <- merge(states,x, by="region", all.x=T)
  map.df <- map.df[order(map.df$order),]
  
  myPlot <- ggplot(map.df, aes(x=long,y=lat,group=group))+
    geom_polygon(aes(fill= percentage))+
    geom_path()+ 
    scale_fill_gradientn(colours=rev(heat.colors(20)),na.value="grey90")+
    geom_text(aes(x=longitude, y=latitude, label=NPPES_PROVIDER_STATE), 
              size=3) +
    ggtitle("Heatmap: Percentage of new drugs cost over States")
  coord_map()
  
  
  
  myPlot
  return(myPlot)
}


## Draw without weight
cost <- as.data.frame(cost)
y <- dropArea(cost)
y <- Low(y, state = state)
y <- loc(y, location)
heatmap_cost <- heatmap(y)
print(heatmap_cost)
ggsave(filename = "heatmap_new_cost_percent.png", plot = heatmap_cost, path = ".",  
       width = 8, height = 6, dpi = 300)
#####################################
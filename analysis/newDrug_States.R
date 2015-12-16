##Where those physicians' from?

#####################################################
# Load packages
require(data.table)
require(ggplot2)
require(plyr)
require(dplyr)
require("XML")

# Download and Load PartD_newDrug.csv
setwd("F:/Academic/Stat 992/group project/prescription_fraud")
partD.new <- fread("PartD_newDrug.csv")

############################################################
# Where are those physicians from? Usage

#usage <- partD.new %>% ddply(~NPPES_PROVIDER_STATE, function(x){length(x$NPI)})
usage <- partD.new %>%
  dplyr::group_by(NPPES_PROVIDER_STATE) %>% 
  dplyr::summarise(usage = sum(TOTAL_CLAIM_COUNT))

# Arrange and reorder the data
usage <- usage %>%
  dplyr::mutate(state.reorder = reorder(x = NPPES_PROVIDER_STATE,
                                        X = usage, FUN = min)) %>%
  dplyr::arrange(., desc(usage))



usagePlot <- ggplot(usage, aes(x = state.reorder, y = usage)) +
  geom_point(aes(color = state.reorder)) +
  geom_text(aes(label = paste0(state.reorder), x = state.reorder, y = usage, 
                color = state.reorder), size = 3) +
  ggtitle("New Drug usage over States")
cat("The total new drug total usage over States \n")
print(usagePlot)
## Save the plot as "newDrug_Usage_plot_state.png"
ggsave(filename = "newDrug_Usage_plot_state.png", plot = usagePlot, path = ".",  
       width = 8, height = 8, dpi = 300)

#####################################################
## heatmap
# get the abbreviation and full name online
URL <- "http://state.1keydata.com/state-abbreviations.php"
tables = readHTMLTable(URL, stringsAsFactors = FALSE)
list <- tables[[2]]
list <- data.frame(full = c(list$V1, list$V3), abb = c(list$V2, list$V4))
state <- list[-27, ][-1, ]
row.names(state) <- 1 : length(state[,1])

## drop the unnecessary areas
dropArea <- function(x, state = state){
  x <- x[which(x$NPPES_PROVIDER_STATE %in% state$abb),]
  row.names(x) <- 1 : length(x$usage)
  return(x)
}

## Make every alphabet to lower case
low <- function(x, state = state, variable = "NPPES_PROVIDER_STATE"){
  index <- grep(pattern = as.character(x[,variable]), state$abb)
  x$region <- state$full[index]
  x$region <- tolower(x$region)
  return(x)
}

Low <- function(data, state = state){  
  y <- data %>% ddply(~NPPES_PROVIDER_STATE, 
                      function(x){low(x, state, "NPPES_PROVIDER_STATE")})
  return(y)
}

# Get Average Latitude and Longitude for US States
location <- read.csv("state_latlon.csv")
names(location)[1] <- c("NPPES_PROVIDER_STATE")

loc <- function(x, location = location){
  x <- merge(x, location, by = "NPPES_PROVIDER_STATE")
  return(x)
}
heatmap_new <- function(x){
  states <- map_data("state")
  map.df <- merge(states,x, by="region", all.x=T)
  map.df <- map.df[order(map.df$order),]
  myPlot <- ggplot(map.df, aes(x=long,y=lat,group=group))+
    geom_polygon(aes(fill= usage))+
    geom_path()+ 
    scale_fill_gradientn(colours=rev(heat.colors(20)),na.value="grey90")+
    geom_text(aes(x=longitude, y=latitude, label=NPPES_PROVIDER_STATE), 
              size=3)+
    ggtitle("New drug use over States")+
    coord_map()
  myPlot
  return(myPlot)
}

## plot
y <- dropArea(usage, state)
y <- Low(y, state = state)
y <- loc(y, location)
heatmap_new <- heatmap_new(y)
print(heatmap_new)
ggsave(filename = "heatmap_new.png", plot = heatmap_new, path = ".",  
       width = 8, height = 6, dpi = 400)


###########################################
############################################

## Next, get the new medicine usage to amount of physicians ratio

############################################

## get the amount of physicians over States
partD_npi <- read.csv("F:/Academic/Stat 992/group project/prescription_fraud/analysis.py/NPI_bg.csv", header = T)
names(partD_npi)
npi_num <- partD_npi %>% group_by(NPPES_PROVIDER_STATE) %>%
  dplyr::summarize(length(NPI))
names(npi_num) <- c("State", "NPI_num")
## merge with y
## doing merge and get the new drug usage to population ratio
y1 <- merge(y, npi_num,  by.y = "State", by.x = "NPPES_PROVIDER_STATE") %>%
  mutate(drug_to_phy = usage / NPI_num) 
heatmap_new1 <- function(x){
  states <- map_data("state")
  map.df <- merge(states,x, by="region", all.x=T)
  map.df <- map.df[order(map.df$order),]
  myPlot <- ggplot(map.df, aes(x=long,y=lat,group=group))+
    geom_polygon(aes(fill= drug_to_phy))+
    geom_path()+ 
    scale_fill_gradientn(colours=rev(heat.colors(20)),na.value="grey90")+
    geom_text(aes(x=longitude, y=latitude, label=NPPES_PROVIDER_STATE), 
              size=3)+
    ggtitle("New drug use over States")+
    coord_map()
  myPlot
  return(myPlot)
}
drug_to_phy_heat <- heatmap_new1(y1)
ggsave(filename = "drug_to_phy_heat.png", drug_to_phy_heat, width = 8, height = 6, 
       dpi = 300)
y2 <- y1 %>% mutate(NPPES_PROVIDER_STATE = reorder(
  x = NPPES_PROVIDER_STATE, X = drug_to_phy)) 
drug_to_phy.plot <- ggplot(y2, aes(x = NPPES_PROVIDER_STATE, y = drug_to_phy)) +
  geom_point(aes(color = drug_to_phy))+
  geom_text(aes(x = NPPES_PROVIDER_STATE, y = drug_to_phy, 
                label = NPPES_PROVIDER_STATE, color = drug_to_phy)) +
  ggtitle("drug to physician amount ratio")
drug_to_phy.plot
ggsave(filename = "drug_to_phy.png", drug_to_phy.plot, width = 8, height = 6, 
       dpi = 300)

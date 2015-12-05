# This document plot a ratio hotmap over States in USA


## Load package
library(plyr)
library(dplyr)
library(ggplot2)
library(maps)
library(XML)

## Load ratio data
ratio_noWeight <- read.csv("ratio_withoutWeight.csv")
ratio_Weight <- read.csv("ratio_withWeight.csv")


## change the data's States from capital Abbreviation to lower case full name
# get the abbreviation and full name online
URL <- "http://state.1keydata.com/state-abbreviations.php"
tables = readHTMLTable(URL, stringsAsFactors = FALSE)
list <- tables[[2]]
list <- data.frame(full = c(list$V1, list$V3), abb = c(list$V2, list$V4))
state <- list[-27, ][-1, ]
row.names(state) <- 1 : length(state[,1])


## drop the unnecessary areas
dropArea <- function(x){
  x <- x[which(x$NPPES_PROVIDER_STATE %in% state$abb),]
  row.names(x) <- 1 : length(x[,1])
  return(x)
}

## Make every alphabet to lower case
low <- function(x, state = state){
  index <- grep(pattern = as.character(x$NPPES_PROVIDER_STATE), state$abb)
  x$region <- state$full[index]
  x$region <- tolower(x$region)
  return(x)
}

Low <- function(data, state = state){
  y <- data %>% ddply(~NPPES_PROVIDER_STATE, function(x){low(x, state)})
  return(y)
}

# Get Average Latitude and Longitude for US States
location <- read.csv("state_latlon.csv")
names(location)[1] <- c("NPPES_PROVIDER_STATE")

loc <- function(x, location = location){
  x <- merge(x, location, by = "NPPES_PROVIDER_STATE")
  return(x)
}



## Plot USA map
heatmap <- function(x){
  states <- map_data("state")
  map.df <- merge(states,x, by="region", all.x=T)
  map.df <- map.df[order(map.df$order),]
  myPlot <- ggplot(map.df, aes(x=long,y=lat,group=group))+
    geom_polygon(aes(fill= bNotG))+
    geom_path()+ 
    scale_fill_gradientn(colours=rev(heat.colors(20)),na.value="grey90")+
    geom_text(aes(x=longitude, y=latitude, label=NPPES_PROVIDER_STATE), 
              size=3) +
    coord_map()
  myPlot
  return(myPlot)
}


## Draw without weight
y <- dropArea(ratio_noWeight)
y <- Low(y, state = state)
y <- loc(y, location)
heatmap_noWeight <- heatmap(y)
print(heatmap_noWeight)
ggsave(filename = "heatmap_withoutWeight.png", plot = last_plot(), path = ".",  
       width = 10, height = 10, dpi = 600)


## Draw and ave with weight
y <- dropArea(ratio_withWeight)
y <- Low(y, state = state)
y <- loc(y, location)
heatmap_weight <- heatmap(y)
print(heatmap_weight)
ggsave(filename = "heatmap_weight.png", plot = last_plot(), path = ".",  
       width = 10, height = 10, dpi = 600)


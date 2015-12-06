##Where those physicians' from?

#####################################################
# Load packages
require(data.table)
require(ggplot2)
require(plyr)
require(dplyr)

# Download and Load PartD_newDrug.csv
setwd("F:/Academic/Stat 992/group project/prescription_fraud")
partD.new <- fread("PartD_newDrug.csv")

############################################################
# Where are those physicians from? Usage

#usage <- partD.new %>% ddply(~NPPES_PROVIDER_STATE, function(x){length(x$NPI)})
usage <- partD.new %>%
  group_by(NPPES_PROVIDER_STATE) %>% 
  summarise(usage = length(.$NPI))

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
       width = 10, height = 10, dpi = 600)

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
heatmap_new <- function(x){
  states <- map_data("state")
  map.df <- merge(states,x, by="region", all.x=T)
  map.df <- map.df[order(map.df$order),]
  myPlot <- ggplot(map.df, aes(x=long,y=lat,group=group))+
    geom_polygon(aes(fill= usage))+
    geom_path()+ 
    scale_fill_gradientn(colours=rev(heat.colors(20)),na.value="grey90")+
    geom_text(aes(x=longitude, y=latitude, label=NPPES_PROVIDER_STATE), 
              size=3) +
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
ggsave(filename = "heatmap_new.png", plot = last_plot(), path = ".",  
       width = 10, height = 10, dpi = 600)

### Functions of heatmap
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

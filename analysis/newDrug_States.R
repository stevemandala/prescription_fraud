##Where those physicians' from?

#####################################################
# Load packages
require(downloader)
require(data.table)
require(ggplot2)
require(plyr)
require(dplyr)

# Download and Load PartD_newDrug.csv
setwd("F:/Academic/Stat 992/group project/prescription_fraud")
partD.new <- fread("PartD_newDrug.csv")
names(partD.new)
#############################################################


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
                color = state.reorder), size = 3)
cat("The total new drug usage over States \n")
print(usagePlot)
## Save the plot as "newDrug_Usage_plot_state.png"
ggsave(filename = "newDrug_Usage_plot_state.png", plot = usagePlot, path = ".",  
       width = 10, height = 10, dpi = 600)





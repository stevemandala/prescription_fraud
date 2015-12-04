# Load package
require(plyr)
require(dplyr)
require(ggplot2)

# Load data
ratio_withoutWeight <- read.csv("ratio_withoutWeight.csv")
ratio_withWeight <- read.csv("ratio_withWeight.csv")

# draw a plot
## doesn't count weight
r <- ratio_withoutWeight %>%
  dplyr::mutate(state.reorder = reorder(x = NPPES_PROVIDER_STATE,
                                        X = bNotG, FUN = min)) %>%
  dplyr::arrange(., desc(bNotG))


ratioPlot <- ggplot(r, aes(x = state.reorder, y = bNotG)) +
  geom_point(aes(color = state.reorder)) +
  geom_text(aes(label = paste0(state.reorder), x = state.reorder, y = bNotG, 
                color = state.reorder), size = 3) +
  ggtitle("Ratio of brand_name and generic_name over States and years")

cat("Ratio of brand_name and generic_name over States and years")
print(ratioPlot)
## Save the plot as "newDrug_Usage_plot_state.png"
ggsave(filename = "ratio_withoutWeight.png", plot = last_plot(), path = ".",  
       width = 10, height = 10, dpi = 600)



## count weight
r <- ratio_withWeight %>%
  dplyr::mutate(state.reorder = reorder(x = NPPES_PROVIDER_STATE,
                                        X = bNotG, FUN = min)) %>%
  dplyr::arrange(., desc(bNotG))


ratioPlot <- ggplot(r, aes(x = state.reorder, y = bNotG)) +
  geom_point(aes(color = state.reorder)) +
  geom_text(aes(label = paste0(state.reorder), x = state.reorder, y = bNotG, 
                color = state.reorder), size = 3) +
  ggtitle("Ratio of brand_name and generic_name over States and years")

cat("Ratio of brand_name and generic_name over States and years")
print(ratioPlot)
## Save the plot as "newDrug_Usage_plot_state.png"
ggsave(filename = "ratio_withWeight.png", plot = last_plot(), path = ".",  
       width = 10, height = 10, dpi = 600)

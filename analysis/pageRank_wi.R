## PageRank of the people in graph
setwd("F:/Academic/Stat 992/group project/prescription_fraud/analysis")
source("wi_referral.R")
require(ggplot2)


# Load BPR data
full <- fread("npi_full.csv", header = T)
########################################
pageRank <- page.rank(g)
pageRank <- data.frame(NPI = names(pageRank$vector), pagerank = pageRank$vector)
pageRank$NPI <- as.integer(as.character(pageRank$NPI))

#partD_npi <- read.csv("F:/Academic/Stat 992/group project/prescription_fraud/analysis.py/NPI_bg.csv", header = T)
# select the npi appears in g1(the induced.graph with core > 10)
npi_rank <- full %>% filter(NPI %in% as.integer(pageRank$NPI))
npi_pageRank <- plyr::join(npi_rank, pageRank, by = "NPI")
npi_pageRank$pagerank <- as.numeric(as.character(npi_pageRank$pagerank))
npi_pageRank <- npi_pageRank %>%
  filter(NPPES_PROVIDER_STATE == "WI")
npi_pageRank$pagerank <- as.numeric(as.character(npi_pageRank$pagerank))
npi_pageRank$pagerank <- npi_pageRank$pagerank/ sum(npi_pageRank$pagerank)
## Pearson and Spearman correlation test
cor.test(npi_pageRank$b.g.with.claim, npi_pageRank$pagerank,  method = "pearson")

## Plot 
pageRank_BPR <- npi_pageRank %>%
  ggplot(aes(x = pagerank, y = b.g.with.claim)) +
  geom_point(aes(colour = hospital)) +
  stat_smooth(method = "lm") +
  guides(colour = F) +
  ggtitle("BPR with pagerank plot") +
  labs(x = "pagerank", y = "BPR")
  
print(pageRank_BPR)
ggsave(filename = "BPR_with_pagerank.png", pageRank_BPR, width = 8, height = 6, dpi = 300)
cor.test(npi_pageRank$b.g.with.claim, npi_pageRank$pagerank,  method = "spearman")
####################################################################
## Relation between pagerank and total drug cost
## Pearson and Spearman correlation test
cor.test(npi_pageRank$TOTAL_DRUG_COST, npi_pageRank$pagerank,  method = "pearson")

## Plot 
pageRank_cost <- npi_pageRank %>%
  ggplot(aes(x = pagerank, y = TOTAL_DRUG_COST)) +
  geom_point(aes(colour = hospital)) +
  stat_smooth(method = "lm") +
  guides(colour = F) +
  ggtitle("Total drug cost with pagerank plot") +
  labs(x = "pagerank", y = "Total drug cost")

print(pageRank_cost)
ggsave(filename = "cost_with_pagerank.png", pageRank_cost, width = 8, height = 6, dpi = 300)

pageRank_cost_wrap <- npi_pageRank %>%
  ggplot(aes(x = pagerank, y = TOTAL_DRUG_COST)) +
  geom_point(aes(colour = hospital)) +
  facet_wrap(~SPECIALTY_DESC) +
  stat_smooth(method = "lm") +
  guides(colour = F) +
  ggtitle("Total drug cost with pagerank plot") +
  labs(x = "pagerank", y = "Total drug cost")

print(pageRank_cost_wrap)
ggsave(filename = "cost_with_pagerank_wrap.png", pageRank_cost_wrap, width = 8, height = 6, dpi = 300)

cor.test(npi_pageRank$TOTAL_DRUG_COST, npi_pageRank$pagerank,  method = "spearman")


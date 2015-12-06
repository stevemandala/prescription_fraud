## Load package
require(data.table)

## load data
r.npi <- read.csv("analysis.py/internalNPI.csv")
referral <- fread("../physician_referrals13-14_inPARTD.csv")
which(r.npi[1:1000,] %in% referral$V1)

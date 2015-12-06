# an aggregated data set over providers. Provides direct data on generics, brand names dispenced

library(data.table)
prov_level = fread("PARTD_PRESCRIBER_PUF_NPI_13.tab")
prov_level = prov_level[!(is.na(prov_level$BRAND_CLAIM_COUNT) | is.na(prov_level$TOTAL_CLAIM_COUNT))]

prov_level$bg_ratio = prov_level$BRAND_CLAIM_COUNT/prov_level$TOTAL_CLAIM_COUNT

setkey(prov_level, NPPES_PROVIDER_STATE)

#Pretty low average brand name/total claim rate
wi_prov_level = prov_level['WI']$BRAND_CLAIM_COUNT/prov_level['WI']$TOTAL_CLAIM_COUNT
hist(wi_prov_level)
mean(wi_prov_level)

#Higher average rate, but within 5%
ny_prov_level = prov_level['NY']$BRAND_CLAIM_COUNT/prov_level['NY']$TOTAL_CLAIM_COUNT
hist(ny_prov_level)
mean(ny_prov_level)

#Higher average rate, 7%+ than WI
nj_prov_level = prov_level['NJ']$BRAND_CLAIM_COUNT/prov_level['NJ']$TOTAL_CLAIM_COUNT
hist(nj_prov_level)
mean(nj_prov_level)

#Spending analysis; does generic correlate with lower costs; looks like Pareto effect of brands and cost
#!/bin/bash
grep "WI\tCardiology" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/wi_cardi.tab
grep "WI\tInternal Medicine" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/wi_im.tab
grep "WI\tDermatology" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/wi_dem.tab

grep "NC\tCardiology" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/nc_cardi.tab
grep "NC\tInternal Medicine" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/nc_im.tab
grep "NC\tDermatology" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/nc_dem.tab

grep "NY\tCardiology" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/ny_cardi.tab
grep "NY\tInternal Medicine" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/ny_im.tab
grep "NY\tDermatology" ../data/PARTD_PRESCRIBER_PUF_NPI_DRUG_13.tab > ../data/ny_dem.tab

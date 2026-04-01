

library(readxl)
library(dplyr)

year_last <- 2025

# Read in data ----

dat <- readxl::read_xlsx("./boot/data/data_from_bm/Herring Assessment Working Group_table_11.1.1.xlsx")
swe_coast <- read.table("./boot/data/swedish_coastal/catch_SWE_spr.27.3aN_coastal_78-24.txt",
                        header = T) 
dat_new <- read.table("./data/catches_div_2024_2026.csv", sep = ",", header = T)

  
# Fix table 11.1 from 2025 HAWG report
names(dat)

unique(dat$Country)

## split and add area ----

mark_div <- which(apply(dat, 1, function(x) any(grepl("Div|Total North Sea and Skagerrak-Kattegat", x))))

dat_sub_1 <- dat[c(mark_div[1]:(mark_div[2]-1)), ]

dat_sub_1[1, 1]$Country

dat_sub_1$area <- "27.4.a"

dat_sub_2 <- dat[c(mark_div[2]:(mark_div[3]-1)), ]

dat_sub_2[1, 1]$Country

dat_sub_2$area <- "27.4.b"

dat_sub_3 <- dat[c(mark_div[3]:(mark_div[4]-1)), ]

dat_sub_3[1, 1]$Country

dat_sub_3$area <- "27.4.c"

dat_sub_4 <- dat[c(mark_div[4]:(mark_div[5]-1)), ]

dat_sub_4[1, 1]$Country

dat_sub_4$area <- "27.3.a"

dat_2 <- bind_rows(dat_sub_1, dat_sub_2, dat_sub_3, dat_sub_4)

dat_sub_5 <- dat[c(mark_div[5]:nrow(dat)), ]

dat_sub_5[1, 1]$Country

dat_sub_5$area <- "Total"

dat_2 <- bind_rows(dat_sub_1, dat_sub_2, dat_sub_3, dat_sub_4, dat_sub_5)

## Remove line with area and gather 

dat_3 <- subset(dat_2, substr(Country, 1, 3) != "Div" & Country != "Total North Sea and Skagerrak-Kattegat")

dat_4 <- tidyr::gather(dat_3, key = "year", value = "catch_1000t", -Country, -area)

dat_5 <- subset(dat_4, !(Country %in% c("Country")))

dat_5 <- rename(dat_5, "ctry" = "Country")

dat_5$year <- as.integer(dat_5$year)

## Handle small landings marked with *
dat_5$catch_1000t[dat_5$catch_1000t == "*"] <- 0.049
dat_5$catch_1000t <- as.numeric(dat_5$catch_1000t)
dat_5$catch_1000t[is.na(dat_5$catch_1000t)] <- 0

## Fix countries ----

unique(dat_5$ctry)

dat_5$ctry[dat_5$ctry == "Denmark"] <- "DK"
dat_5$ctry[dat_5$ctry == "Norway"] <- "NO"
dat_5$ctry[dat_5$ctry == "Sweden"] <- "SE"
dat_5$ctry[dat_5$ctry == "UK\r\n(Scotland)"] <- "GB-SCT"
dat_5$ctry[dat_5$ctry == "Germany"] <- "DE"
dat_5$ctry[dat_5$ctry == "Netherlands"] <- "NL"
dat_5$ctry[dat_5$ctry == "France"] <- "FR"
dat_5$ctry[dat_5$ctry == "UK (Engl. & Wales)" | dat_5$ctry == "UK (Engl. &\r\nWales)"] <- "GB-EAW"
dat_5$ctry[dat_5$ctry == "Faroe Islands"] <- "FO"
dat_5$ctry[dat_5$ctry == "Belgium"] <- "BE"
dat_5$ctry[dat_5$ctry == "Faroe\r\nIslands"] <- "FO"

unique(dat_5$ctry)

## Fix missing German landings 2023 ----
dat_5$catch_1000t[dat_5$ctry == "DE" & dat_5$year == 2023 & dat_5$area == "27.4.b"] <- 
  round(3.237848, digits = 1)
dat_5$catch_1000t[dat_5$ctry == "Total" & dat_5$year == 2023 & dat_5$area == "27.4.b"] <- 
  round(3.237848 + dat_5$catch_1000t[dat_5$ctry == "Total" & 
                                       dat_5$year == 2023 & dat_5$area == "27.4.b"], digits = 1)

dat_5$catch_1000t[dat_5$ctry == "Total" & dat_5$year == 2023 & dat_5$area == "Total"] <- round(3.237848 + dat_5$catch_1000t[dat_5$ctry == "Total" & dat_5$year == 2023 & dat_5$area == "Total"], digits = 1)

## Remove Swedish coastal ----
swe_sum <- summarise(group_by(swe_coast, Year), catch_swe_coast_1000t = sum(Catch_in_tonnes/1000, na.rm = T))
swe_sum <- rename(swe_sum, year = Year)

dat_6 <- left_join(dat_5, swe_sum)

dat_6$catch_1000t[dat_5$ctry == "SE" & dat_5$area == "27.3.a"] <- 
  round(dat_6$catch_1000t[dat_5$ctry == "SE" & dat_5$area == "27.3.a"] -
  dat_6$catch_swe_coast_1000t[dat_5$ctry == "SE" & dat_5$area == "27.3.a"], digits = 1)

dat_6$catch_1000t[dat_5$ctry == "Total" & dat_5$area == "27.3.a"]  <- 
  round(dat_6$catch_1000t[dat_5$ctry == "Total" & dat_5$area == "27.3.a"] -
          dat_6$catch_swe_coast_1000t[dat_5$ctry == "Total" & dat_5$area == "27.3.a"], digits = 1)

dat_6$catch_1000t[dat_5$ctry == "Total" & dat_5$area == "Total"]  <- 
  round(dat_6$catch_1000t[dat_5$ctry == "Total" & dat_5$area == "Total"] -
          dat_6$catch_swe_coast_1000t[dat_5$ctry == "Total" & dat_5$area == "Total"], digits = 1)

# Add recent year ----

unique(dat_new$country)

dat_new_1 <- subset(dat_new, year %in% c(year_last, year_last + 1))

unique(dat_new_1$subarea)

dat_new_2 <- subset(dat_new_1, subarea %in% c("27.3.a.20", "27.3.a.21",
                                              "27.4.a", "27.4.b", "27.4.c"))

dat_new_2 <- rename(dat_new_2, area = subarea, ctry = country)

dat_new_sum <- summarise(group_by(dat_new_2, year, ctry, area), catch_1000t = sum(catch_in_ton/1000))
dat_new_sum$catch_1000t[dat_new_sum$catch_1000t <= 0.049] <- NA
dat_new_sum$catch_1000t <- round(dat_new_sum$catch_1000t, digits = 1)
dat_new_sum$catch_1000t[is.na(dat_new_sum$catch_1000t)] <- 0.049

## Add totals ----

tot_year_ctry <- summarise(group_by(dat_new_2, year, ctry), catch_1000t = sum(catch_in_ton/1000))
tot_year_ctry$area <- "Total"
tot_year_ctry$catch_1000t[tot_year_ctry$catch_1000t <= 0.049] <- NA
tot_year_ctry$catch_1000t <- round(tot_year_ctry$catch_1000t, digits = 1)
tot_year_ctry$catch_1000t[is.na(tot_year_ctry$catch_1000t)] <- 0.049

tot_year <- summarise(group_by(dat_new_2, year), catch_1000t = sum(catch_in_ton/1000))
tot_year$ctry <- "Total"
tot_year$area <- "Total"
tot_year$catch_1000t[tot_year$catch_1000t <= 0.049] <- NA
tot_year$catch_1000t <- round(tot_year$catch_1000t, digits = 1)
tot_year$catch_1000t[is.na(tot_year$catch_1000t)] <- 0.049

dat_new_3 <- rbind(dat_new_sum, tot_year_ctry, tot_year)

# Combine ----

done <- rbind(select(dat_6, -catch_swe_coast_1000t), dat_new_3)

# output ----

write.table(done, paste0("./data/11_catch_year_country_div_2005_", year_last, ".csv"), row.names = F, sep = ";", na = "")

# Table xx advice - move to another script           

total <- subset(done, area == "Total")
done$catch_1000t[done$catch_1000t == 0.049] <- "+"
done_t <- arrange(tidyr::spread(done, key = ctry, value = catch_1000t), year, area)
done_t <- select(done_t, year, area, BE, DE, DK, FO, FR, `GB-EAW`, `GB-SCT`, NL, NO, SE, Total)
names(done_t)
names(done_t) <- c("Year", "Area", "Belgium", "Germany", "Denmark", 
                    "Faroe Islands", "France", "England and Wales", 
                    "Scotland", "Netherlands", "Norway", "Sweden", "Total")

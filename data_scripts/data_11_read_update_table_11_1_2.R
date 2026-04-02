

library(readxl)
library(dplyr)

year_last <- 2025

# Read in data ----

dat <- readxl::read_xlsx("./boot/data/data_from_bm/Herring Assessment Working Group_table_11.1.2.xlsx", skip = 1)
swe_coast <- read.table("./boot/data/swedish_coastal/catch_SWE_spr.27.3aN_coastal_78-24.txt",
                        header = T) 
dat_new <- read.table("./data/catches_div_2024_2026.csv", sep = ",", header = T)

  
# Fix table 11.1.2 from 2025 HAWG report
names(dat)


## split and add area ----

col_names <- c("year", "quarter", "27.4.a", "27.4.b", "27.4.c", "27.3.a", "Total")

row_1 <- dat[, c(1:7)]
names(row_1) <- col_names
row_1$year <- as.numeric(row_1$year)
unique(row_1$quarter)
row_1 <- subset(row_1, !(is.na(quarter)) & quarter != "Quar-ter")
row_2 <- dat[, c(9:15)]
names(row_2) <- col_names
row_2$year <- as.numeric(row_2$year)
unique(row_2$quarter)
row_2 <- subset(row_2, !(is.na(quarter)) & quarter != "Quar-ter")
row_2$quarter[row_2$quarter == "1**"] <- 1

min(row_1$year, na.rm = T)
max(row_1$year, na.rm = T)
min(row_2$year, na.rm = T)
max(row_2$year, na.rm = T)

row_1$year <- rep(c(min(row_1$year, na.rm = T):max(row_1$year, na.rm = T)), each = 5)
row_2$year <- rep(c(min(row_2$year, na.rm = T):max(row_2$year, na.rm = T)), each = 5)

dat_1 <- bind_rows(row_1, row_2)

## Gather data 
dat_2 <- tidyr::gather(dat_1, key = "area", value = "catch_t", -year, -quarter)

dat_2$year <- as.integer(dat_2$year)

## Handle small landings marked with *
dat_2$catch_t[dat_2$catch_t == "*"] <- 0.49
dat_2$catch_t <- as.numeric(dat_2$catch_t)
dat_2$catch_t[is.na(dat_2$catch_t)] <- 0

## Fix missing German landings 2023 ----
dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "27.4.b" & dat_2$quarter == "2"] <- 
  round(dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "27.4.b" & dat_2$quarter == "2"] + 
          282.848, digits = 0)
dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "27.4.b" & dat_2$quarter == "3"] <- 
  round(dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "27.4.b" & dat_2$quarter == "3"] + 
          2955, digits = 0)
dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "27.4.b" & dat_2$quarter == "Total"] <- 
  round(dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "27.4.b" & dat_2$quarter == "Total"] + 
          2955 + 282.848, digits = 0)

dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "Total" & dat_2$quarter == "2"] <- 
  round(dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "Total" & dat_2$quarter == "2"] + 
          282.848, digits = 0)
dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "Total" & dat_2$quarter == "3"] <- 
  round(dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "Total" & dat_2$quarter == "3"] + 
          2955, digits = 0)

dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "Total" & dat_2$quarter == "Total"] <- 
  round(dat_2$catch_t[dat_2$year == 2023 & dat_2$area == "Total" & dat_2$quarter == "Total"] + 
          2955 + 282.848, digits = 0)

## Remove Swedish coastal ----
swe_sum <- summarise(group_by(swe_coast, Year), catch_swe_coast_t = sum(Catch_in_tonnes/4, na.rm = T))
dummy <- data.frame(Year = rep(c(min(swe_sum$Year):max(swe_sum$Year)), each = 4), 
                                  quarter = rep(c(1:4), length(unique(swe_sum$Year))))
dummy$quarter <- as.character(dummy$quarter)

swe_sum <- left_join(dummy, swe_sum)

swe_sum_t <- summarise(group_by(swe_coast, Year), catch_swe_coast_t = sum(Catch_in_tonnes, na.rm = T))
swe_sum_t$quarter <- "Total"

swe_sum_final <- rbind(swe_sum, swe_sum_t)
swe_sum_final <- rename(swe_sum_final, "year" = "Year")

dat_3 <- left_join(dat_2, swe_sum_final)

dat_3$catch_t[dat_3$area == "27.3.a"] <- 
  round(dat_3$catch_t[dat_3$area == "27.3.a"] -
          dat_3$catch_swe_coast_t[dat_3$area == "27.3.a"], digits = 0)

dat_3$catch_t[dat_3$area == "Total"] <- 
  round(dat_3$catch_t[dat_3$area == "Total"] -
          dat_3$catch_swe_coast_t[dat_3$area == "Total"], digits = 0)

# Remove year in old time series

dat_4 <- subset(dat_3, year >= 2005 & year != year_last)

# Add recent year ----

unique(dat_new$country)

dat_new_1 <- subset(dat_new, year %in% c(year_last, year_last + 1))

unique(dat_new_1$subarea)

dat_new_2 <- subset(dat_new_1, subarea %in% c("27.3.a.20", "27.3.a.21",
                                              "27.4.a", "27.4.b", "27.4.c"))

dat_new_2$subarea[dat_new_2$subarea %in% c("27.3.a.20", "27.3.a.21")] <- "27.3.a"

dat_new_2 <- rename(dat_new_2, area = subarea, ctry = country)

dat_new_sum <- summarise(group_by(dat_new_2, year, quarter, area), catch_t = sum(catch_in_ton))
dat_new_sum$catch_t[dat_new_sum$catch_t <= 0.49] <- NA
dat_new_sum$catch_t <- round(dat_new_sum$catch_t, digits = 0)
dat_new_sum$catch_t[is.na(dat_new_sum$catch_t)] <- 0.49

dat_new_sum$quarter <- as.character(dat_new_sum$quarter)

## Add totals ----

tot_year_q <- summarise(group_by(dat_new_2, year, quarter), catch_t = sum(catch_in_ton))
tot_year_q$area <- "Total"
tot_year_q$catch_t[tot_year_q$catch_t <= 0.49] <- NA
tot_year_q$catch_t <- round(tot_year_q$catch_t, digits = 0)
tot_year_q$catch_t[is.na(tot_year_q$catch_t)] <- 0.49
tot_year_q$quarter <- as.character(tot_year_q$quarter)

tot_year_a <- summarise(group_by(dat_new_2, year, area), catch_t = sum(catch_in_ton))
tot_year_a$quarter <- "Total"
tot_year_a$catch_t[tot_year_a$catch_t <= 0.49] <- NA
tot_year_a$catch_t <- round(tot_year_a$catch_t, digits = 0)
tot_year_a$catch_t[is.na(tot_year_a$catch_t)] <- 0.49

tot_year <- summarise(group_by(dat_new_2, year), catch_t = sum(catch_in_ton))
tot_year$quarter <- "Total"
tot_year$area <- "Total"
tot_year$catch_t[tot_year$catch_t <= 0.49] <- NA
tot_year$catch_t <- round(tot_year$catch_t, digits = 0)
tot_year$catch_t[is.na(tot_year$catch_t)] <- 0.49

dat_new_3 <- rbind(dat_new_sum, tot_year_q, tot_year_a, tot_year)

# Combine ----

done <- rbind(select(dat_4, -catch_swe_coast_t), dat_new_3)

# output ----

write.table(done, paste0("./data/11_catch_year_quarter_div_2005_", year_last, ".csv"), row.names = F, sep = ";", na = "")



library(readxl)
library(dplyr)

dat <- readxl::read_xlsx("./boot/data/data_from_bm/Herring Assessment Working Group_table_11.1.1.xlsx")

names(dat)

unique(dat$Country)

# split and add area ----

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

## Remove line with area and gather 

dat_3 <- subset(dat_2, substr(Country, 1, 3) != "Div" & Country != "Total North Sea and Skagerrak-Kattegat")

dat_4 <- tidyr::gather(dat_3, key = "year", value = "catch_1000t", -Country, -area)

dat_5 <- subset(dat_4, !(Country %in% c("Country", "Total")))

dat_5 <- rename(dat_5, "ctry" = "Country")

dat_5$catch_1000t <- as.numeric(dat_5$catch_1000t)

# Fix countries ----

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

# output

write.table(dat_5, "./data/11_catch_year_country_div_2005_2024.csv", row.names = F, sep = ";", na = "")

dat_sum <- summarise(group_by(dat_5, year, ctry), catch_1000t = sum(catch_1000t, na.rm = T))


write.table(dat_sum, "./data/11_catch_year_country_2005_2024.csv", row.names = F, sep = ";", na = "")

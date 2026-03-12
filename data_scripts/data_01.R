
library(icesTAF)
library(readxl)
library(lubridate)
library(dplyr)
library(stringr)

mkdir("data")


bel_file <- "BE_2025 DC HAWG spr.27.4 BEL landings_v2.xls"
deu_file <- "DE_2025 DC HAWG spr.27.4 DE landings_v2.xls"
sco_file <-
  "2025 DC HAWG spr27.3a4 spr.27.67a-cf-k SCO exchange spreadsheet.xls"
dnk_file <- "DC_Annex_HAWG2 sprat template_DNK_2023_2025.xlsx"
# ltu_file <- "DC_Annex_7.1.1. HAWG LTU_2020.xls" # Only herring
nor_file <- "NO_DC_Annex_HAWG2 sprat_NOR2024.xls"
swe_file <- "SE_2025 DC HAWG spr.27.3a4 YellowSheet.xls"
nld_file <- "2025_NLD_HAWG Sprat template.xls"
eng_file <- "DC_Annex_HAWG2 sprat template 2025 UK EW.xls"
# fra_file <- "FRA_2022.xls"


# Catch subdiv ----

bel_cat_div <-
  read_excel(paste0("boot/data/", bel_file), sheet = 2)[, c(1:5)] # bingo
deu_cat_div <-
  read_excel(paste0("boot/data/", deu_file), sheet = 2)[, c(1:5)] # bingo
sco_cat_div <-
  read_excel(paste0("boot/data/", sco_file), sheet = 2)[, c(1:5)] # bingo
sco_cat_div <-
  rename(sco_cat_div, "Subarea" = "ICES area", "Catch_in_ton" = "Catch_in_tonnes")
swe_cat_div <-
  read_excel(paste0("boot/data/", swe_file), sheet = 2)[, c(1:5)] # bingo
swe_cat_div <-
  rename(swe_cat_div, "Subarea" = "ICES area", "Catch_in_ton" = "Catch_in_tonnes")
nor_cat_div <-
  read_excel(paste0("boot/data/", nor_file), sheet = 2)[, c(1:5)] # bingo
nor_cat_div <-
  rename(nor_cat_div, "Subarea" = "ICES area", "Catch_in_ton" = "Catch_in_tonnes")
dnk_cat_div <-
  read_excel(paste0("boot/data/", dnk_file), sheet = 2)[, c(1:5)] # bingo
dnk_cat_div <-
  rename(dnk_cat_div, "Subarea" = "ICES area", "Catch_in_ton" = "Catch_in_tonnes")
nld_cat_div <-
  read_excel(paste0("boot/data/", nld_file), sheet = 2)[, c(1:5)] # bingo
nld_cat_div <-
  rename(nld_cat_div, "Subarea" = "ICES area", "Catch_in_ton" = "Catch_in_tonnes")
eng_cat_div <-
  read_excel(paste0("boot/data/", eng_file), sheet = 2)[, c(1:5)] # bingo
eng_cat_div <-
  rename(eng_cat_div, "Subarea" = "ICES area", "Catch_in_ton" = "Catch_in_tonnes")
# fra_cat_div <- read_excel(paste0(path, fra_file), sheet=2)[, c(1:5)] # bingo

names(bel_cat_div)
names(deu_cat_div)
names(sco_cat_div)
names(swe_cat_div)
names(nor_cat_div)
names(dnk_cat_div)
names(nld_cat_div)
names(eng_cat_div)

cat_div <-
  rbind(
    bel_cat_div,
    deu_cat_div,
    sco_cat_div,
    swe_cat_div,
    nor_cat_div,
    dnk_cat_div,
    nld_cat_div,
    eng_cat_div
  )
cat_div_1 <- subset(cat_div, Year %in% c(2023, 2024, 2025))

## correct naming of subdivision
unique(cat_div_1$Subarea)

cat_div_1$Subarea[cat_div_1$Subarea %in% c("4aW", "4a")] <- "27.4.a"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("4b", "4B", "27.4b", "4.b")] <-
  "27.4.b"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("4c", "4C", "27.4c", "4.c")] <-
  "27.4.c"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("3a")] <- "27.3.a"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("3aS")] <- "27.3.a.21"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("3aN")] <- "27.3.a.20"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("27.6a", "6A")] <-
  "27.6.a"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("27.7a")] <- "27.7.a"
cat_div_1$Subarea[cat_div_1$Subarea %in% c("7d")] <- "27.7.d"

unique(cat_div_1$Subarea)

names(cat_div_1) <- tolower(names(cat_div_1))

write.csv(cat_div_1,
          paste0("data/", "catches_div_2023_2025.csv"),
          row.names = F)

# Check figures against submissions
## combine new data with old

old_div <-
  read.csv(
    paste0(
      "boot/data/data_from_last_year/",
      "catches_div_2019_2024.csv"
    ),
    sep = ";"
  )
names(old_div) <- tolower(names(old_div))
unique(old_div$year)

distinct(cat_div_1, country, year) # Only Danish data from 2023 and 2025
distinct(old_div, country, year)

old_div_1 <-
  subset(old_div,!(country == "DK" & year %in% c(2023, 2024)))
distinct(old_div_1, country, year)

new_div <- rbind(old_div_1, cat_div_1)

write.csv(new_div,
          paste0("data/", "catches_div_2019_2025.csv"),
          row.names = F)


# Catch square ----

bel_cat_sq <-
  read_excel(paste0("boot/data/", bel_file), sheet = 3)[, c(1:5)] # bingo
deu_cat_sq <-
  read_excel(paste0("boot/data/", deu_file), sheet = 3)[, c(1:5)] # bingo
sco_cat_sq <-
  read_excel(paste0("boot/data/", sco_file), sheet = 3)[, c(1:5)] # bingo
sco_cat_sq <-
  rename(sco_cat_sq, "Square" = "Statrec", "Catch_in_ton" = "Catch_in_tonnes")
swe_cat_sq <-
  read_excel(paste0("boot/data/", swe_file), sheet = 3)[, c(1:5)] # bingo
swe_cat_sq <-
  rename(swe_cat_sq, "Square" = "Statrec", "Catch_in_ton" = "Catch_in_tonnes")
nld_cat_sq <-
  read_excel(paste0("boot/data/", nld_file), sheet = 3)[, c(1:5)] # bingo
nld_cat_sq <-
  rename(nld_cat_sq, "Square" = "Statrec", "Catch_in_ton" = "Catch_in_tonnes")
nor_cat_sq <-
  read_excel(paste0("boot/data/", nor_file), sheet = 3)[, c(1:5)] # bingo
nor_cat_sq <-
  rename(nor_cat_sq, "Square" = "Statrec", "Catch_in_ton" = "Catch_in_tonnes")
dnk_cat_sq <-
  read_excel(paste0("boot/data/", dnk_file), sheet = 3)[, c(1:5)] # bingo
dnk_cat_sq <-
  rename(dnk_cat_sq, "Square" = "Statrec", "Catch_in_ton" = "Catch_in_tonnes")
eng_cat_sq <-
  read_excel(paste0("boot/data/", eng_file), sheet = 3)[, c(1:5)] # bingo
eng_cat_sq <-
  rename(eng_cat_sq, "Square" = "Statrec", "Catch_in_ton" = "Catch_in_tonnes")
# fra_cat_sq <- read_excel(paste0("boot/data/", fra_file), sheet=3)[, c(1:5)] # bingo

names(bel_cat_sq)
names(deu_cat_sq)
names(sco_cat_sq)
names(swe_cat_sq)
names(nld_cat_sq)
names(nor_cat_sq)
names(dnk_cat_sq)
names(eng_cat_sq)

cat_sq <-
  rbind(
    bel_cat_sq,
    deu_cat_sq,
    sco_cat_sq,
    swe_cat_sq,
    nld_cat_sq,
    nor_cat_sq,
    dnk_cat_sq,
    eng_cat_sq
  )
cat_sq_1 <- subset(cat_sq, Year %in% c(2023, 2024, 2025))

head(cat_sq_1)

## Correct squares

unique(cat_sq_1$Square)

cat_sq_1$Square <- str_remove_all(cat_sq_1$Square, "'")
cat_sq_1$Square[cat_sq_1$Square == "NONE"] <- NA
unique(cat_sq_1$Square)

names(cat_sq_1) <- tolower(names(cat_sq_1))

write.csv(cat_sq_1,
          paste0("data/", "catches_square_2023_2025.csv"),
          row.names = F)

## combine new data with old

old_sq <-
  read.csv(
    paste0(
      "boot/data/data_from_last_year/",
      "catches_square_2002_2024.csv"
    ),
    sep = ","
  )
names(old_sq) <- tolower(names(old_sq))
unique(old_sq$year)

distinct(cat_sq_1, country, year) # Only Danish data from 2023 and 2025
distinct(old_sq, country, year)

old_sq_1 <-
  subset(old_sq,!(country == "DK" & year %in% c(2023, 2024)))
distinct(old_sq_1, country, year)

new_sq <- rbind(old_sq_1, cat_sq_1)

write.csv(new_sq,
          paste0("data/", "catches_square_2002_2025.csv"),
          row.names = F)

# samples ALK ----

swe_samp_alk <-
  read_excel(paste0("boot/data/", swe_file), sheet = 4)[, c(1:14)] # bingo
swe_samp_alk$date_old <- swe_samp_alk$Date
swe_samp_alk$Date <-
  as.Date(as.character(swe_samp_alk$Date), "%y%m%d")
# nor_samp_alk <-
#   read_excel(paste0("boot/data/", nor_file), sheet = 4)[, c(1:14)] # bingo
# nor_samp_alk$date_old <- nor_samp_alk$Date
# nor_samp_alk$Date <-
#   as.Date(as.character(nor_samp_alk$Date), "%y%m%d")
dnk_samp_alk <-
  read_excel(paste0("boot/data/", dnk_file), sheet = 4)[, c(1:14)] # bingo
dnk_samp_alk$date_old <- dnk_samp_alk$Date
dnk_samp_alk$Date <-
  as.Date(as.character(dnk_samp_alk$Date), "%Y%m%d")

names(swe_samp_alk)
# names(nor_samp_alk)
names(dnk_samp_alk)

samp_alk <- rbind(swe_samp_alk, dnk_samp_alk)#, nor_samp_alk)
head(samp_alk)

samp_alk <-
  mutate(
    samp_alk,
    year = year(Date),
    day = day(Date),
    month = month(Date),
    length_mm = SCM * 5,
    quarter = quarter(Date)
  )

samp_alk_1 <- subset(samp_alk, year %in% c(2023, 2024, 2025))

unique(samp_alk_1$length_mm)

names(samp_alk_1) <- tolower(names(samp_alk_1))
names(samp_alk_1)
samp_alk_1 <- rename(samp_alk_1, c("noage4" = "noage4+"))

write.csv(samp_alk_1,
          paste0("data/", "alk_samples_2023_2025.csv"),
          row.names = F)

## Output to Anna's script

samp_alk_a <- rename(samp_alk_1, c("noage4_" = "noage4"))

samp_alk_a_1 <- subset(samp_alk_a, country != "DK")

write.csv(
  samp_alk_a_1,
  paste0("data/", "alk_samples_original_format_no_dnk_2024_2025.csv"),
  row.names = F,
  na = ""
)

# samples ld ----


swe_samp_ld <-
  read_excel(paste0("boot/data/", swe_file), sheet = 5)[, c(1:6)] # bingo
swe_samp_ld$date_old <- swe_samp_ld$Date
swe_samp_ld$Date <-
  as.Date(as.character(swe_samp_ld$Date), "%y%m%d")
swe_samp_ld <- rename(swe_samp_ld, "ICESsq" = "Statrec")

# nor_samp_ld <-
#   read_excel(paste0("boot/data/", nor_file), sheet = 5)[, c(1:6)] # bingo
# nor_samp_ld$date_old <- nor_samp_ld$Date
# nor_samp_ld$Date <-
#   as.Date(as.character(nor_samp_ld$Date), "%y%m%d")
# nor_samp_ld <- rename(nor_samp_ld, "ICESsq" = "Statrec")

dnk_samp_ld <-
  read_excel(paste0("boot/data/", dnk_file), sheet = 5)[, c(1:6)] # bingo
dnk_samp_ld$date_old <- dnk_samp_ld$Date
dnk_samp_ld$Date <-
  as.Date(as.character(dnk_samp_ld$Date), "%Y%m%d")
dnk_samp_ld <- rename(dnk_samp_ld, "ICESsq" = "Statrec")

names(swe_samp_ld)
# names(nor_samp_ld)
names(dnk_samp_ld)

samp_ld <- rbind(swe_samp_ld, dnk_samp_ld) #nor_samp_ld, 
head(samp_ld)

samp_ld <-
  mutate(
    samp_ld,
    year = year(Date),
    day = day(Date),
    month = month(Date),
    length_mm = SCM * 5,
    quarter = quarter(Date)
  )

samp_ld_1 <- subset(samp_ld, year %in% c(2023, 2024, 2025))

unique(samp_ld_1$length_mm)

names(samp_ld_1) <- tolower(names(samp_ld_1))

write.csv(samp_ld_1,
          paste0("data/", "ld_samples_2023_2025.csv"),
          row.names = F)

## Output to Anna's script


samp_ld_a_1 <- subset(samp_ld_1, country != "DK")

write.csv(
  samp_ld_a_1,
  paste0("data/", "ld_samples_original_format_no_dnk_2024_2025.csv"),
  row.names = F
)

# samples number ----


swe_samp <-
  read_excel(paste0("boot/data/", swe_file), sheet = 6)[, c(1:8)] # bingo
swe_samp <- rename(swe_samp, "Catch_in_ton" = "Catch_in_tonnes")
# nor_samp <-
#   read_excel(paste0("boot/data/", nor_file), sheet = 6)[, c(1:8)] # bingo
dnk_samp <-
  read_excel(paste0("boot/data/", dnk_file), sheet = 6)[, c(1:8)] # bingo
dnk_samp <- rename(dnk_samp, "Catch_in_ton" = "Catch_in_tonnes")

names(swe_samp)
names(dnk_samp)
# names(nor_samp)

samp <- rbind(swe_samp, dnk_samp) #, nor_samp)
head(samp)

samp_1 <- subset(samp, Year %in% c(2023, 2024, 2025))

## correct naming of subdivision
unique(samp_1$Subarea)

samp_1$Subarea[samp_1$Subarea %in% c("4aW")] <- "27.4.a"
samp_1$Subarea[samp_1$Subarea %in% c("4b", "4B", "27.4b")] <-
  "27.4.b"
samp_1$Subarea[samp_1$Subarea %in% c("4c", "4C", "27.4c")] <-
  "27.4.c"
samp_1$Subarea[samp_1$Subarea %in% c("3a")] <- "27.3.a"
samp_1$Subarea[samp_1$Subarea %in% c("3aS")] <- "27.3.a.21"
samp_1$Subarea[samp_1$Subarea %in% c("3aN")] <- "27.3.a.20"

samp_1$Subarea[samp_1$Subarea %in% c("27.6a")] <- "27.6.a"
samp_1$Subarea[samp_1$Subarea %in% c("27.7a")] <- "27.7.a"

unique(samp_1$Subarea)

names(samp_1) <- tolower(names(samp_1))

write.csv(samp_1,
          paste0("data/", "no_samples_2023_2025.csv"),
          row.names = F)

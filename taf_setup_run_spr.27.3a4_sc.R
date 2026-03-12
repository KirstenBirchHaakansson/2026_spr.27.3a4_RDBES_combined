
library(icesTAF)

getwd()
# taf.skeleton()


# draft.data(data.files = "preliminary_catch_statistics",
#            data.scripts = NULL,
#            originator = "ICES",
#            title = "Preliminary catch statistic from ICES",
#            file = T,
#            append = F)

draft.data(data.files = "submitted_data/2026_NLD_HAWG Sprat template.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from the Nedtherlands",
           period = "2025",
           access = "Restricted",
           file = T,
           append = F)

draft.data(data.files = "submitted_data/BE_2026 DC HAWG spr.27.4 BEL landings.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Belgium",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/DC_Annex_HAWG2 spr.27.3a4 template 2025 UK EW.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Englend Wales",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/DC_Annex_HAWG2 spr.27.3a4 template_DNK_2023_2025.xlsx",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Denmark",
           period = "2024-2026",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/age_including_survey.sas7bdat",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Denmark in the old SAS format",
           period = "-2026",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/length_including_survey.sas7bdat",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Denmark in the old SAS format",
           period = "-2026",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/DE_2026 DC HAWG spr.27.4 DE landings.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Germany",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/GB-SCT_2026 DC HAWG spr27.3a4 spr.27.67a-cf-k SCO exchange spreadsheet.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Scotland",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

# draft.data(data.files = "GB-SCT_2026 DC HAWG spr27.3a4 spr.27.67a-cf-k SCO exchange spreadsheet.xls",
#            data.scripts = NULL,
#            originator = "Data submitted to HAWG",
#            title = "Data from Scotland",
#            period = "2025",
#            access = "Restricted",
#            file = T,
#            append = T)

draft.data(data.files = "submitted_data/NO_2026 DC HAWG spr.27.3a4 NO.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Norway",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "submitted_data/SE_SE_2026 DC HAWG spr.27.3a4 YellowSheet_v2.xls",
           data.scripts = NULL,
           originator = "Data submitted to HAWG",
           title = "Data from Sweden",
           period = "2025",
           access = "Restricted",
           file = T,
           append = T)

draft.data(data.files = "data_from_bm",
           data.scripts = NULL,
           originator = "HAWG",
           title = "Data from benchmark",
           period = "-2024",
           access = "Restricted",
           file = T,
           append = T)

# draft.data(data.files = "old_input_files",
#            data.scripts = NULL,
#            originator = "Anna",
#            title = "Files needed for the SAS script",
#            file = T,
#            append = T)

# 
# draft.data(data.files = "time_series",
#            data.scripts = NULL,
#            originator = "Former HAWGs",
#            title = "Time series from last year",
#            file = T,
#            append = T)
# 
# draft.data(data.files = "data_from_tomas",
#            data.scripts = NULL,
#            originator = "Data from Tomas (former SC)",
#            title = "Data from Tomas",
#            file = T,
#            append = T)

# draft.data(data.files = NULL,
#            data.scripts = "download_from_stockassessment_org_single_fleet.R",
#            originator = "stockassessment.org",
#            title = "Single fleet data from stockassessment.org",
#            file = T,
#            append = T)
# 
# draft.data(data.files = NULL,
#            data.scripts = "download_from_stockassessment_org_multi_fleet.R",
#            originator = "stockassessment.org",
#            title = "Multi fleet data from stockassessment.org",
#            file = T,
#            append = T)

# draft.data(data.files = "Herring_TAC_catches_by_area.csv",
#            data.scripts = NULL,
#            originator = "Updated 2024",
#            title = "TAC and catch",
#            file = T,
#            append = T)

# draft.data(data.files = "kibi_notes",
#            data.scripts = NULL,
#            originator = "Kibi",
#            title = "Kibi's notes",
#            file = T,
#            append = T)

taf.boot()

# mkdir("data")
# mkdir("output")

# sourceTAF("data") 
# 
# sourceTAF("report") 
# run model_0....

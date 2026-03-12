
*********** DNK data; 
libname in "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2025_spr.27.3a4_RDBES_combined\boot\data";
libname out "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2025_spr.27.3a4_RDBES_combined\data";


data out.age_including_survey;
set in.age_including_survey;

data out.length_including_survey;
set in.length_including_survey;

run;

*********** old input files data; 
libname in "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2025_spr.27.3a4_RDBES_combined\boot\data\old_input_files";

data out.dk_spr_catch_82_88;
set in.dk_spr_catch_82_88;

data out.dk_spr_catch_89_11;
set in.dk_spr_catch_89_11;

data out.dk_spr_catch_89_13;
set in.dk_spr_catch_89_13;

data out.dk_spr_catch_89_14;
set in.dk_spr_catch_89_14;

data out.dk_spr_catch_89_15;
set in.dk_spr_catch_89_15;

data out.dk_spr_catch_89_16;
set in.dk_spr_catch_89_16;

data out.havr89_og_frem_alle_arter;
set in.havr89_og_frem_alle_arter;

data out.ices_catch;
set in.ices_catch;

data out.length;
set in.length;

data out.new_sandeel_areas_incl_3a;
set in.new_sandeel_areas_incl_3a;

data out.sms_ns_2011;
set in.sms_ns_2011;

run;


*********** data_from_last_year; 
libname in "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2025_spr.27.3a4_RDBES_combined\boot\data\data_from_last_year";

data out.alk23_intsq;
set in.alk23_intsq;

data out.mean_weight_and_n_per_kg_2023;
set in.mean_weight_and_n_per_kg_2023;

run;

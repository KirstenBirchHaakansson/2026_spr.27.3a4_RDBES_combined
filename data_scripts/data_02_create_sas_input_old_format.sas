

libname in "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\boot\data\data_from_bm";
libname out "C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\data";

%let path = C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\data;

%let year = 2025;

*ALK;

PROC IMPORT OUT= WORK.alk
            DATAFILE= "&path.\alk_samples_original_format_no_dnk_2024_2026.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 DELIMITER=',';
	 GUESSINGROWS = 500;
RUN;

data alk;
set alk;

drop date;

data alk;
set alk;
format date 10.;

date = date_old;

run;

proc sql;
create table year_new as
select distinct year
from alk;

data old_alk;
set in.norwegian_alk_2024;

day=date-100*floor(date/100);
month=(date-10000*floor(date/10000)-day)/100;
year=floor(date/10000)+2000;

if year >= &year. then delete;

run;

data out.norwegian_alk_&year.;
set  old_alk alk;
run;

proc sql;
create table tjek_alk as
select year, count(year) as nrow, sum(noage0 + noage1 + noage2 + noage3 + noage4_)
from out.norwegian_alk_&year.
group by year;

*LD;

PROC IMPORT OUT = work.ld
            DATAFILE= "&path.\ld_samples_original_format_no_dnk_2024_2026.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 DELIMITER=',';
	 GUESSINGROWS = 500;
RUN;


data ld;
set ld;

drop date;

data ld;
set ld;
format date 10.;

date = date_old;

run;

proc sql;
create table year_new as
select distinct year
from ld;

data old_ld;
set in.norwegian_length_2024; *Wronag naming in 2022;

day=date-100*floor(date/100);
month=(date-10000*floor(date/10000)-day)/100;
year=floor(date/10000)+2000;

if year >= &year. then delete;

run;

data out.norwegian_length_&year.;
set  old_ld ld;
run;

proc sql;
create table tjek_ld as
select year, count(year) as nrow, sum(Total_number_length_class) as noLength
from out.norwegian_length_&year.
group by year;

*Landings per square;

PROC IMPORT OUT= out.catch_square_2002_2026
            DATAFILE= "&path.\catches_square_2002_2026.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


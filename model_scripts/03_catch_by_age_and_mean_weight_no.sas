/**/

%let update = 'partial'; *all|partial;
%let years_to_update_first = 2024;
%let years_to_update_last = 2026;
%let year = 2025;

libname in 'C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\data';
libname out 'C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\model';

%let path_area = C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\utils\area_relation;
%let path_output = C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\model;
%let path_coast = C:\Users\kibi\OneDrive - Danmarks Tekniske Universitet\stock_coord_work\spr.27.3a4\2026_spr.27.3a4_RDBES_combined\boot\data\swedish_coastal;


%let new_mw_no_file_name = mean_weight_and_n_per_kg_&year.;

PROC IMPORT OUT= WORK.area_relation
            DATAFILE= "&path_area./sprat_area_relation.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows=50000;
RUN;

PROC IMPORT OUT= WORK.swe_swe_coast 
            DATAFILE= "&path_coast.\catch_SWE_spr.27.3aN_coastal_78-24.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc sql;
create table swe_swe_coast_sum as
select Year, 'IV' as div, sum(Catch_in_tonnes/1000) as swe_coast_ton
from swe_swe_coast
group by Year, div;

************Der er to input data sæt: havret tilbage til 1989 og logbog fra 1982-1988. ************
************Før 1982 bruges gennesmnitlig fordeling 1982-1988*******************************'******;

data a01;
set in.Dk_spr_catch_82_88;
aar=year+1900;
kv=quarter;
if aar=1989 then delete;
ton=brs_ton;
sq=square;
run;

proc sort data=a01;
by kv sq;
run;

proc summary data=a01;
var ton;
by kv sq;
output out=a02 (drop=_type_ _freq_) mean()=;
run;

data a0;
set a02;
do aar=1963 to 1981 by 1;
output;
end;
run;

data a1;
set in.Dk_spr_catch_82_88;
aar=year+1900;
kv=quarter;
if aar=1989 then delete;
ton=brs_ton;
sq=square;
run;

data a2a1;
set in.Havr89_og_frem_alle_arter;
if art not in ('BRS') then delete;
if aar lt 2012 then delete;
if aar gt 2013 then delete;
run;

data a2a2;
set in.dk_spr_catch_89_11;
if aar ge 2012 then delete;
run;

data a2a3;
set in.Havr89_og_frem_alle_arter;
if art not in ('BRS') then delete;
if aar lt 2014 then delete;
run;

data a2a;
set a2a3 a2a2 a2a1 a1 a0;

year=aar;
quarter=kv;
intsq='    ';
intsq=sq;

if year gt 2018 then delete;
*roundfish=put(sq,$ibts.);
*if roundfish in ('OUT','','MANGLER') then delete;
*div='    ';
*div='IV';
*if roundfish in ('8','9') then div='IIIa';

keep year quarter intsq ton div;
run;

** Add areas;
proc sql;
create table a2a_area as
select *
from a2a a left join area_relation b
on a.intsq = b.rect;

data a2a;
set a2a_area;

if spr_div in ('OUT','','MANGLER') then delete;
div = spr_div;
if spr_div in ('8','9') then div='IIIa';
if intsq in ('45F7', '45F8', '46F8', '46F9', '47F9', '46G0', '47G0', '48G0', '47G1') then div='NO';

run;

proc sql;
create table area_check as
select distinct rfa, spr_div, div
from a2a;


proc sort data=a2a;
by year quarter div;
run;

proc summary data=a2a;
var ton;
by year quarter div ;
output out=t4x (drop=_type_ _freq_) sum()=;
run;

proc export data=a2a
   outfile= "&path_output\danish_catches.csv"
   dbms=csv 
   replace;
run;
quit;

data a2b;
set in.catch_square_2002_&years_to_update_last.;
intsq='    ';
intsq=square;
ton=catch_in_ton;
if country in ('DEN','DK') and year lt 2019 then delete;
****************REMOVE IN 2024************************;
****************Temporary fix for low catches and no samples**********;
*if year=2025 and quarter=1 then do;
*	quarter=4; *year=2024;
*	end;
run;

** Add areas;
proc sql;
create table a2b_area as
select *
from a2b a left join area_relation b
on a.intsq = b.rect;

data a2b;
set a2b_area;

if spr_div in ('OUT','','MANGLER') then delete;
div = spr_div;
if spr_div in ('8','9') then div='IIIa';
if intsq in ('45F7', '45F8', '46F8', '46F9', '47F9', '46G0', '47G0', '48G0', '47G1') then div='NO';

run;

proc sql;
create table area_check as
select distinct rfa, spr_div, div
from a2b;

data a2c;
set a2a a2b;
*if quarter=2 then quarter=3;
run;

proc sort data=a2c;
by year quarter intsq;
run;

proc summary data=a2c;
var ton;
by year quarter intsq;
output out=a2 (drop=_type_ _freq_) sum()=;
run;

proc sort data=a2;
by year quarter intsq;
run;

proc sort data=out.&new_mw_no_file_name. out=a3;
by year quarter intsq;
run;

*************260313 - impute missing biology 2025 & 2026 ****************************;
data a3_imp;
set a3;

if year in (2024, 2025) and quarter = 4 then do;
	year = year + 1;
	quarter = 1;
	n4_per_kg = (n3_per_kg + n4_per_kg) / 2;
	n3_per_kg = n2_per_kg;
	n2_per_kg = n1_per_kg;
	n1_per_kg = n0_per_kg;
	n0_per_kg = 0;
	mw4 = (mw3 + mw4) / 2;
	mw3 = mw2;
	mw2 = mw1;
	mw1 = mw0;
	mw0 = .;
	imputation = 'yes';
end;

if imputation ne 'yes' then delete;
run;

data a3_imp;
set a3_imp;

output; 

if year = 2025 and quarter = 1 and intsq = '42F8' then do;
	intsq = '42F9'; *Why is this one missing?;
	output;
end;

run;

data a3; 
set a3; 
if year in (2025, 2026) and quarter = 1 then delete;

run;

data a3;
set a3 a3_imp;
run;

proc sort data=a3;
by year quarter intsq;
run;

***********************************************************************************;

data a4;
merge a2 a3;
by year quarter intsq;
run;

data a4_miss_bio;
set a4;

if level = .;

drop spr_div;

run;

proc sql;
create table a4_miss_bio_2 as
select *
from a4_miss_bio a left join area_relation b
on a.intsq = b.rect;

proc sql;
create table a4_miss_bio_sum as
select year, quarter, spr_div, intsq, sum(ton) as ton
from a4_miss_bio_2
group by year, quarter, spr_div, intsq;

*proc sort data=a4 out=x4;
*by quarter year;
*run;

*proc corr data=x4 outp=x5;
*var n_samples ton;
*by quarter year;
*run;

*proc summary data=x4;
*var ton n_samples;
*by quarter year;
*output out=x4a sum()=;
*run;

*proc export data=x4a
   outfile='C:\ar\sprat\age_distributions\quarterly_catches.csv'
   dbms=csv 
   replace;
*run;
*quit;

*data x6;
*set x5;
*if _type_ ne 'CORR' then delete;
*if _name_ ne 'ton' then delete;
*if year lt 1991 then delete;
*run;

*proc corr data=x6;
*var year n_samples;
*by quarter;
*run;

*proc summary data=x6;
*var n_samples;
*by quarter;
*output out=x7 (drop=_type_ _freq_) p90()=p90 p10()=p10 mean()=mean max()=max min()=min;
*run;

*proc export data=x7
   outfile='C:\ar\sprat\age_distributions\correlation_n_samples_ton.csv'
   dbms=csv 
   replace;
*run;
*quit;

*proc gplot data=x6;
*plot n_samples*year=quarter;
*symbol1 v=plus i=join;
*symbol2 v=plus i=join;
*symbol3 v=plus i=join;
*symbol4 v=plus i=join;
*run;


data a2d;
set a2;

*roundfish=put(intsq,$ibts.);

*div='    ';
*div='IV';
*if roundfish in ('8','9') then div='IIIa';

*if intsq in ('45F7', '45F8', '46F8', '46F9', '47F9', '46G0', '47G0', '48G0', '47G1') 
then div='NO';

run;

** Add areas;
proc sql;
create table a2d_area as
select *
from a2d a left join area_relation b
on a.intsq = b.rect;

data a2d;
set a2d_area;

if spr_div in ('OUT','','MANGLER') then delete;
div = spr_div;
if intsq in ('45F7', '45F8', '46F8', '46F9', '47F9', '46G0', '47G0', '48G0', '47G1') then div='NO';
roundfish = spr_div;

run;

proc sql;
create table area_check_2 as
select distinct rfa, spr_div, div
from a2d;


proc sort data=a2d;
by year div roundfish;
run;

proc summary data=a2d;
var ton;
by year div;
output out=t4 (drop=_type_ _freq_) sum()=;
run;

data t5;
set in.sms_ns_2011;
if species ne 'Sprat' then delete;
sms_ton=yield__sop_;
if year gt 1964 then delete;
run;

proc sort data=t5;
by year;
run;

proc summary data=t5;
var sms_ton;
by year;
output out=t6 (drop=_type_ _freq_) sum()=IV;
run;

data t7a;
set t6 in.ices_catch;
if year lt 1965 then IV=IV/1000;
if year ge 1966 then IV=IV+IIIa;
run;

data t7b;
merge t7a t4;
by year;
run;


***************UPDATE HERE AND UNQUOTE*****************************;


data t8a;
set t7b;
if year=2012 then IV=85.564+10.416;

if year=2013 then IV=60.934+3.75;

if year=2014 then IV=140.384+18.58;

if year=2015 then IV=290.380+13.27;

if year=2016 then IV=240.673+8.204;

if year=2017 then IV=128.660+1.418;

if year=2018 then IV=187.216+3.969;

if year=2019 then IV=23.386+123.082;

*if year=2020 then IV=179.843+0.478; *2021;
if year=2020 then IV=182.654;
if year=2021 then IV=80.761;
if year=2022 then IV=89.721+0.384; *OK;

if year=2023 then IV=91.420+3.237848; *2025 - updated and only 2023 landings;

if year=2024 then IV=84.970 + 0.002; *2025 - updated 2024+2025 landings;

if year=2025 then IV=0; *2025 run - moved to Q4 2024;

****************REMOVE 683 t from 2019 IN 2021************************;
****************Temporary fix for low catches and no samples**********;
run;

proc sort data = t8a;
by Year div;
run;

data t8a_1;
merge t8a swe_swe_coast_sum;
by year div;
run;

data t8a;
set t8a_1;

if swe_coast_ton = . then swe_coast_ton = 0;
IV = IV-swe_coast_ton;

if div='IV' then faktorIV=1000*IV/ton;
if div='NO' then faktorNO=1;
keep year faktorIV faktorNO;
run;

proc summary data=t8a;
var faktorIV faktorNO;
by year;
output out=t8 (drop=_type_ _freq_) sum()=;
run;


proc gplot data=t8;
plot (faktorIV faktorNO)*year/overlay;
run;

proc sort data=a4;
by year;
run;

data cb9;
merge a4 t8;
by year;
run; 

data cb9;
set cb9;
drop spr_div RFA;
run;
** Add areas;
proc sql;
create table cb9_area as
select *
from cb9 a left join area_relation b
on a.intsq = b.rect;

data cb9;
set cb9_area;

*if spr_div in ('OUT','','MANGLER') then delete;
div = spr_div;
if intsq in ('45F7', '45F8', '46F8', '46F9', '47F9', '46G0', '47G0', '48G0', '47G1') then div='NO';
roundfish = rfa;

run;

proc sql;
create table area_check_3 as
select distinct rfa, spr_div, area3
from cb9;

data cb10;
set cb9;
if ton=. then ton=0;
*roundfish=put(intsq,$ibts.);
*div='    ';
*div='IV';
*if intsq in ('45F7', '45F8', '46F8', '46F9', '47F9', '46G0', '47G0', '48G0', '47G1') then div='NO';

if div='IV' then ton=faktorIV*ton;
if div='NO' then ton=faktorNO*ton;

n0=ton*n0_per_kg;
n1=ton*n1_per_kg;
n2=ton*n2_per_kg;
n3=ton*n3_per_kg;
n4=ton*n4_per_kg;
wmw0=n0*mw0;
wmw1=n1*mw1;
wmw2=n2*mw2;
wmw3=n3*mw3;
wmw4=n4*mw4;
*if quarter=2 then wmw0=mw0;
*if quarter=2 then wmw1=mw1;
*if quarter=2 then wmw2=mw2;
*if quarter=2 then wmw3=mw3;
*if quarter=2 then wmw4=mw4;

run;

proc sort data=cb10 out=cb11;
by year quarter div;
run;

proc sort data=cb10 out=cb11x;
by div year intsq;
run;


proc summary data=cb11x;
var ton n_samples;
by div year intsq;
output out=cb12x sum()= ;
run;

proc export data=cb12x (drop= _type_ _freq_)
   outfile= "&path_output\square_based_cathes.csv"
   dbms=csv 
   replace;
run;
quit;

proc summary data=cb11;
var n0-n4 wmw0-wmw4 ton n_samples 
;
by year quarter div;
output out=cb12 sum()= mean(wmw0)=w2mw0 mean(wmw1)=w2mw1 mean(wmw2)=w2mw2 mean(wmw3)=w2mw3 mean(wmw4)=w2mw4;
run;

data cb13;
set cb12;
mw0=wmw0/n0;
mw1=wmw1/n1;
mw2=wmw2/n2;
mw3=wmw3/n3;
mw4=wmw4/n4;
*if quarter=2 then mw0=w2mw0;
*if quarter=2 then mw1=w2mw1;
*if quarter=2 then mw2=w2mw2;
*if quarter=2 then mw3=w2mw3;
*if quarter=2 then mw4=w2mw4;

*keep aar area ton n0-n4 mw0-mw4 n_samples;
run;

*****************Indsæt 0-år og middelvægt for hele perioden hvor W=.;

proc sort data=cb13 out=m14 (keep=year quarter div) nodupkey;
by quarter;
run;

data m15a;
set m14;
do year=1974 to 2025 by 1;
output;
end;
run;

data m15;
set m15a;
do div='IV', 'NO';
output;
end;
run;

proc sort data=m15;
by year quarter div;
run;

data m16;
merge cb13 m15;
by year quarter div;
run;

data m17;
set m16;
if n0=. then n0=0;
if n1=. then n1=0;
if n2=. then n2=0;
if n3=. then n3=0;
if n4=. then n4=0;

if ton=. then ton=0;
if year=. then delete;

run;

proc sort data=m17;
by quarter div;
run;

proc summary data=m17;
var mw0-mw4;
by quarter div;
output out=m18 (drop=_type_ _freq_) mean(mw0)=mmw0 mean(mw1)=mmw1 
mean(mw2)=mmw2 mean(mw3)=mmw3 mean(mw4)=mmw4
;
run;

data m19;
merge m17 m18;
by quarter div;
run;

data m20;
set m19;
if mw0=. then mw0=mmw0;
if mw1=. then mw1=mmw1;
if mw2=. then mw2=mmw2;
if mw3=. then mw3=mmw3;
if mw4=. then mw4=mmw4;

if n_samples lt 5  then mw0=mmw0;
if n_samples lt 5  then mw1=mmw1;
if n_samples lt 5  then mw2=mmw2;
if n_samples lt 5  then mw3=mmw3;
if n_samples lt 5  then mw4=mmw4;

n0_per_ton=n0/ton;
n1_per_ton=n1/ton;
n2_per_ton=n2/ton;
n3_per_ton=n3/ton;
n4_per_ton=n4/ton;

n0_n1=n0/n1;
n1_n2=n1/n2;
n2_n3=n2/n3;
n3_n4=n3/n4;

*if n_samples lt 5 then delete;

drop mmw0-mmw4;
run;

proc sort data=m19;
by quarter div;
run;

proc gplot data=m20;
plot (n0-n4)*year/overlay;
by quarter div;
symbol1 v=plus i=join c=black;
symbol2 v=plus i=join c=red;
symbol3 v=plus i=join c=blue;
symbol4 v=plus i=join c=green;
symbol5 v=plus i=join c=orange;
run;

proc gplot data=m19;
plot (mw0-mw4)*year/overlay;
by quarter;
run;

proc gplot data=m20;
plot (n0_per_ton n1_per_ton n2_per_ton n3_per_ton n4_per_ton)*year=div;
by quarter;
run;

*****************In 1985, there are no 3-year olds observed, in 1986 there are no samples*************;
****************Before 1974, there are no samples and SMS data are used*******************************;

data s1;
set in.sms_ns_2011;
if species ne 'Sprat' then delete;
sms_ton=yield__sop_;
sms_per_ton=c/sms_ton;
if quarter ne 3 then delete;
if age=0 then smsn0=c;
if age=1 then smsn1=c;
if age=2 then smsn2=c;
if age=3 then smsn3=0.91*c;
if age=3 then smsn4=0.09*c;
if age=0 then smsw0=weca;
if age=1 then smsw1=weca;
if age=2 then smsw2=weca;
if age=3 then smsw3=weca;
if age=3 then smsw4=weca;
run;

proc sort data=s1;
by year;
run;

proc summary data=s1;
var smsn0-smsn4 smsw0-smsw4;
by year;
output out=s2 (drop=_type_ _freq_) sum()=;
run;

proc summary data=s1;
var sms_ton;
by year ;
output out=s3 (drop=_type_ _freq_) sum()=;
run;

proc sort data=m20;
by year;
run;

data s4;
 merge m20 s2 s3;
 by year;
 run;

data s5;
set s4;
*if year in (1963,1964,1965,1966,1967,1968,1969,1970,1971,1972,1973,1985,1986) and div='IV' then id=1;
if id=1 then mw0=smsw0;
if id=1 then mw1=smsw1;
if id=1 then mw2=smsw2;
if id=1 then mw3=smsw3;
if id=1 then mw4=smsw4;
if id=1 and quarter ne 4 then n0=0;
if id=1 and quarter=4 then n0=smsn0;
if id=1 then n1=ton*smsn1/(sms_ton-mw0*n0);
if id=1 then n2=ton*smsn2/(sms_ton-mw0*n0);
if id=1 then n3=ton*smsn3/(sms_ton-mw0*n0);
if id=1 then n4=ton*smsn4/(sms_ton-mw0*n0);
if id=1 and quarter=4 then n1=(ton-smsn0*mw0)*smsn1/(sms_ton-mw0*n0);
if id=1 and quarter=4 then n2=(ton-smsn0*mw0)*smsn2/(sms_ton-mw0*n0);
if id=1 and quarter=4 then n3=(ton-smsn0*mw0)*smsn3/(sms_ton-mw0*n0);
if id=1 and quarter=4 then n4=(ton-smsn0*mw0)*smsn4/(sms_ton-mw0*n0);
run;

proc sort data=s4;
by quarter;
run;

proc gplot data=s4;
plot mw2*smsw2=quarter;
*by quarter;
run;


*proc sort data=s5;
*by year quarter;
*run;

*proc summary data=s5;
*var n0-n4;
*by year;
*output out=s6 sum()=;
*run;
/*
**************Adding final year q1 catches*******************;

data s6;
set s5;
if year=2019 then ton=.;
if year=2019 then n0=0;
if year=2019 then n1=0;
if year=2019 then n2=0;
if year=2019 then n3=0;
if year=2019 then n4=0;
run;

data s7;
set s6;/*
q12=0;
q34=0;
if quarter=1 then q12=ton;
if quarter=2 then q12=ton;
if quarter=3 then q34=ton;
if quarter=4 then q34=ton;
if quarter in (1,2) then year=year-1;
if year lt 2014 then delete;
if year ne 2017 and quarter ne 4 then n0=.;
if year ne 2017 and quarter ne 4 then n1=.;
if year ne 2017 and quarter ne 4 then n2=.;
if year ne 2017 and quarter ne 4 then n3=.;
if year ne 2017 and quarter ne 4 then n4=.;
run;

proc sort data=s7;
by div year;
run;

proc summary data=s7;
var n0-n4 q12 q34;
by div year;
output out=s8 sum()=;
run;

data s9;
set s8;
if year=2017 then q12=.;
ratio=q12/q34;
if year ne 2017 then q34=.;
run;

proc summary data=s9;
var n0-n4 ratio q34;
by div;
output out=s10 mean()=;
run;

data s11;
set s10;
n1last=n0;
n2last=n1;
n3last=n2;
n4last=n3+n4;
tonlast=q34*ratio;
year=2018;
keep div n1last n2last n3last n4last tonlast year;
run;

proc sort data=s5;
by div year;
run;

data s12;
merge s5 s11;
by div year;
run;

data s13;
set s12;
if year=2018 then quarter=1;
if year=2018 and quarter=1 then ton=tonlast;  ** replaced by TAC 2017 for area 4 below***;
*if year=2018 and quarter=1 and div='IV' then ton=33830;
if year=2018 and quarter=1 then n0=0;
if year=2018 and quarter=1 then n1=n1last;
if year=2018 and quarter=1 then n2=n2last;
if year=2018 and quarter=1 then n3=n3last;
if year=2018 and quarter=1 then n4=n4last;
run;

********SOP korrektion af mw***************************************************;
data m25;
set s5;
if quarter in (1,2) then sopcorr=ton/(n1*mw1+n2*mw2+n3*mw3+n4*mw4);
if quarter in (3,4) then sopcorr=ton/(n0*mw0+n1*mw1+n2*mw2+n3*mw3+n4*mw4);
if ton=0 then sopcorr=1;

mw0=sopcorr*mw0;
mw1=sopcorr*mw1;
mw2=sopcorr*mw2;
mw3=sopcorr*mw3;
mw4=sopcorr*mw4;
if quarter=. then delete;
sop=n0*mw0+n1*mw1+n2*mw2+n3*mw3+n4*mw4;
keep year quarter n0-n4 mw0-mw4 ton n_samples div;
run;

data m26;
set s5;
if quarter in (1,2) then sopcorr=ton/(n1*mw1+n2*mw2+n3*mw3+n4*mw4);
if quarter in (3,4) then sopcorr=ton/(n0*mw0+n1*mw1+n2*mw2+n3*mw3+n4*mw4);
if ton=0 then sopcorr=1;

if quarter ne 2 then mw1=sopcorr*mw1;
if quarter ne 2 then mw2=sopcorr*mw2;
if quarter ne 2 then mw3=sopcorr*mw3;
if quarter ne 2 then mw4=sopcorr*mw4;
*if year lt 1991 then delete;
if quarter=. then delete;
sop=n0*mw0+n1*mw1+n2*mw2+n3*mw3+n4*mw4;

wmw0=n0*mw0;
wmw1=n1*mw1;
wmw2=n2*mw2;
wmw3=n3*mw3;
wmw4=n4*mw4;
if quarter=2 then wmw1=mw1;
if quarter=2 then wmw2=mw2;
if quarter=2 then wmw3=mw3;
if quarter=2 then wmw4=mw4;
*if quarter in (1,2) then year=year-1;
*keep year quarter n0-n4 mw0-mw4 ton n_samples div;
run;

proc sort data=m26;
by div year quarter;
run;

proc summary data=m26;
var n_samples n0-n4 wmw0-wmw4 ton;
by div year quarter;
output out=m27 sum()= mean(wmw1)=w2mw1 mean(wmw2)=w2mw2 mean(wmw3)=w2mw3 mean(wmw4)=w2mw4;
run;

data m28;
set m27;
if year ne 2020 then mw0=wmw0/n0;
if year ne 2020 then mw1=wmw1/n1;
if year ne 2020 then mw2=wmw2/n2;
if year ne 2020 then mw3=wmw3/n3;
if year ne 2020 then mw4=wmw4/n4;
if quarter=2 then mw1=w2mw1;
if quarter=2 then mw2=w2mw2;
if quarter=2 then mw3=w2mw3;
if quarter=2 then mw4=w2mw4;
*if quarter=2 then mw0=wmw0;
*if quarter=2 then mw1=wmw1;
*if quarter=2 then mw2=wmw2;
*if quarter=2 then mw3=wmw3;
*if quarter=2 then mw4=wmw4;
*if year lt 1982 then delete;
*keep year quarter n0-n4 mw0-mw4 ton n_samples div;
run;

proc sort data=m28;
by div quarter;
run;

proc summary data=m28;
var mw0-mw4;
by div quarter;
output out=m29 mean(mw0)=mmw0 mean(mw1)=mmw1 mean(mw2)=mmw2 mean(mw3)=mmw3 mean(mw4)=mmw4;
run;

data m30;
merge m28 m29;
by div quarter;
run;

data m31;
set m30;
*if year=2018 then mw0=.;
*if year=2018 then mw1=.;
*if year=2018 then mw2=.;
*if year=2018 then mw3=.;
*if year=2018 then mw4=.;
if mw0=. then mw0=mmw0;
if mw1=. then mw1=mmw1;
if mw2=. then mw2=mmw2;
if mw3=. then mw3=mmw3;
if mw4=. then mw4=mmw4;
*sop2017=ton/(n1*mw1+n2*mw2+n3*mw3+n4*mw4);
*if year=2018 then n1=n1*sop2017;
*if year=2018 then n2=n2*sop2017;
*if year=2018 then n3=n3*sop2017;
*if year=2018 then n4=n4*sop2017;
keep year quarter n0-n4 mw0-mw4 ton n_samples div;
run;
/*
proc sort data=m31;
by div quarter;
run;

proc gplot data=m31;
plot (mw0-mw4)*year/overlay;
by div quarter;
symbol1 v=plus i=join c=black;
symbol2 v=plus i=join c=red;
symbol3 v=plus i=join c=blue;
symbol4 v=plus i=join c=green;
symbol5 v=plus i=join c=red;

run;

******Eksporter csv**;

proc sort data=m31;
by div year quarter;
run;

data miv;
set m31;
if div ne 'IV' then delete;
run;

proc export data=miv
   outfile='c:\ar\sprat\age_distributions\Total_catch_in_numbers_and_mean_weight_benchmark_IV_no_Q2_2019.csv'
   dbms=csv 
   replace;
run;
quit;

data miiia;
set m31;
if div ne 'NO' then delete;
if year lt 1974 then delete;
run;

proc export data=miiia
   outfile='c:\ar\sprat\age_distributions\Total_catch_in_numbers_and_mean_weight_benchmark_NO_no_Q2_2019.csv'
   dbms=csv 
   replace;
run;
quit;

*/
data m26;
set s5;
if quarter in (1,2) then sopcorr=ton/(n1*mw1+n2*mw2+n3*mw3+n4*mw4);
if quarter in (3,4) then sopcorr=ton/(n0*mw0+n1*mw1+n2*mw2+n3*mw3+n4*mw4);
if ton=0 then sopcorr=1;

mw0=sopcorr*mw0;
mw1=sopcorr*mw1;
mw2=sopcorr*mw2;
mw3=sopcorr*mw3;
mw4=sopcorr*mw4;

if quarter=. then delete;
if quarter in (1,2) then year=year-1;


if quarter in (1,2) then n0=n1;
if quarter in (1,2) then n1=n2;
if quarter in (1,2) then n2=n3;
if quarter in (1,2) then n3=n4;
if quarter in (3,4) then n3=n3+n4;

if quarter in (1,2) then mw0=mw1;
if quarter in (1,2) then mw1=mw2;
if quarter in (1,2) then mw2=mw3;
if quarter in (1,2) then mw3=mw4;
if quarter in (3,4) then mw3=(n3*mw3+n4*mw4)/(n3+n4);

wmw0=n0*mw0;
wmw1=n1*mw1;
wmw2=n2*mw2;
wmw3=n3*mw3;

*if quarter=2 then wmw0=mw0;
*if quarter=2 then wmw1=mw1;
*if quarter=2 then wmw2=mw2;
*if quarter=2 then wmw3=mw3;
*if quarter=2 then wmw4=mw4;

quarter=quarter-2;
if quarter lt 1 then quarter=quarter+4;

*keep year quarter n0-n4 mw0-mw4 ton n_samples div;
run;

proc sort data=m26;
by div year quarter;
run;

proc summary data=m26;
var n_samples n0-n3 wmw0-wmw3 ton;
by div year quarter;
output out=m27 sum()= mean(wmw1)=w2mw1 mean(wmw2)=w2mw2 mean(wmw3)=w2mw3 mean(wmw0)=w2mw0;
run;

data m28;
set m27;
if year lt 2026 then mw0=wmw0/n0;
if year lt 2026 then mw1=wmw1/n1;
if year lt 2026 then mw2=wmw2/n2;
if year lt 2026 then mw3=wmw3/n3;
if quarter in (1,2) then  mw0=wmw0/n0;
if quarter in (1,2) then  mw1=wmw1/n1;
if quarter in (1,2) then  mw2=wmw2/n2;
if quarter in (1,2) then  mw3=wmw3/n3;
*if quarter in (4) then  mw0=w2mw0;
*if quarter in (4) then  mw1=w2mw1;
*if quarter in (4) then  mw2=w2mw2;
*if quarter in (4) then  mw3=w2mw3;
*if quarter in (4) then  mw4=w2mw4;
*if year lt 1982 then delete;
*keep year quarter n0-n3 mw0-mw3 ton n_samples div;
run;

proc sort data=m28;
by div quarter;
run;

proc summary data=m28;
var mw0-mw3;
by div quarter ;
output out=m29 mean(mw0)=mmw0 mean(mw1)=mmw1 mean(mw2)=mmw2 mean(mw3)=mmw3;
run;

data m30;
merge m28 m29;
by div quarter;
run;

data m31;
set m30;
*if year=2020 and quarter=3 then mw0=.;
*if year=2020 and quarter=3  then mw1=.;
*if year=2020 and quarter=3  then mw2=.;
*if year=2020 and quarter=3  then mw3=.;
if mw0=. then mw0=mmw0;
if mw1=. then mw1=mmw1;
if mw2=. then mw2=mmw2;
if mw3=. then mw3=mmw3;
*sop2017=ton/(n0*mw0+n1*mw1+n2*mw2+n3*mw3);
*if year=2017 and quarter=3  then n0=n0*sop2017;
*if year=2017 and quarter=3  then n1=n1*sop2017;
*if year=2017 and quarter=3  then n2=n2*sop2017;
*if year=2017 and quarter=3  then n3=n3*sop2017;
nperton0=n0/ton;
nperton1=n1/ton;
nperton2=n2/ton;
nperton3=n3/ton;
if div='NO' and year lt 1974 then delete;
keep year quarter n0-n4 mw0-mw4 ton n_samples div;
run;

proc sort data=m31;
by div quarter;
run;

proc gplot data=m31;
plot (nperton0-nperton3)*year/overlay;
by div quarter;
symbol1 v=plus i=join c=black;
symbol2 v=plus i=join c=red;
symbol3 v=plus i=join c=blue;
symbol4 v=plus i=join c=green;
symbol5 v=plus i=join c=red;

run;
*nperton0-nperton3 mw0-mw3;
******Eksporter csv**;

proc sort data=m31;
by div year quarter;
run;

data miv;
set m31;
if div ne 'IV' then delete;
if year lt 1974 then delete;
run;

proc export data=miv
   outfile= "&path_output\canum_weca_jul_jun_season_IV_with_Q2_no_SMS_no_SEcoast_v30.csv"
   dbms=csv 
   replace;
run;
quit;

data miiia;
set m31;
if div ne 'NO' then delete;
if year lt 1974 then delete;
run;

proc export data=miiia
   outfile= "&path_output\canum_weca_jul_jun_season_NO_with_Q2_no_SMS_no_SEcoast_v30.csv"
   dbms=csv 
   replace;
run;
quit;

*****************************************************************************;
*Half-year - season;

data hy;
set m31;
if div ne 'IV' then delete;
if year lt 1974 then delete;

if quarter in (1, 2) then hy = 1;
if quarter in (3, 4) then hy = 2;

t0=n0*mw0;
t1=n1*mw1;
t2=n2*mw2;
t3=n3*mw3;

run;

proc summary data=hy;
var n0-n3 t0-t3 ton mw0-mw3 n_samples;
by div year hy;
output out=hy1 sum()= mean(mw0)=mmw0 mean(mw1)=mmw1 mean(mw2)=mmw2 mean(mw3)=mmw3;
run;

data hy2; 
set hy1;

mw0=t0/n0;
mw1=t1/n1;
mw2=t2/n2;
mw3=t3/n3;

drop mmw0-mmw3 t0-t3 _TYPE_ _FREQ_;
run;

proc sort data=hy2;
by div hy;
run;

proc summary data=hy2;
var mw0-mw3;
by div hy;
output out=hy3 mean(mw0)=mmw0 mean(mw1)=mmw1 mean(mw2)=mmw2 mean(mw3)=mmw3;
run;

data hy4;
merge hy2 hy3;
by div hy;
run;

data hy5;
set hy4;

if mw0=. then mw0=mmw0;
if mw1=. then mw1=mmw1;
if mw2=. then mw2=mmw2;
if mw3=. then mw3=mmw3;

drop mmw0-mmw3 t0-t3 _TYPE_ _FREQ_;
run;

proc export data=hy5
   outfile= "&path_output\canum_weca_jul_jun_halfyear_IV_with_Q2_no_SMS_no_SEcoast_v30.csv"
   dbms=csv 
   replace;
run;
quit;

* Proportion in number per hy;
data hy6;
set hy5;

n_tot=n0+n1+n2+n3;

n0_prop=n0/n_tot;
n1_prop=n1/n_tot;
n2_prop=n2/n_tot;
n3_prop=n3/n_tot;

check_prop=n0_prop+n1_prop+n2_prop+n3_prop;

keep div year hy n_samples n0_prop n1_prop n2_prop n3_prop n_tot ton check_prop;
run;

proc export data=hy6 (drop = check_prop)
   outfile= "&path_output\no_prop_jul_jun_halfyear_IV_with_Q2_no_SMS_no_SEcoast_v30.csv"
   dbms=csv 
   replace;
run;
quit;

*****************************************************************************;
*Model year - season;

data year;
set m31;
if div ne 'IV' then delete;
if year lt 1974 then delete;

t0=n0*mw0;
t1=n1*mw1;
t2=n2*mw2;
t3=n3*mw3;

run;

proc summary data=year;
var n0-n3 t0-t3 ton mw0-mw3;
by div year;
output out=year1 sum()= mean(mw0)=mmw0 mean(mw1)=mmw1 mean(mw2)=mmw2 mean(mw3)=mmw3;
run;

data year2; 
set year1;

mw0=t0/n0;
mw1=t1/n1;
mw2=t2/n2;
mw3=t3/n3;

if mw0=. then mw0=mmw0;
if mw1=. then mw1=mmw0;
if mw2=. then mw2=mmw0;
if mw3=. then mw3=mmw0;

drop mmw0-mmw3 t0-t3 _TYPE_ _FREQ_;
run;

proc export data=year2
   outfile= "&path_output\canum_weca_jul_jun_year_IV_with_Q2_no_SMS_no_SEcoast_v30.csv"
   dbms=csv 
   replace;
run;
quit;

proc sql;
create table check_season_ton_sum as
select sum(ton/1000) as ton, sum(n0/1000) as n0, sum(n1/1000) as n1, sum(n2/1000) as n2, sum(n3/1000) as n3
from miv;
proc sql;
create table check_hy_ton_sum as
select sum(ton/1000) as ton, sum(n0/1000) as n0, sum(n1/1000) as n1, sum(n2/1000) as n2, sum(n3/1000) as n3
from hy5;
proc sql;
create table check_year_ton_sum as
select sum(ton/1000) as ton, sum(n0/1000) as n0, sum(n1/1000) as n1, sum(n2/1000) as n2, sum(n3/1000) as n3
from year2;

proc sql;
create table check_hy_prop_sum as
select sum(ton/1000) as ton
from hy6;

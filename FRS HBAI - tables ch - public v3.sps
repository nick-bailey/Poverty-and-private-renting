* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - tables ch - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure3 and 7 for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   ALSO MAKES AGGREGATE TABLES FOR CHILDREN BY TENURE, YEAR, AGE, [REGION,] [POVERTY STATUS]. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** IF RUNNING THIS SYNTAX ON ITS OWN, NEED TO SET FILE HANDLE FOR 'FRS' FOLDER HERE.
* file handle frs / name= "K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.

*** select children only. 
select if (ch=1).
execute.


*** 0. Preliminaries. 
* levels.
variable level tenure2 (nominal).
formats yearcode (f4.0).
value labels scot 1 'Rest of UK' 2 'Scotland'.

* age - 1yr bands.
compute age2=age.
var labels age2 'Age'.
recode age2 (19=18) (else=copy).
value labels age2 18 '18/19'.
formats age2 (f2.0).
* freq age2 .

* complete cases only - here, this has no effect at present. 
* descriptives tenure2 yearcode age2.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age2)).



*** 1a. Make dataset with means of tenure2 by age2 and year with smoothing. 
dataset activate main.
weight by gs_newbu.

* for fig quoted in text, look at children 5 or under.
* temp. 
* select if (age2 lt 6).
* crosstabs yearcode by tenure2 /cells row.



* sort cases. 
sort cases by yearcode age2 tenure2.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1a.
AGGREGATE
  /OUTFILE='aggr_1a'
  /BREAK=yearcode age2 tenure2
  /N_ten3=N.

* aggregate onto that file the total number in each year/age group.
DATASET ACTIVATE aggr_1a.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all=SUM(N_ten3).

* make % in each tenure. 
compute ten3=N_ten3/N_all.
* freq ten3 /histogram /formats notable /statistics all.
* freq N_ten3 /histogram /formats notable.
execute.

* patch for missing values (i.e. year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP yearcode=1994 TO 2018.
LEAVE yearcode.
-  LOOP tenure2=1 TO 4.
-  LEAVE tenure2.
-    LOOP age2=0 to 18.
-    END CASE.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by yearcode age2 tenure2.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1a
  by yearcode age2 tenure2.
execute.
* where no data for ten3, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten3)) ten3=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten3). 
execute.
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1a.
dataset copy aggr_1a.
dataset activate aggr_1a.
dataset close temp.

* smoothing. 
dataset activate aggr_1a.
* 1.
sort cases by tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3).
execute.
* 2.
sort cases by tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3).
execute.
* 3.
sort cases by tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3).
execute.
* 4.
sort cases by tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3).
execute.
* smoother.
compute ten3s=mean(ten3, ten3_1, ten3_2, ten3_3, ten3_4). 
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4.
execute.

* checking: within each yearcode x age2 group, check that sum of ten4 and ten42 percentages is 1 in every case.  
sort cases by yearcode age2 tenure2.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /ten3_sum=SUM(ten3) 
  /ten3s_sum=SUM(ten3s).
descriptives ten3_sum ten3s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten3s = N_all2 * ten3s.
execute.

* check to see if sum of counts for the different tenures equals total for yearcode x age2 group - checks should be zero in every case. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_ten3s_sum=SUM(N_ten3s).

compute check=n_ten3s_sum - N_all2.
compute checkpct=check/n_ten3s_sum.
descriptives check checkpct.

* add UK/region identifiers.
compute region=0.
STRING regname (A20).
compute regname='UK'.
execute.


*** Figure 3: Heatmaps - age2 by year by tenure - children.
dataset activate aggr_1a.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
*.
temp. 
compute ten3s=ten3s*100.
formats ten3s (pct2).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Age"))
  ELEMENT: polygon(position(yearcode*age2*tenure2), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* save result, reordering vars. 
save outfile = 'temp1a.sav' 
    /keep region regname yearcode age2 tenure2 N_ten3s N_all2.
* close temp file. 
dataset close aggr_1a.


*** 1b. Make dataset with means of tenure2 by age2 and year and poverty AHC with smoothing. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by low60ahc yearcode age2 tenure2.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1b.
AGGREGATE
  /OUTFILE='aggr_1b'
  /BREAK=low60ahc yearcode age2 tenure2
  /N_ten3=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_1b.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc yearcode age2
  /N_all=SUM(N_ten3).

* make % in each tenure. 
compute ten3=N_ten3/N_all.
* freq ten3 /histogram /formats notable /statistics all.
* freq N_ten3 /histogram /formats notable.
execute.

* patch for missing values (i.e. low60ahc/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP low60ahc=0 TO 1.
LEAVE low60ahc.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure2=1 TO 4.
-    LEAVE tenure2.
-      LOOP age2=0 to 18.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by low60ahc yearcode age2 tenure2.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1b
  by low60ahc yearcode age2 tenure2.
execute.
* where no data for ten3, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten3)) ten3=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc yearcode age2
  /N_all2=SUM(N_ten3). 
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1b.
dataset copy aggr_1b.
dataset close temp.

* smoothing. 
dataset activate aggr_1b. 
* 1.
sort cases by low60ahc tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3).
execute.
* 2.
sort cases by low60ahc tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3).
execute.
* 3.
sort cases by low60ahc tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3).
execute.
* 4.
sort cases by low60ahc tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3).
execute.
* smoother.
compute ten3s=mean(ten3, ten3_1, ten3_2, ten3_3, ten3_4). 
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4.
execute.

* checking. 
sort cases by low60ahc yearcode age2 tenure2.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc  yearcode age2
  /ten3_sum=SUM(ten3) 
  /ten3s_sum=SUM(ten3s).
descriptives ten3_sum ten3s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten3s = N_all2 * ten3s.
execute.

* check to see if sum of tenures equals total - it doesn't due to smoothing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc  yearcode age2
  /N_ten3s_sum=SUM(N_ten3s).

compute check=n_ten3s_sum - N_all2.
compute checkpct=check/n_ten3s_sum.
descriptives check checkpct.

* add UK/region identifiers.
compute region=0.
STRING regname (A20).
compute regname='UK'.
execute.

* Figure 7: Heatmaps - age2 by year by tenure2 by poverty AHC - children.
dataset active aggr_1b.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten3s=ten3s*100.
formats ten3s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=low60ahc yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: low60ahc=col(source(s), name("low60ahc"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure2*low60ahc), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* save result, reordering vars. 
save outfile = 'temp1b.sav' 
    /keep low60ahc region regname yearcode age2 tenure2 N_ten3s N_all2.
dataset close aggr_1b.


*** 1c. Make dataset with means of tenure2 by age2 and year and poverty BHC with smoothing. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by low60bhc yearcode age2 tenure2.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1c.
AGGREGATE
  /OUTFILE='aggr_1c'
  /BREAK=low60bhc yearcode age2 tenure2
  /N_ten3=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_1c.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc yearcode age2
  /N_all=SUM(N_ten3).

* make % in each tenure. 
compute ten3=N_ten3/N_all.
* freq ten3 /histogram /formats notable /statistics all.
* freq N_ten3 /histogram /formats notable.
execute.

* patch for missing values (i.e. low60bhc/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP low60bhc=0 TO 1.
LEAVE low60bhc.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure2=1 TO 4.
-    LEAVE tenure2.
-      LOOP age2=0 to 18.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by low60bhc yearcode age2 tenure2.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1c
  by low60bhc yearcode age2 tenure2.
execute.
* where no data for ten3, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten3)) ten3=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc yearcode age2
  /N_all2=SUM(N_ten3). 
execute.
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1c.
dataset copy aggr_1c.
dataset close temp.

* smoothing. 
dataset activate aggr_1c. 
* 1.
sort cases by low60bhc tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3).
execute.
* 2.
sort cases by low60bhc tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3).
execute.
* 3.
sort cases by low60bhc tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3).
execute.
* 4.
sort cases by low60bhc tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3).
execute.
* smoother.
compute ten3s=mean(ten3, ten3_1, ten3_2, ten3_3, ten3_4). 
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4.
execute.

* checking. 
sort cases by low60bhc yearcode age2 tenure2.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc  yearcode age2
  /ten3_sum=SUM(ten3) 
  /ten3s_sum=SUM(ten3s).
descriptives ten3_sum ten3s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten3s = N_all2 * ten3s.
execute.

* check to see if sum of tenures equals total - it doesn't due to smoothing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc  yearcode age2
  /N_ten3s_sum=SUM(N_ten3s).

compute check=n_ten3s_sum - N_all2.
compute checkpct=check/n_ten3s_sum.
descriptives check checkpct.

* add UK/region identifiers.
compute region=0.
STRING regname (A20).
compute regname='UK'.
execute.

* Figure 7 [bhc]: Heatmaps - age2 by year by tenure2 by poverty - children.
dataset active aggr_1c.
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
temp. 
compute ten3s=ten3s*100.
formats ten3s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=low60bhc yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,700px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: low60bhc=col(source(s), name("low60bhc"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure2*low60bhc), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* save result, reordering vars. 
save outfile = 'temp1c.sav' 
    /keep low60bhc region regname yearcode age2 tenure2 N_ten3s N_all2.
dataset close aggr_1c.



*** 2a. Make dataset with means of tenure2 by age2 and year and region with smoothing. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by region yearcode age2 tenure2.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2a.
AGGREGATE
  /OUTFILE='aggr_2a'
  /BREAK=region yearcode age2 tenure2
  /N_ten3=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_2a.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /N_all=SUM(N_ten3).

* make % in each tenure. 
compute ten3=N_ten3/N_all.
* freq ten3 /histogram /formats notable /statistics all.
* freq N_ten3 /histogram /formats notable.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP region=1 TO 6.
LEAVE region.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure2=1 TO 4.
-    LEAVE tenure2.
-      LOOP age2=0 to 18.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by region yearcode age2 tenure2.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2a
  by region yearcode age2 tenure2.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten3)) ten3=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten3)) ten3=0.
execute.

* problem that ten3 does not sum to 1 if no date for given region/year/age.
* in these cases, borrow from adjacent ages first.
* make var to indicate sum of ten4 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /ten3_sum=SUM(ten3). 
* make lag vars for ages either side.
* 1.
sort cases by region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_a=lag(ten3).
execute.
* 2.
sort cases by region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_b=lag(ten3).
execute.
if (ten3_sum lt .99) ten3=mean(ten3_a, ten3_b).
* check ten3_sum again.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /ten3_sum2=SUM(ten3). 
* freq ten3_sum ten3_sum2.
delete variables ten3_a, ten3_b, ten3_sum, ten3_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten3). 
* replace dataset with new one.
DATASET CLOSE aggr_2a.
dataset copy aggr_2a.
dataset close temp.

* smoothing. 
dataset activate aggr_2a. 
* 1.
sort cases by region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3).
execute.
* 2.
sort cases by region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3).
execute.
* 3.
sort cases by region tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3).
execute.
* 4.
sort cases by region tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3).
execute.
* smoother.
compute ten3s=mean(ten3, ten3_1, ten3_2, ten3_3, ten3_4). 
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4.
execute.

*** with region, for ten3s, now need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten3s=$sysmis.

*** temp checking. 
dataset activate aggr_2a.
sort cases by region yearcode age2 tenure2.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /ten3_sum=SUM(ten3) 
  /ten3s_sum=SUM(ten3s).
descriptives ten3_sum ten3s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten3s = N_all2 * ten3s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /N_ten3s_sum=SUM(N_ten3s).
compute check=n_ten3s_sum - N_all2.
compute checkpct=check/n_ten3s_sum.
descriptives check checkpct.

* add area identifiers.
string regname (a20).
if (region=1) regname = "London".
if (region=2) regname  = "South".
if (region=3) regname  = "Midlands".
if (region=4) regname  = "North/Wales".
if (region=5) regname  = "Scotland".
if (region=6) regname  = "Northern Ireland".
execute.

* Figure: Heatmaps - age2 by year by tenure2 by region.
dataset active aggr_2a.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,1600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Age"))
  ELEMENT: polygon(position(yearcode*age2*tenure2*region), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

save outfile = 'temp2a.sav' 
    /keep region regname yearcode age2 tenure2 N_ten3s N_all2.
dataset close aggr_2a.



*** 2b. Make dataset with means of tenure2 by age2 and year and region and low60ahc with smoothing. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by low60ahc region yearcode age2 tenure2.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2b.
AGGREGATE
  /OUTFILE='aggr_2b'
  /BREAK=low60ahc region yearcode age2 tenure2
  /N_ten3=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_2b.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc region yearcode age2
  /N_all=SUM(N_ten3).

* make % in each tenure. 
compute ten3=N_ten3/N_all.
* freq ten3 /histogram /formats notable /statistics all.
* freq N_ten3 /histogram /formats notable.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP low60ahc=0 TO 1.
LEAVE low60ahc.
- LOOP region=1 TO 6.
- LEAVE region.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure2=1 TO 4.
-    LEAVE tenure2.
-      LOOP age2=0 to 18.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by low60ahc region yearcode age2 tenure2.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2b
  by low60ahc region yearcode age2 tenure2.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten3)) ten3=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten3)) ten3=0.
execute.

* problem that ten3 does not sum to 1 if no date for given region/year/age.
* in these cases, borrow from adjacent ages first.
* make var to indicate sum of ten3 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc region yearcode age2
  /ten3_sum=SUM(ten3). 
* make lag vars for ages either side.
* 1.
sort cases by low60ahc region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_a=lag(ten3).
execute.
* 2.
sort cases by low60ahc region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_b=lag(ten3).
execute.
if (ten3_sum lt .99) ten3=mean(ten3_a, ten3_b).
execute.
* check ten3_sum again.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc region yearcode age2
  /ten3_sum2=SUM(ten3). 
* freq ten3_sum ten3_sum2.
delete variables ten3_a, ten3_b, ten3_sum, ten3_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten3). 
* replace dataset with new one.
DATASET CLOSE aggr_2b.
dataset copy aggr_2b.
dataset close temp.

* smoothing. 
dataset activate aggr_2b. 
* 1.
sort cases by low60ahc region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3).
execute.
* 2.
sort cases by low60ahc region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3).
execute.
* 3.
sort cases by low60ahc region tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3).
execute.
* 4.
sort cases by low60ahc region tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3).
execute.
* smoother.
compute ten3s=mean(ten3, ten3_1, ten3_2, ten3_3, ten3_4). 
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4.
execute.

* run smoothing a second time. 
dataset activate aggr_2b. 
* 1.
sort cases by low60ahc region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3s).
execute.
* 2.
sort cases by low60ahc region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3s).
execute.
* 3.
sort cases by low60ahc region tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3s).
execute.
* 4.
sort cases by low60ahc region tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3s).
execute.
* smoother - ave of cell plus adjacents.
compute ten3s2=mean(ten3s, ten3_1, ten3_2, ten3_3, ten3_4). 
compute ten3s=ten3s2.
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4 ten3s2.
execute.

*** with region, for ten3s, now need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten3s=$sysmis.

*** checking sum of tenure shares is 1 in all cases - unsmoothed and smoothed. 
dataset activate aggr_2b.
sort cases by low60ahc region yearcode age2 tenure2.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc region yearcode age2
  /ten3_sum=SUM(ten3) 
  /ten3s_sum=SUM(ten3s).
descriptives ten3_sum ten3s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten3s = N_all2 * ten3s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc region yearcode age2
  /N_ten3s_sum=SUM(N_ten3s).
compute check=n_ten3s_sum - N_all2.
compute checkpct=check/n_ten3s_sum.
descriptives check checkpct.

* add area identifiers.
string regname (a20).
if (region=1) regname = "London".
if (region=2) regname  = "South".
if (region=3) regname  = "Midlands".
if (region=4) regname  = "North/Wales".
if (region=5) regname  = "Scotland".
if (region=6) regname  = "Northern Ireland".
execute.

* Figure: Heatmaps - age2 by year by tenure2 by region.
dataset active aggr_2b.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=low60ahc region yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,1600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: low60ahc=col(source(s), name("low60ahc"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Age"))
  ELEMENT: polygon(position(yearcode*age2*tenure2*region*low60ahc), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

save outfile = 'temp2b.sav' 
    /keep low60ahc region regname yearcode age2 tenure2 N_ten3s N_all2.
dataset close aggr_2b.


*** 2c. Make dataset with means of tenure2 by age2 and year and region and low60bhc with smoothing. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by low60bhc region yearcode age2 tenure2.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2c.
AGGREGATE
  /OUTFILE='aggr_2c'
  /BREAK=low60bhc region yearcode age2 tenure2
  /N_ten3=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_2c.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc region yearcode age2
  /N_all=SUM(N_ten3).

* make % in each tenure. 
compute ten3=N_ten3/N_all.
* freq ten3 /histogram /formats notable /statistics all.
* freq N_ten3 /histogram /formats notable.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP low60bhc=0 TO 1.
LEAVE low60bhc.
- LOOP region=1 TO 6.
- LEAVE region.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure2=1 TO 4.
-    LEAVE tenure2.
-      LOOP age2=0 to 18.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by low60bhc region yearcode age2 tenure2.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2c
  by low60bhc region yearcode age2 tenure2.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten3)) ten3=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten3)) ten3=0.
execute.
* problem that ten3 does not sum to 1 if no date for given region/year/age.
* in these cases, borrow from adjacent ages first.
* make var to indicate sum of ten3 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc region yearcode age2
  /ten3_sum=SUM(ten3). 
* make lag vars for ages either side.
* 1.
sort cases by low60bhc region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_a=lag(ten3).
execute.
* 2.
sort cases by low60bhc region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_b=lag(ten3).
execute.
if (ten3_sum lt .99) ten3=mean(ten3_a, ten3_b).
execute.
* check ten3_sum again.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc region yearcode age2
  /ten3_sum2=SUM(ten3). 
* freq ten3_sum ten3_sum2.
delete variables ten3_a, ten3_b, ten3_sum, ten3_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten3). 
* replace dataset with new one.
DATASET CLOSE aggr_2c.
dataset copy aggr_2c.
dataset close temp.

* smoothing. 
dataset activate aggr_2c. 
* 1.
sort cases by low60bhc region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3).
execute.
* 2.
sort cases by low60bhc region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3).
execute.
* 3.
sort cases by low60bhc region tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3).
execute.
* 4.
sort cases by low60bhc region tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3).
execute.
* smoother.
compute ten3s=mean(ten3, ten3_1, ten3_2, ten3_3, ten3_4). 
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4.
execute.

* run smoothing a second time. 
dataset activate aggr_2c. 
* 1.
sort cases by low60bhc region tenure2 yearcode age2.
execute.
if (lag(age2) lt age2) ten3_1=lag(ten3s).
execute.
* 2.
sort cases by low60bhc region tenure2 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten3_2=lag(ten3s).
execute.
* 3.
sort cases by low60bhc region tenure2 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten3_3=lag(ten3s).
execute.
* 4.
sort cases by low60bhc region tenure2  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten3_4=lag(ten3s).
execute.
* smoother - ave of cell plus adjacents.
compute ten3s2=mean(ten3s, ten3_1, ten3_2, ten3_3, ten3_4). 
compute ten3s=ten3s2.
execute.
delete variables ten3_1 ten3_2 ten3_3 ten3_4 ten3s2.
execute.

*** with region, for ten3s, now need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten3s=$sysmis.

*** checking sum of tenure shares is 1 in all cases - unsmoothed and smoothed. 
dataset activate aggr_2c.
sort cases by low60bhc region yearcode age2 tenure2.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc region yearcode age2
  /ten3_sum=SUM(ten3) 
  /ten3s_sum=SUM(ten3s).
descriptives ten3_sum ten3s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten3s = N_all2 * ten3s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60bhc region yearcode age2
  /N_ten3s_sum=SUM(N_ten3s).
compute check=n_ten3s_sum - N_all2.
compute checkpct=check/n_ten3s_sum.
descriptives check checkpct.

* add area identifiers.
string regname (a20).
if (region=1) regname = "London".
if (region=2) regname  = "South".
if (region=3) regname  = "Midlands".
if (region=4) regname  = "North/Wales".
if (region=5) regname  = "Scotland".
if (region=6) regname  = "Northern Ireland".
execute.

* Figure: Heatmaps - age2 by year by tenure2 by region.
dataset active aggr_2c.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=low60bhc region yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,1600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: low60bhc=col(source(s), name("low60bhc"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Age"))
  ELEMENT: polygon(position(yearcode*age2*tenure2*region*low60bhc), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

save outfile = 'temp2c.sav' 
    /keep low60bhc region regname yearcode age2 tenure2 N_ten3s N_all2.
dataset close aggr_2c.


*** 3. merge files together. 

* UK and regions - no poverty split.
get file = 'temp1a.sav' . 
dataset name final1.

DATASET ACTIVATE final1.
ADD FILES /FILE=*
  /FILE='temp2a.sav'.
EXECUTE.

* add poverty status var.
compute poverty_status=0.


* UK and regions - poverty AHC split.
get file = 'temp1b.sav' . 
dataset name final2.

DATASET ACTIVATE final2.
ADD FILES /FILE=*
  /FILE='temp2b.sav'.
EXECUTE.

* adjust poverty var name and values for merging. 
RENAME VARIABLES (low60ahc = poverty_status).
recode poverty_status (0=1) (1=2).


* UK and regions - poverty BHC split.
get file = 'temp1c.sav' . 
dataset name final3.

DATASET ACTIVATE final3.
ADD FILES /FILE=*
  /FILE='temp2c.sav'.
EXECUTE.

* adjust poverty var name and values for merging. 
RENAME VARIABLES (low60bhc = poverty_status).
recode poverty_status (0=3) (1=4).


* merge these three datasets together.
DATASET ACTIVATE final1.
ADD FILES /FILE=*
  /FILE=final2
  /FILE=final3.
EXECUTE.

* formats.
formats tenure2 poverty_status (f2.0).
formats N_ten3s N_all2 (f8.0).

* varname and labels for poverty_status.
VARIABLE LABELS poverty_status 'Poverty status'.
value lables poverty_status 
  0 'All' 
  1 'Not poor (AHC)' 
  2 'Poor (AHC)'
  3 'Not poor (BHC)'
  4 'Poor (BHC)'.

* add string var for poverty.
string poverty (A20).
if (poverty_status=0) poverty = 'All'. 
if (poverty_status=1) poverty = 'Not poor (AHC)'. 
if (poverty_status=2) poverty = 'Poor (AHC)'.
if (poverty_status=3) poverty = 'Not poor (BHC)'.
if (poverty_status=4) poverty = 'Poor (BHC)'.

* add string var for tenure.
string tenurename (A20).
if (tenure2=1) tenurename='Owner occupier'.
if (tenure2=2) tenurename='Social rent'.
if (tenure2=3) tenurename='Private rent'.
if (tenure2=4) tenurename='Care of/rent free'.
execute.

* rename vars to make same as adult. 
rename variables (tenure2 = tenure4)
   (N_ten3s = N_ten4s).

* save combined results - reordering vars.
save outfile = 'FRS HBAI - tables ch.sav' 
   /keep region regname yearcode age2 tenure4 tenurename poverty_status poverty N_ten4s N_all2.

* and as csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - tables ch.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep region regname yearcode age2 tenure4 tenurename poverty_status poverty N_ten4s N_all2
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

* close datasets.
dataset close final1.
dataset close final2.
dataset close final3.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 3 7.spv'
 LOCK=NO.


*** Figure 3: Heatmaps - age2 by year by tenure - children.
output close all.
get file = 'temp1a.sav' . 
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten3s=N_ten3s/N_all2*100.
formats ten3s (pct2).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Age"))
  ELEMENT: polygon(position(yearcode*age2*tenure2), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig3.tiff'
     PERCENTSIZE=100.


* Figure 7: Heatmaps - age2 by year by tenure2 by poverty AHC - children.
output close all.
get file = 'temp1b.sav' . 
execute.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten3s=N_ten3s/N_all2*100.
formats ten3s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=low60ahc yearcode age2 tenure2 ten3s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: low60ahc=col(source(s), name("low60ahc"), unit.category())
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: ten3s=col(source(s), name("ten3s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure2*low60ahc), color.interior(summary.sum(ten3s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig7.tiff'
     PERCENTSIZE=100.



* activate main - so all temp files can be closed. 
dataset activate main.
dataset close all.

* tidy up temporary files. 
erase file = 'temp1a.sav'.
erase file = 'temp1b.sav'.
erase file = 'temp1c.sav'.
erase file = 'temp2a.sav'.
erase file = 'temp2b.sav'.
erase file = 'temp2c.sav'.


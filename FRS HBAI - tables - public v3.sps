* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - tables - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure2 and 4 for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   ALSO MAKES AGGREGATE TABLES BY TENURE, YEAR, AGE, [REGION,] [POVERTY STATUS]. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** IF RUNNING THIS SYNTAX ON ITS OWN, NEED TO SET FILE HANDLE FOR 'FRS' FOLDER HERE.
* file handle frs / name= "K:/Data store/FRS".
* cd frs. 


***   Structure of syntax file. 
* 0. Preliminaries. 
* 1a. Tenure x age x year  [whole UK].
* 1b. Tenure x age x year x poverty AHC  [whole UK].
* 1c. Tenure x age x year x poverty BHC  [whole UK].
* 2a. Tenure x age x year x region. 
* 2b. Tenure x age x year x region x poverty AHC  . 
* 2c. Tenure x age x year x region x poverty BHC  . 
* 3. Join files for RShiny app.


*** 0. Preliminaries. 

* open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.

* var levels.
variable level tenure4 (nominal).
formats yearcode (f4.0).

* age - 1yr bands.
compute age2=age80.
var labels age2 'Age'.
if (age2 le 16) age2=16.
if (age2 ge 80) age2=80.
value labels age2 80 '80+'.
formats age2 (f2.0).
* freq age2 .

* complete cases only . 
* descriptives tenure2 yearcode age2.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age2)).
execute.



*** 1a. Make dataset with means of tenure4 by age2 and year with smoothing. 
dataset activate main.
weight by gs_newbu.   

* sort cases. 
sort cases by yearcode age2 tenure4.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1a.
AGGREGATE
  /OUTFILE='aggr_1a'
  /BREAK=yearcode age2 tenure4
  /N_ten4=N.

* aggregate onto that file the total number in each year/age group.
DATASET ACTIVATE aggr_1a.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
* freq ten4 /histogram /formats notable /statistics all.
* freq N_ten4 /histogram /formats notable.
execute.

* patch for missing values (i.e. year/age/tenure combinations where no cases). 
* make blank dataset with case for every year/age/tenure combination.
INPUT PROGRAM.
LOOP yearcode=1994 TO 2018.
LEAVE yearcode.
-  LOOP tenure4=1 TO 4.
-  LEAVE tenure4.
-    LOOP age2=16 to 80.
-    END CASE.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by yearcode age2 tenure4.
dataset name temp.
dataset activate temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1a
  by yearcode age2 tenure4.
execute.
* where no data for ten4, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten4)) ten4=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten4). 
execute.
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1a.
dataset copy aggr_1a.
dataset close temp.

* smoothing process - creates average for four adjacent cells hor and vert; takes ave of cell and that average. . 
dataset activate aggr_1a.
* 1.
sort cases by tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoothing - mean of cell plus four adjacents.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

* checking: within each yearcode x age2 group, check that sum of ten4 and ten42 percentages is 1 in every case.  
sort cases by yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of counts for the different tenures equals total for yearcode x age2 group - checks should be zero in every case. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_ten4s_sum=SUM(N_ten4s).

compute check=n_ten4s_sum - N_all2.
compute checkpct=check/n_ten4s_sum.
descriptives check checkpct.

* add UK/region identifiers.
compute region=0.
STRING regname (A20).
compute regname='UK'.
execute.

*** Figure 2: tenure by age heatmap - for checking here.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten4s=ten4s*100.
formats ten4s (pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,800px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* save result, reordering vars. 
save outfile = 'temp1a.sav' 
    /keep region regname yearcode age2 tenure4 N_ten4s N_all2.
* close temp file. 
dataset close aggr_1a.



*** 1b. Make dataset with means of tenure4 by age2 and year and poverty AHC with smoothing. 
dataset activate main.
weight by gs_newbu.

* set temporary poverty measure to AHC. 
compute pov=low60ahc.
var labels pov 'Poverty status'.
value labels pov 0 'Not poor' 1 'Poor'.
formats pov (f2.0).

* check listwise deletion.
descriptives pov yearcode age2 tenure4.

* select only whole cases - NB: not necessary in this case.
* select if (pov ge 0 and yearcode ge 0 and age2 ge 0 and tenure4 ge 0). 

* sort cases. 
sort cases by pov yearcode age2 tenure4

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1b.
AGGREGATE
  /OUTFILE='aggr_1b'
  /BREAK=pov yearcode age2 tenure4 
  /N_ten4=N.

* aggregate onto that file the total number in each year/age group.
DATASET ACTIVATE aggr_1b.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
* freq ten4 /histogram /formats notable /statistics all.
* freq N_ten4 /histogram /formats notable.
execute.

* patch for missing values (i.e. year/age/tenure combinations where no cases). 
* make blank dataset with case for every year/age/tenure combination.
INPUT PROGRAM.
LOOP pov=0 TO 1.
LEAVE pov.
- LOOP yearcode=1994 TO 2018.
- LEAVE yearcode.
-   LOOP tenure4=1 TO 4.
-   LEAVE tenure4.
-     LOOP age2=16 to 80.
-     END CASE.
-     END LOOP.
-   END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by pov yearcode age2 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1b
  by pov yearcode age2 tenure4.
execute.
* where no data for ten4, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten4)) ten4=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_all2=SUM(N_ten4). 
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1b.
dataset copy aggr_1b.
dataset close temp.

* smoothing process - creates average for four adjacent cells hor and vert; takes ave of cell and that average. . 
dataset activate aggr_1b.
* 1.
sort cases by pov tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by pov tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by pov tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by pov tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoothing - mean of cell plus four adjacents.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

* checking. 
sort cases by pov yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of tenures equals total - it doesn't due to smoothing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_ten4s_sum=SUM(N_ten4s).

compute check=n_ten4s_sum - N_all2.
compute checkpct=check/n_ten4s_sum.
descriptives check checkpct.

* add UK/region identifiers.
compute region=0.
STRING regname (A20).
compute regname='UK'.
execute.

*** Figure 4: Tenure by age and poverty status - adults - for checking here.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,1200px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: pov=col(source(s), name("pov"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*pov), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* save result, reordering vars. 
save outfile = 'temp1b.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = low60ahc).
dataset close aggr_1b.


*** 1c. Make dataset with means of tenure4 by age2 and year and poverty BHC with smoothing. 
dataset activate main.
weight by gs_newbu.

* set temporary poverty measure to bHC. 
compute pov=low60bhc.
var labels pov 'Poverty status'.
value labels pov 0 'Not poor' 1 'Poor'.
formats pov (f2.0).

* check listwise deletion.
descriptives pov yearcode age2 tenure4.

* select only whole cases - NB: not necessary in this case.
* select if (pov ge 0 and yearcode ge 0 and age2 ge 0 and tenure4 ge 0). 

* sort cases. 
sort cases by pov yearcode age2 tenure4

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1c.
AGGREGATE
  /OUTFILE='aggr_1c'
  /BREAK=pov yearcode age2 tenure4 
  /N_ten4=N.

* aggregate onto that file the total number in each year/age group.
DATASET ACTIVATE aggr_1c.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
* freq ten4 /histogram /formats notable /statistics all.
* freq N_ten4 /histogram /formats notable.
execute.

* patch for missing values (i.e. year/age/tenure combinations where no cases). 
* make blank dataset with case for every year/age/tenure combination.
INPUT PROGRAM.
LOOP pov=0 TO 1.
LEAVE pov.
- LOOP yearcode=1994 TO 2018.
- LEAVE yearcode.
-   LOOP tenure4=1 TO 4.
-   LEAVE tenure4.
-     LOOP age2=16 to 80.
-     END CASE.
-     END LOOP.
-   END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by pov yearcode age2 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1c
  by pov yearcode age2 tenure4.
execute.
* where no data for ten4, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten4)) ten4=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_all2=SUM(N_ten4). 
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1c.
dataset copy aggr_1c.
dataset close temp.

* smoothing process - creates average for four adjacent cells hor and vert; takes ave of cell and that average. . 
dataset activate aggr_1c.
* 1.
sort cases by pov tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by pov tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by pov tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by pov tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoothing - mean of cell plus four adjacents.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

* checking. 
sort cases by pov yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of tenures equals total - it doesn't due to smoothing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_ten4s_sum=SUM(N_ten4s).

compute check=n_ten4s_sum - N_all2.
compute checkpct=check/n_ten4s_sum.
descriptives check checkpct.

* add UK/region identifiers.
compute region=0.
STRING regname (A20).
compute regname='UK'.
execute.

* Figure 4 BHC: Tenure by age and poverty status - adults.
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
*.
temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,1600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: pov=col(source(s), name("pov"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*pov), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* save result, reordering vars. 
save outfile = 'temp1c.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = low60bhc).
dataset close aggr_1c.



*** 2a. Make dataset for tenure4 by age2 by year and region with smoothing. 
dataset activate main.
weight by gs_newbu.

* check listwise deletion.
descriptives region yearcode age2 tenure4.

* sort cases. 
sort cases by region yearcode age2 tenure4.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2a.
AGGREGATE
  /OUTFILE='aggr_2a'
  /BREAK=region yearcode age2 tenure4
  /N_ten4=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_2a.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
* freq ten4 /histogram /formats notable /statistics all.
* freq N_ten4 /histogram /formats notable.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP region=1 TO 6.
LEAVE region.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure4=1 TO 4.
-    LEAVE tenure4.
-      LOOP age2=16 to 80.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by region yearcode age2 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2a
  by region yearcode age2 tenure4.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten4)) ten4=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten4)) ten4=0.
execute.

* problem that ten4 does not sum to 1 if no date for given region/year/age.
* in these cases, borrow from adjacent ages first.
* make var to indicate sum of ten4 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /ten4_sum=SUM(ten4). 
* make lag vars for ages either side.
* 1.
sort cases by region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_a=lag(ten4).
execute.
* 2.
sort cases by region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_b=lag(ten4).
execute.
if (ten4_sum lt .99) ten4=mean(ten4_a, ten4_b).
* check ten4_sum again.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /ten4_sum2=SUM(ten4). 
* freq ten4_sum ten4_sum2.
delete variables ten4_a, ten4_b, ten4_sum, ten4_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten4). 
* replace dataset with new one.
DATASET CLOSE aggr_2a.
dataset copy aggr_2a.
dataset close temp.

* smoothing. 
dataset activate aggr_2a. 
* 1.
sort cases by region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by region tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by region tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoothing - mean of cell plus four adjacents.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

*** with region, for ten4s, need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten4s=$sysmis.

*** temp checking. 
dataset activate aggr_2a.
sort cases by region yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region yearcode age2
  /N_ten4s_sum=SUM(N_ten4s).
compute check=n_ten4s_sum - N_all2.
compute checkpct=check/n_ten4s_sum.
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

* Figure: Tenure by age and region as heatmap (c.f. Figure 6).
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
*.
temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,2400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

save outfile = 'temp2a.sav' 
    /keep region regname yearcode age2 tenure4 N_ten4s N_all2.
dataset close aggr_2a.


*** 2b. Make dataset with means of tenure4 by age2 by year by region by poverty AHC with smoothing. 
dataset activate main.
weight by gs_newbu.

* set poverty var to AHC.
compute pov=low60ahc.

* check listwise deletion.
* descriptives pov region yearcode age2 tenure4.
execute.

* sort cases. 
sort cases by pov region yearcode age2 tenure4.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2b.
AGGREGATE
  /OUTFILE='aggr_2b'
  /BREAK=pov region yearcode age2 tenure4
  /N_ten4=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_2b.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
* freq ten4 /histogram /formats notable /statistics all.
* freq N_ten4 /histogram /formats notable.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP pov=0 TO 1.
LEAVE pov.
- LOOP region=1 TO 6.
- LEAVE region.
-   LOOP yearcode=1994 TO 2018.
-   LEAVE yearcode.
-     LOOP tenure4=1 TO 4.
-     LEAVE tenure4.
-       LOOP age2=16 to 80.
-       END CASE.
-       END LOOP.
-     END LOOP.
-   END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by pov region yearcode age2 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2b
  by pov region yearcode age2 tenure4.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten4)) ten4=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten4)) ten4=0.
execute.

* problem that ten4 does not sum to 1 if no date for given region/year/age.
* in these cases, borrow from adjacent ages first.
* make var to indicate sum of ten4 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /ten4_sum=SUM(ten4). 
* make lag vars for ages either side.
* 1.
sort cases by pov region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_a=lag(ten4).
execute.
* 2.
sort cases by pov region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_b=lag(ten4).
execute.
if (ten4_sum lt .99) ten4=mean(ten4_a, ten4_b).
execute.
* check ten4_sum again.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /ten4_sum2=SUM(ten4). 
* freq ten4_sum ten4_sum2.
delete variables ten4_a, ten4_b, ten4_sum, ten4_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten4). 
* replace dataset with new one.
DATASET CLOSE aggr_2b.
dataset copy aggr_2b.
dataset close temp.

* smoothing. 
dataset activate aggr_2b. 
* 1.
sort cases by pov region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by pov region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by pov region tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by pov region tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoothing - mean of cell plus four adjacents.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

* run smoothing a second time. 
dataset activate aggr_2b. 
* 1.
sort cases by pov region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4s).
execute.
* 2.
sort cases by pov region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4s).
execute.
* 3.
sort cases by pov region tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4s).
execute.
* 4.
sort cases by pov region tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4s).
execute.
* smoother - ave of cell plus adjacents.
compute ten4s2=mean(ten4s, ten4_1, ten4_2, ten4_3, ten4_4). 
compute ten4s=ten4s2.
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4 ten4s2.
execute.

*** with region, for ten4s, need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten4s=$sysmis.

*** checking sum of tenure shares is 1 in all cases - unsmoothed and smoothed. 
dataset activate aggr_2b.
sort cases by pov region yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /N_ten4s_sum=SUM(N_ten4s).
compute check=n_ten4s_sum - N_all2.
compute checkpct=check/n_ten4s_sum.
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


* Figure: Tenure by age and region as heatmap - not poor.
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
*.
temp. 
select if (pov=0).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,2400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* Figure: Tenure by age and region as heatmap - poor.
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
*.
temp. 
select if (pov=1).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,2400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

save outfile = 'temp2b.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = low60ahc).
dataset close aggr_2b.


*** 2c. Make dataset with means of tenure4 by age2 by year by region by poverty BHC with smoothing. 
dataset activate main.
weight by gs_newbu.

* set poverty var to BHC.
compute pov=low60ahc.

* check listwise deletion.
descriptives pov region yearcode age2 tenure4.

* sort cases. 
sort cases by pov region yearcode age2 tenure4.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2c.
AGGREGATE
  /OUTFILE='aggr_2c'
  /BREAK=pov region yearcode age2 tenure4
  /N_ten4=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_2c.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
* freq ten4 /histogram /formats notable /statistics all.
* freq N_ten4 /histogram /formats notable.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP pov=0 TO 1.
LEAVE pov.
- LOOP region=1 TO 6.
- LEAVE region.
-   LOOP yearcode=1994 TO 2018.
-   LEAVE yearcode.
-     LOOP tenure4=1 TO 4.
-     LEAVE tenure4.
-       LOOP age2=16 to 80.
-       END CASE.
-       END LOOP.
-     END LOOP.
-   END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by pov region yearcode age2 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2c
  by pov region yearcode age2 tenure4.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten4)) ten4=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten4)) ten4=0.
execute.

* problem that ten4 does not sum to 1 if no date for given region/year/age.
* in these cases, borrow from adjacent ages first.
* make var to indicate sum of ten4 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /ten4_sum=SUM(ten4). 
* make lag vars for ages either side.
* 1.
sort cases by pov region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_a=lag(ten4).
execute.
* 2.
sort cases by pov region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_b=lag(ten4).
execute.
if (ten4_sum lt .99) ten4=mean(ten4_a, ten4_b).
* check ten4_sum again.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /ten4_sum2=SUM(ten4). 
* freq ten4_sum ten4_sum2.
delete variables ten4_a, ten4_b, ten4_sum, ten4_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode age2
  /N_all2=SUM(N_ten4). 
* replace dataset with new one.
DATASET CLOSE aggr_2c.
dataset copy aggr_2c.
dataset close temp.

* smoothing. 
dataset activate aggr_2c. 
* 1.
sort cases by pov region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by pov region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by pov region tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by pov region tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoother.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

* run smoothing a second time. 
dataset activate aggr_2c. 
* 1.
sort cases by pov region tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4s).
execute.
* 2.
sort cases by pov region tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4s).
execute.
* 3.
sort cases by pov region tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4s).
execute.
* 4.
sort cases by pov region tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4s).
execute.
* smoother.
compute ten4s2=mean(ten4s, ten4_1, ten4_2, ten4_3, ten4_4). 
compute ten4s=ten4s2.
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4 ten4s2.
execute.

*** with region, for ten4s, need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten4s=$sysmis.

*** temp checking. 
dataset activate aggr_2c.
sort cases by region yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov region yearcode age2
  /N_ten4s_sum=SUM(N_ten4s).
compute check=n_ten4s_sum - N_all2.
compute checkpct=check/n_ten4s_sum.
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

* Figure: Tenure by age and region as heatmap - not poor.
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
*.
temp. 
select if (pov=0).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,2400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

* Figure: Tenure by age and region as heatmap - poor.
* set chart template.
set ctemplate="chart_style 14pt nb.sgt".
*.
temp. 
select if (pov=1).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(2000px,2400px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

save outfile = 'temp2c.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = low60bhc).
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
formats tenure4 poverty_status (f2.0).
formats N_ten4s N_all2 (f8.0).

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
if (tenure4=1) tenurename='Owner occupier'.
if (tenure4=2) tenurename='Social rent'.
if (tenure4=3) tenurename='Private rent'.
if (tenure4=4) tenurename='Care of/rent free'.
execute.

* save combined results - reordering vars.
save outfile = 'FRS HBAI - tables.sav' 
   /keep region regname yearcode age2 tenure4 tenurename poverty_status poverty N_ten4s N_all2. 

* and as csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - tables.csv'
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

* save all output up to now.
OUTPUT SAVE NAME=*
 OUTFILE='tables Fig 2 4.spv'
 LOCK=NO.


*** Figure 2: tenure by age heatmap - for output.
output close all.
get file = 'temp1a.sav' . 
dataset name temp1a.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten4s=N_ten4s/N_all2*100.
formats ten4s (pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,800px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig2.tiff'
     PERCENTSIZE=100.


*** Figure 4: Tenure by age and poverty status - adults - for output.
output close all.
get file = 'temp1b.sav' . 
dataset name temp1b.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
rename variables (low60ahc = pov).
temp. 
compute ten4s=N_ten4s/N_all2*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,1200px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: pov=col(source(s), name("pov"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age2*tenure4*pov), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig4.tiff'
     PERCENTSIZE=100.


* tidy up temporary files. 
* activate main - so all temp files can be closed. 
dataset activate main.
* close datasets.
dataset close temp1a.
dataset close temp1b.
* then erase temp files.
erase file = 'temp1a.sav'.
erase file = 'temp1b.sav'.
erase file = 'temp1c.sav'.
erase file = 'temp2a.sav'.
erase file = 'temp2b.sav'.
erase file = 'temp2c.sav'.


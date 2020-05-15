* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - tables - quin dec v3.sps.
*** from "... tables - public v1.sps" but for income quintiles/deciles. 
***   -  no v2.
***   v3 - May 2020: updated for 2018/19 data.


*** IF RUNNING THIS SYNTAX ON ITS OWN, NEED TO SET FILE HANDLE FOR 'FRS' FOLDER HERE.
file handle frs / name= "K:/Data store/FRS".
cd frs. 


***   Structure of syntax file. 
* 0. Preliminaries. 
* 1d. Tenure x age x year x income quintiles  [whole UK].
* 1e. Tenure x age x year x income deciles  [whole UK].
* 1f. Tenure x age x year x income quintiles  [regions].
*      - includes python script for multiple lattices. 
* 3. Files for Dan Cookson gif.


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


*** 1d. Make dataset with means of tenure4 by age2 and year and inc_quin with smoothing. 
dataset activate main.
weight by gs_newbu.

* set temporary poverty measure to inc_quin. 
compute pov=inc_quin.
var labels pov 'Income qunitiles'.
value labels pov 1 'Poorest' 5 'Richest'.
formats pov (f2.0).

* check listwise deletion.
descriptives pov yearcode age2 tenure4.

* select only whole cases - NB: not necessary in this case.
* select if (pov ge 0 and yearcode ge 0 and age2 ge 0 and tenure4 ge 0). 

* sort cases. 
sort cases by pov yearcode age2 tenure4

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1d.
AGGREGATE
  /OUTFILE='aggr_1d'
  /BREAK=pov yearcode age2 tenure4 
  /N_ten4=N.

* aggregate onto that file the total number in each year/age group.
DATASET ACTIVATE aggr_1d.
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
LOOP pov=1 TO 5.
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
MATCH FILES file=* /file=aggr_1d
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
DATASET CLOSE aggr_1d.
dataset copy aggr_1d.
dataset close temp.

* smoothing process - creates average for four adjacent cells hor and vert; takes ave of cell and that average. . 
dataset activate aggr_1d.
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

*** Figure x: Tenure by age and income quintile - adults - for checking here.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,2000px))
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
save outfile = 'temp1d.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = inc_quin).
dataset close aggr_1d.



*** 1e. Make dataset with means of tenure4 by age2 and year and inc_dec with smoothing. 
dataset activate main.
weight by gs_newbu.

* set temporary poverty measure to inc_dec. 
compute pov=inc_dec.
var labels pov 'Income deciles'.
value labels pov 1 'Poorest' 10 'Richest'.
formats pov (f2.0).

* check listwise deletion.
descriptives pov yearcode age2 tenure4.

* select only whole cases - NB: not necessary in this case.
* select if (pov ge 0 and yearcode ge 0 and age2 ge 0 and tenure4 ge 0). 

* sort cases. 
sort cases by pov yearcode age2 tenure4

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1e.
AGGREGATE
  /OUTFILE='aggr_1e'
  /BREAK=pov yearcode age2 tenure4 
  /N_ten4=N.

* aggregate onto that file the total number in each year/age group.
DATASET ACTIVATE aggr_1e.
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
LOOP pov=1 TO 10.
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
MATCH FILES file=* /file=aggr_1e
  by pov yearcode age2 tenure4.
execute.
* SPECIAL FIX; where no data for ten4, set to 1 IF TENURE4 = 4 AND AGE LT 19 AND HIGHER INC_DEC. 
* OTHERWISE zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten4) and tenure4 = 4 and age2 lt 19 and pov gt 6) ten4=1.
* where no data for ten4, set to zero i.e. assume minimal numbers before starting smoothing.
if (sysmis(ten4)) ten4=0.
execute.
* patch where N_all missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=pov yearcode age2
  /N_all2=SUM(N_ten4). 
* close original aggregated file and replace with new. 
DATASET CLOSE aggr_1e.
dataset copy aggr_1e.
dataset close temp.

* smoothing process - creates average for four adjacent cells hor and vert; takes ave of cell and that average. . 
dataset activate aggr_1e.
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

*** Figure x: Tenure by age and income decile - adults - for checking here.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1200px,3000px))
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
save outfile = 'temp1e.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = inc_dec).
dataset close aggr_1e.


*** 1f. Make dataset with means of tenure4 by age2 and year and region and inc_quin with smoothing. 
dataset activate main.
weight by gs_newbu.

* combine age2 into two year age bands.
compute age2 = 2* trunc(age2/2).

* combine yearcode into two year bands.
compute yearcode = 2 * trunc(yearcode/2).

* set temporary poverty measure to inc_quin. 
compute pov=inc_quin.
var labels pov 'Income qunitiles'.
value labels pov 1 'Poorest' 5 'Richest'.
formats pov (f2.0).

* sort cases. 
sort cases by region pov yearcode age2 tenure4.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_1f.
AGGREGATE
  /OUTFILE='aggr_1f'
  /BREAK=region pov yearcode age2 tenure4
  /N_ten4=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_1f.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region pov yearcode age2
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
freq ten4 /histogram /formats notable /statistics all.
freq N_ten4 /histogram /formats notable /statistics all.
execute.

* patch for missing values (i.e. region/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP region=1 TO 6.
LEAVE region.
- LOOP pov=1 TO 5.
- LEAVE pov.
-  LOOP yearcode=1994 TO 2018 by 2.
-  LEAVE yearcode.
-    LOOP tenure4=1 TO 4.
-    LEAVE tenure4.
-      LOOP age2=16 to 80 by 2.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
- END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by region pov yearcode age2 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_1f
  by region pov yearcode age2 tenure4.
execute.
* set missing values to 0 for all cases region 1 to 5.
if (region le 5 and sysmis(ten4)) ten4=0.
* for region 6/NI, set missing values 0 only for years from 2002. 
if (region=6 and yearcode ge 2002 and sysmis(ten4)) ten4=0.
execute.

* problem that ten4 does not sum to 1 if no data for given region/pov/year/age.
* here it is all 16yr olds - shw this by making sum of ten4 [some values not exactly 1 due to rounding].
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region pov yearcode age2
  /ten4_sum=SUM(ten4). 
* then list cases where sum of ten4 in given reg/pov/year/age2 lt 100%.
temp.
select if (ten4_sum lt .99). 
list variables region pov yearcode age2 tenure4 ten4 N_ten4.
*.
* if we look at figs for 18 yr olds (same reg/pov/year) almost all tenure4=4 care of so use that here. 
do if (ten4_sum lt .99). 
  if (tenure4 le 3) ten4=0. 
  if (tenure4 = 4) ten4=1. 
end if.

* but still need to fix N_all - use lag vars for TWO YEARS either side for same age.
* 1.
sort cases by region pov tenure4 age2 yearcode .
execute.
if (lag(yearcode) lt yearcode) N_ten4_a=lag(N_ten4).
if (lag(yearcode, 2) lt yearcode) N_ten4_b=lag(N_ten4, 2).
execute.
* 2.
sort cases by region pov tenure4 age2 (A) yearcode (D) .
execute.
if (lag(yearcode) gt yearcode) N_ten4_c=lag(N_ten4).
if (lag(yearcode, 2) gt yearcode) N_ten4_d=lag(N_ten4, 2).
execute.

sort cases by region pov yearcode age2 tenure4.
* checking - haven't corrected ten4_sum yet so can still use to select.
temp.
select if (ten4_sum lt .99). 
list variables region pov yearcode age2 tenure4 ten4  N_ten4 N_ten4_a N_ten4_b N_ten4_c N_ten4_d .
* most can be fixed by averaging across these four values but two have to be fixed manually.
*  - yes, this is a very poor fix!.
do if (ten4_sum lt .99). 
  if (tenure4 le 3) N_ten4=0. 
  if (tenure4 = 4) N_ten4=mean(N_ten4_a, N_ten4_b, N_ten4_c, N_ten4_d). 
  if (sysmis(N_ten4)) N_ten4=1500. 
end if.
* .
temp.
select if (ten4_sum lt .99). 
list variables region pov yearcode age2 tenure4 ten4  N_ten4 N_ten4_a N_ten4_b N_ten4_c N_ten4_d .

*.
* check ten4_sum again - now fixed.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region pov yearcode age2
  /ten4_sum2=SUM(ten4). 
freq ten4 ten4_sum ten4_sum2 /histogram /formats notable /statistics all.
delete variables N_ten4_a, N_ten4_b,  N_ten4_c, N_ten4_d, ten4_sum, ten4_sum2.

* make new var N_all2 so none missing. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region pov yearcode age2
  /N_all2=SUM(N_ten4). 
freq N_all N_all2 /formats notable /statistics all.
DATASET CLOSE aggr_1f.
dataset copy aggr_1f.
dataset close temp.

* smoothing. 
dataset activate aggr_1f. 
* 1.
sort cases by region pov tenure4 yearcode age2.
execute.
if (lag(age2) lt age2) ten4_1=lag(ten4).
execute.
* 2.
sort cases by region pov tenure4 yearcode (A) age2 (D).
execute.
if (lag(age2) gt age2) ten4_2=lag(ten4).
execute.
* 3.
sort cases by region pov tenure4 age2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_3=lag(ten4).
execute.
* 4.
sort cases by region pov tenure4  age2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_4=lag(ten4).
execute.
* smoother - cell plus four adjacents.
compute ten4s=mean(ten4, ten4_1, ten4_2, ten4_3, ten4_4). 
execute.
delete variables ten4_1 ten4_2 ten4_3 ten4_4.
execute.

*** with region, for ten4s, now need to set all NI cases from 2001 or earlier to sysmis. 
if (region=6 and yearcode le 2001) ten4s=$sysmis.
execute.

*** temp checking. 
dataset activate aggr_1f.
sort cases by region pov yearcode age2 tenure4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region pov yearcode age2
  /ten4_sum=SUM(ten4) 
  /ten4s_sum=SUM(ten4s).
descriptives ten4_sum ten4s_sum.

* make smoothed count for all cases, inc. those where no data in original. 
compute N_ten4s = N_all2 * ten4s.
execute.

* check to see if sum of tenures equals total which it should do now. 
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=region pov yearcode age2
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


*** Figure x: Tenure by age and income quintile - adults - London only - for checking here.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
select if (region=1). 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,2000px))
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

*** Figure x: Lexis surface for tenure by region - poorest income quintile - - for checking here.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
select if (region=1). 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,2000px))
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


* python script: Lexis surfaces lattice (tenure x pov) BY region.
begin program.
import spss
regname = ("London", "South", "Midlands", "North/Wales", "Scotland", "Northern Ireland")
for i in range(6):
  titlename = regname[(i)]
  spss.Submit(r"""
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
select if (region=(%s+1)).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,1000px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pov=col(source(s), name("pov"), unit.category())
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  GUIDE: text.title(label("%s"))
  ELEMENT: polygon(position(yearcode*age2*tenure4*pov), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.
   """ %(i, titlename))
end program.

* python script: Lexis surfaces lattice (tenure x region) BY pov.
begin program.
import spss
quinname = ("Poorest", "Quintile 2", "Quintile 3", "Quintile 4", "Richest")
for i in range(5):
  titlename = quinname[(i)]
  spss.Submit(r"""
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
select if (pov=(%s+1)).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,1000px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  GUIDE: text.title(label("%s"))
  ELEMENT: polygon(position(yearcode*age2*tenure4*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.
   """ %(i, titlename))
end program.

* python script: Lexis surfaces lattice (pov x region) BY tenure.
begin program.
import spss
tenurename = ("Owner occupied", "Social rented", "Private rented", "Care of/rent free")
for i in range(4):
  titlename = tenurename[(i)]
  spss.Submit(r"""
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
select if (tenure4=(%s+1)).
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=region pov yearcode age2 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,1000px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: region=col(source(s), name("region"), unit.category())
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age2=col(source(s), name("age2"), unit.category())
  DATA: pov=col(source(s), name("pov"), unit.category())
  DATA: ten4s=col(source(s), name("ten4s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  GUIDE: text.title(label("%s"))
  ELEMENT: polygon(position(yearcode*age2*pov*region), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.
   """ %(i, titlename))
end program.


* save result, reordering vars. 
save outfile = 'temp1f.sav' 
    /keep pov region regname yearcode age2 tenure4 N_ten4s N_all2
    /rename (pov = inc_quin).
dataset close aggr_1f.




*** 3. files for Dan Cookson/GIF. 
* 3d. inc_quin.
get file = 'temp1d.sav' . 
dataset name final4.

* names.
RENAME VARIABLES (inc_quin = poverty_status).

* add string var for poverty.
string poverty (A20).
if (poverty_status=1) poverty = 'Poorest fifth'. 
if (poverty_status=5) poverty = 'Richest fifth'.

* add string var for tenure.
string tenurename (A20).
if (tenure4=1) tenurename='Owner occupier'.
if (tenure4=2) tenurename='Social rent'.
if (tenure4=3) tenurename='Private rent'.
if (tenure4=4) tenurename='Care of/rent free'.
execute.

* and as csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - tables quintiles.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep region regname yearcode age2 tenure4 tenurename poverty_status poverty N_ten4s N_all2
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.


* 3e. inc_dec.
get file = 'temp1e.sav' . 
dataset name final5.

* names.
RENAME VARIABLES (inc_dec = poverty_status).

* add string var for poverty.
string poverty (A20).
if (poverty_status=1) poverty = 'Poorest tenth'. 
if (poverty_status=10) poverty = 'Richest tenth'.

* add string var for tenure.
string tenurename (A20).
if (tenure4=1) tenurename='Owner occupier'.
if (tenure4=2) tenurename='Social rent'.
if (tenure4=3) tenurename='Private rent'.
if (tenure4=4) tenurename='Care of/rent free'.
execute.

* and as csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - tables deciles.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep region regname yearcode age2 tenure4 tenurename poverty_status poverty N_ten4s N_all2
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.


* 3f. inc_quin by regions.
get file = 'temp1f.sav' . 
dataset name final4.

* names.
RENAME VARIABLES (inc_quin = poverty_status).

* add string var for poverty.
string poverty (A20).
if (poverty_status=1) poverty = 'Poorest fifth'. 
if (poverty_status=5) poverty = 'Richest fifth'.

* add string var for tenure.
string tenurename (A20).
if (tenure4=1) tenurename='Owner occupier'.
if (tenure4=2) tenurename='Social rent'.
if (tenure4=3) tenurename='Private rent'.
if (tenure4=4) tenurename='Care of/rent free'.
execute.

* and as csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - tables quintiles.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep region regname yearcode age2 tenure4 tenurename poverty_status poverty N_ten4s N_all2
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

* close datasets.
dataset close final4.
dataset close final5.

* save all output up to now.
OUTPUT SAVE NAME=*
 OUTFILE='tables DanC.spv'
 LOCK=NO.



*** Figure quin: tenure by age heatmap - for output.
output close all.
get file = 'temp1d.sav' . 
dataset name temp1d.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
rename variables (inc_quin = pov).
temp. 
compute ten4s=N_ten4s/N_all2*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1200px,2000px))
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
  /TIF  IMAGEROOT='Fig Quin.tiff'
     PERCENTSIZE=100.


*** Figure quintile by quintile: tenure by age heatmap - for output.
get file = 'temp1d.sav' . 
dataset name temp1d.
set ctemplate="richpoorTitle.sgt".
rename variables (inc_quin = pov).

* cycle through quintiles producing chart for each. 
begin program python.
import spss
for i in range(5): 
    counter = i + 1
    file = str('FigQuin' + str(counter) + '.tiff')
    title = (str("Quintile:     ") + str('. ' * (counter - 1)) + str(str(counter) + ' ') + str('. ' * (5 - counter)))
    spss.Submit(r"""
    output close all.
    temp. 
    select if (pov = %s).
    compute ten4s=N_ten4s/N_all2*100.
    formats ten4s(pct3.0).
    GGRAPH
      /GRAPHDATASET NAME="graphdataset" VARIABLES= yearcode age2 tenure4 ten4s
      /GRAPHSPEC SOURCE=INLINE.
    BEGIN GPL
      PAGE: begin(scale(120px,60px))
      SOURCE: s=userSource(id("graphdataset"))
      DATA: yearcode=col(source(s), name("yearcode"), unit.category())
      DATA: age2=col(source(s), name("age2"), unit.category())
      DATA: tenure4=col(source(s), name("tenure4"), unit.category())
      DATA: ten4s=col(source(s), name("ten4s"))
      GUIDE: axis(dim(1), label(""))
      GUIDE: axis(dim(2), label(""))
      GUIDE: text.title(label("%s"))
      ELEMENT: polygon(position(yearcode*age2*tenure4), color.interior(summary.sum(ten4s)), color.exterior(color.grey),
         transparency.exterior(transparency."0.7"))
      PAGE: end()
    END GPL.
    EXECUTE.
    OUTPUT EXPORT
      /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
      /TIF  IMAGEROOT='%s'
         PERCENTSIZE=100.
    """%(counter, title, file))
end program.


*** Figure dec: Tenure by age and poverty status - adults - for output.
output close all.
get file = 'temp1e.sav' . 
dataset name temp1e.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
rename variables (inc_dec = pov).
temp. 
compute ten4s=N_ten4s/N_all2*100.
formats ten4s(pct3.0).
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pov yearcode age2 tenure4 ten4s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1200px,3000px))
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
  /TIF  IMAGEROOT='Fig Dec.tiff'
     PERCENTSIZE=100.


* tidy up temporary files. 
* activate main - so all temp files can be closed. 
dataset activate main.
* then erase temp files.
erase file = 'temp1d.sav'.
erase file = 'temp1e.sav'.
erase file = 'temp1f.sav'.



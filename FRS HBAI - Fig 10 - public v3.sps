* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 10 - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure 10 for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** SET FILE HANDLE HERE ONLY IF NEED TO RUN THIS FILE ON ITS OWN - otherwise comment out.
* file handle frs / name="K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.

*** create povahc.  
recode low60ahc (0=1) (1=2) into povahc.
value labels povahc 1 'Not poor' 2 'Poor'.

*** SET OUTCOME VAR AS 0/1.
compute outcome=yearlive. 
recode outcome (1=1) (2 thru hi=0).
var labels outcome 'Length of residence'.
value labels outcome 1 '< 1 yr' 0 'Not'.
execute.


*** 0. Preliminaries. 
dataset activate main. 

* levels.
variable level tenure2 tenure3 tenure4 (nominal).

* complete cases only - here, this has no effect at present. 
* descriptives tenure2 yearcode age80.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age80)).
execute.


*** 1. Make dataset with means of tenure4 by age80 and year and povahc with smoothing. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by povahc yearcode age80 tenure4.

* aggregate to give number in each year/age/tenure group.
DATASET DECLARE aggr_2.
AGGREGATE
  /OUTFILE='aggr_2'
  /BREAK=povahc yearcode age80 tenure4
  /N_outcome=sum(outcome)
  /N_all=N.
dataset activate aggr_2.

* make % with outcome=1. 
compute out1=N_outcome/N_all.
* freq out1 /histogram /formats notable /statistics all.
* freq N_out1 /histogram /formats notable.
execute.

* patch for missing values (i.e. povahc/year/age/tenure combinations where no cases). 
INPUT PROGRAM.
LOOP povahc=1 TO 2.
LEAVE povahc.
-  LOOP yearcode=1994 TO 2018.
-  LEAVE yearcode.
-    LOOP tenure4=1 TO 4.
-    LEAVE tenure4.
-      LOOP age80=16 to 80.
-      END CASE.
-      END LOOP.
-    END LOOP.
-  END LOOP.
END LOOP.
END FILE.
END INPUT PROGRAM.
execute.
sort cases by povahc yearcode age80 tenure4.
dataset name temp.
* match prev data on to this one. 
MATCH FILES file=* /file=aggr_2
  by povahc yearcode age80 tenure4.
execute.
* where missing, set to zero.
if (sysmis(out1)) out1=.00.
execute.
DATASET CLOSE aggr_2.
dataset copy aggr_2.
dataset activate aggr_2.
dataset close temp.

* smoothing. 
dataset activate aggr_2. 
* 1.
sort cases by povahc tenure4 yearcode age80.
execute.
if (lag(age80) lt age80) out1_1=lag(out1).
execute.
* 2.
sort cases by povahc tenure4 yearcode (A) age80 (D).
execute.
if (lag(age80) gt age80) out1_2=lag(out1).
execute.
* 3.
sort cases by povahc tenure4 age80 yearcode.
execute.
if (lag(yearcode) lt yearcode) out1_3=lag(out1).
execute.
* 4.
sort cases by povahc tenure4  age80 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) out1_4=lag(out1).
execute.
* smoother.
compute out1s=mean(out1, out1_1, out1_2, out1_3, out1_4). 
execute.
delete variables out1_1 out1_2 out1_3 out1_4.
execute.


*** Figure 10. Heatmaps - age80 by year by tenure4 by povahc.
dataset activate aggr_2.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp.
compute out1s=out1s*100.
formats out1s(pct3.0). 
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=povahc yearcode age80 tenure4 out1s
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1500px,1200px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"), unit.category())
  DATA: age80=col(source(s), name("age80"), unit.category())
  DATA: povahc=col(source(s), name("povahc"), unit.category())
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: out1s=col(source(s), name("out1s"))
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  ELEMENT: polygon(position(yearcode*age80*tenure4*povahc), color.interior(summary.sum(out1s)), color.exterior(color.grey),
     transparency.exterior(transparency."0.7"))
  PAGE: end()
END GPL.
EXECUTE.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig10.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 10.spv'
 LOCK=NO.
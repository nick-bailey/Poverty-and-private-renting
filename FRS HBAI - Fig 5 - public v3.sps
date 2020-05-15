* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 5 - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure 5 for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** SET FILE HANDLE HERE ONLY IF NEED TO RUN THIS FILE ON ITS OWN - otherwise comment out.
* file handle frs / name="K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.


*** SET OUTCOME VAR AS 0/1.
compute outcome=low60ahc. 
var labels outcome 'Poverty AHC'.
value labels outcome 1 'Yes' 0 'No'.


*** REDUCE TO VAR=1 + ADULTS CASES ONLY.
select if (outcome=1 AND ad=1).
execute.


*** 0. Preliminaries. 

* levels/labels.
variable level tenure2 tenure3 (nominal).
value labels scot 1 'Rest of UK' 2 'Scotland'.


* complete cases only - here, this has no effect at present. 
* descriptives tenure2 yearcode age80.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age80)).
execute.

* 'Freq' - basic frequencies. 
weight off.
* freq yearcode.
weight by gs_newbu.     /* weight for all hhld-level analyses.
* freq tenure2 tenure3 yearcode age80.  


*** 1. Make dataset with means of outcome by year - for line chart - u40 only. 
dataset activate main.
weight by gs_newbu.

* cut to u40 years.
select if (age80 lt 40).
execute.

* sort cases. 
sort cases by yearcode tenure4.

* aggregate to give number in each year/tenure group.
DATASET DECLARE aggr_7.
AGGREGATE
  /OUTFILE='aggr_7'
  /BREAK=yearcode tenure4
  /N_out1=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_7.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode 
  /N_all=SUM(N_out1).

* make % in each tenure. 
compute out1=N_out1/N_all.
execute.

* smoothing. 
dataset activate aggr_7. 
* 1.
sort cases by tenure4 yearcode.
execute.
if (lag(yearcode) lt yearcode) out1_1=lag(out1).
execute.
* 2.
sort cases by tenure4 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) out1_2=lag(out1).
execute.
* smoother.
compute out1_12=mean(out1_1, out1_2).
compute out1s=mean(out1, out1_12). 
execute.
delete variables out1_12 out1_1 out1_2 .
execute.


*** 2. Figure 5: 4 tenures by year - u40 only. 
dataset activate aggr_7.
* set chart template.
set ctemplate="chart_style 14pt line nb.sgt".
* temp. 
compute out1s=out1s*100.
formats out1s(pct3.0).
GGRAPH
/GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode out1s tenure4
/GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,700px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"))
  DATA: out1s=col(source(s), name("out1s"))
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Share of poor"))
  GUIDE: form.line(position(*, 10), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 20), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 30), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 40), color(color.darkgrey), shape(shape.dash))
  SCALE: linear(dim(1), min(1992), max(2018))
  SCALE: linear(dim(2), min(0), max(40))
  ELEMENT: line(position(yearcode * out1s), color(tenure4), size(size."3px"))
  PAGE: end()
END GPL.


OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig5.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 5.spv'
 LOCK=NO.

*** write csv file for fig. 

* add string var for tenure.
string tenurename (A20).
if (tenure4=1) tenurename='Owner occupier'.
if (tenure4=2) tenurename='Social rent'.
if (tenure4=3) tenurename='Private rent'.
if (tenure4=4) tenurename='Care of/rent free'.
execute.

* csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - fig 5.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep yearcode tenure4 tenurename out1s 
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.


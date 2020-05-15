* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 1a - public v1.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.

***   Syntax creates Figure 1a for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** SET FILE HANDLE HERE ONLY IF NEED TO RUN THIS FILE ON ITS OWN - otherwise comment out.
* file handle frs / name="K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.



*** 0. Preliminaries. 
dataset activate main. 

* levels.
variable level tenure2 tenure3 tenure4 (nominal).
formats yearcode (f4.0).

* complete cases only - here, this has no effect at present. 
* descriptives tenure2 yearcode age80.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age80)).


*** 1. Make dataset with means of tenure3 by year - for line chart. 
dataset activate main.
weight by gs_newbu.   

* sort cases. 
sort cases by yearcode tenure4.

* aggregate to give number in each year/tenure group.
DATASET DECLARE aggr_3.
AGGREGATE
  /OUTFILE='aggr_3'
  /BREAK=yearcode tenure4
  /N_ten4=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_3.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode 
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
execute.

* smoothing. 
dataset activate aggr_3. 
* 1.
sort cases by tenure4 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_1=lag(ten4).
execute.
* 2.
sort cases by tenure4 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_2=lag(ten4).
execute.
* smoother.
compute ten4_12=mean(ten4_1, ten4_2).
compute ten4s=mean(ten4, ten4_12). 
execute.
delete variables ten4_12 ten4_1 ten4_2 .
execute.


*** Figure 1a: Line graph - 4 tenures by year - adults.
dataset activate aggr_3.
* set chart template for PLOS One.
set ctemplate="chart_style 14pt line nb.sgt".
* temp. 
compute ten4s=ten4s*100.
formats ten4s (pct3.0).
GGRAPH
/GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode ten4s tenure4
/GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,700px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"))
  DATA: ten4s=col(source(s), name("ten4s"))
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Percent"))
  GUIDE: form.line(position(*, 20), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 40), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 60), color(color.darkgrey), shape(shape.dash))
  SCALE: linear(dim(1), min(1992), max(2017))
  SCALE: linear(dim(2), min(0), max(65))
  ELEMENT: line(position(yearcode * ten4s), color(tenure4), size(size."3px"))
  PAGE: end()
END GPL.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig1a.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 1a.spv'
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
SAVE TRANSLATE OUTFILE='FRS HBAI - fig 1a.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep yearcode tenure4 tenurename ten4s 
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.

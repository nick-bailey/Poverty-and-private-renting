* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 1b - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure 1b for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** SET FILE HANDLE HERE ONLY IF NEED TO RUN THIS FILE ON ITS OWN - otherwise comment out.
* file handle frs / name="K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.
dataset activate main.


*** select children only. 
select if (ch=1).
weight off.
freq tenure2.
execute.


*** 0. Preliminaries. 

* country.
* freq gvtregn gvtregn2 scot.

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


* 'Freq' - basic frequencies. 
weight off.
* FREQ YEARCODE.
weight by gs_newbu.     /* weight for all hhld-level analyses.
* freq tenure2 tenure2 yearcode age2.  
execute.



*** 1. Make dataset with means of tenure2 by year - for line chart. 
dataset activate main.
weight by gs_newbu.   


* sort cases. 
sort cases by yearcode tenure2.

* aggregate to give number in each year/tenure group.
DATASET DECLARE aggr_3.
AGGREGATE
  /OUTFILE='aggr_3'
  /BREAK=yearcode tenure2
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
sort cases by tenure2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_1=lag(ten4).
execute.
* 2.
sort cases by tenure2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_2=lag(ten4).
execute.
* smoother.
compute ten4_12=mean(ten4_1, ten4_2).
compute ten4s=mean(ten4, ten4_12). 
execute.
delete variables ten4_12 ten4_1 ten4_2 .
execute.


*** Figure 1b: Line graph - 4 tenures by year - children. 
dataset activate aggr_3.
* set chart template.
set ctemplate="chart_style 14pt line nb.sgt".
*.
* temp. 
compute ten4s=ten4s*100.
formats ten4s (pct3.0).
GGRAPH
/GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode ten4s tenure2
/GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,700px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"))
  DATA: ten4s=col(source(s), name("ten4s"))
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Percent"))
  GUIDE: form.line(position(*, 20), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 40), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 60), color(color.darkgrey), shape(shape.dash))
  SCALE: linear(dim(1), min(1992), max(2018))
  SCALE: linear(dim(2), min(0), max(65))
  ELEMENT: line(position(yearcode * ten4s), color(tenure2), size(size."3px"))
  PAGE: end()
END GPL.

OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig1b.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 1b.spv'
 LOCK=NO.


*** write csv file for fig. 
* add string var for tenure.
string tenurename (A20).
if (tenure2=1) tenurename='Owner occupier'.
if (tenure2=2) tenurename='Social rent'.
if (tenure2=3) tenurename='Private rent'.
if (tenure2=4) tenurename='Rent free'.
execute.

* csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - fig 1b.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep yearcode tenure2 tenurename ten4s 
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.


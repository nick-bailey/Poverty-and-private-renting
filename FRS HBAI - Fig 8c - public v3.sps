* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 8c - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure 8c for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** SET FILE HANDLE HERE ONLY IF NEED TO RUN THIS FILE ON ITS OWN - otherwise comment out.
* file handle frs / name="K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.

*** select children only. 
select if (ch=1).
weight off.

*** SET OUTCOME VAR AS 0/1.
compute outcome=lowincmdchsev. 
var labels outcome 'Severe child poverty'.
value labels outcome 1 'Yes' 0 'No'.

*** REDUCE TO VAR=1 + CHILD CASES ONLY.
select if (outcome=1 AND ch=1).
execute.


*** 0. Preliminaries. 

* levels/labels.
variable level tenure2 (nominal).
value labels scot 1 'Rest of UK' 2 'Scotland'.

* age - 1yr bands.
compute age2=age.
var labels age2 'Age'.
recode age2 (19=18) (else=copy).
value labels age2 18 '18/19'.
formats age2 (f2.0).

* complete cases only - here, this has no effect at present. 
* descriptives tenure2 yearcode age2.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age2)).
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
  /N_out1=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_3.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=yearcode 
  /N_all=SUM(N_out1).

* make % in each tenure. 
compute out1=N_out1/N_all.
execute.

* smoothing. 
dataset activate aggr_3. 
* 1.
sort cases by tenure2 yearcode.
execute.
if (lag(yearcode) lt yearcode) out1_1=lag(out1).
execute.
* 2.
sort cases by tenure2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) out1_2=lag(out1).
execute.
* smoother.
compute out1_12=mean(out1_1, out1_2).
compute out1s=mean(out1, out1_12). 
execute.
delete variables out1_12 out1_1 out1_2 .
execute.


*** Figure 8c. Line graph - 4 tenures by year - UK - sev pov. 
* 2004 on for comparison with MD and sev pov.
dataset activate aggr_3.
* set chart template.
set ctemplate="chart_style 14pt line nb.sgt".
* temp.
select if (yearcode ge 2004).
compute out1s=out1s*100.
formats out1s(pct3.0). 
GGRAPH
/GRAPHDATASET NAME="graphdataset" VARIABLES=yearcode out1s tenure2
/GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(800px,700px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"))
  DATA: out1s=col(source(s), name("out1s"))
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label("Share of severe child poverty"))
  GUIDE: form.line(position(*, 10), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 20), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 30), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 40), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 50), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 60), color(color.darkgrey), shape(shape.dash))
  SCALE: linear(dim(1), min(2003), max(2018))
  SCALE: linear(dim(2), min(0), max(60))
  ELEMENT: line(position(yearcode * out1s), color.interior(tenure2), size(size."3px"))
  PAGE: end()
END GPL.


OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig8c.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 8c.spv'
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
SAVE TRANSLATE OUTFILE='FRS HBAI - fig 8c.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep yearcode tenure2 tenurename out1s 
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.



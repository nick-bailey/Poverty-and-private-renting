* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 9 - public v1.sps.
***   Dec 2018.
***   Syntax creates Figure 9 for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
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
execute.

*** 0. Preliminaries. 

* poverty.
var labels low60ahc 'Low income poverty (AHC)'
   /low60bhc 'Low income poverty (BHC)'.
value labels low60ahc low60bhc 0 'Not poor' 1 'Poor'.

* levels.
variable level tenure2 (nominal).
formats yearcode (f4.0).

* age - 1yr bands.
compute age2=age.
var labels age2 'Age'.
recode age2 (19=18) (else=copy).
value labels age2 18 '18/19'.
formats age2 (f2.0).

* complete cases only - here, this has no effect at present. 
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age2)).


*** 1. Make dataset with means of tenure2 by year by region - for line chart. 
dataset activate main.
weight by gs_newbu.

* sort cases. 
sort cases by low60ahc region yearcode tenure2.

* aggregate to give number in each year/tenure group.
DATASET DECLARE aggr_4.
AGGREGATE
  /OUTFILE='aggr_4' 
  /BREAK=low60ahc region yearcode tenure2
  /N_ten4=N.

* aggregate onto that file number in each year/age group.
DATASET ACTIVATE aggr_4.
AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=low60ahc region yearcode 
  /N_all=SUM(N_ten4).

* make % in each tenure. 
compute ten4=N_ten4/N_all.
execute.

* smoothing. 
dataset activate aggr_4. 
* 1.
sort cases by low60ahc region tenure2 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_1=lag(ten4).
execute.
* 2.
sort cases by low60ahc region tenure2 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_2=lag(ten4).
execute.
* smoother.
compute ten4_12=mean(ten4_1, ten4_2).
compute ten4s=mean(ten4, ten4_12). 
execute.
delete variables ten4_12 ten4_1 ten4_2 .
execute.


*** Figure 9: Line graph - 4 tenures by region by poverty. 
dataset activate aggr_4.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
/GRAPHDATASET NAME="graphdataset" VARIABLES=low60ahc region yearcode ten4s tenure2
/GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1200px,600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"))
  DATA: ten4s=col(source(s), name("ten4s"))
  DATA: tenure2=col(source(s), name("tenure2"), unit.category())
  DATA: low60ahc=col(source(s), name("low60ahc"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  GUIDE: form.line(position(*, 20), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 40), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 60), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 80), color(color.darkgrey), shape(shape.dash))
  SCALE: linear(dim(1), min(1994), max(2016))
  SCALE: linear(dim(2), min(0), max(80))
  ELEMENT: line(position(yearcode * ten4s * region * low60ahc), color.interior(tenure2)), size(size."3px"))
  PAGE: end()
END GPL.


OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig9.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 9.spv'
 LOCK=NO.
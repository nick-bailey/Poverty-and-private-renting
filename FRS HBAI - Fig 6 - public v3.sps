* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - Fig 6 - public v3.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.

***   Syntax creates Figure 6 for Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***   FOR INFO ON FILES STRUCTURES/LOCATIONS, SEE 'FRS HBAI - master - public v1.sps'.


*** SET FILE HANDLE HERE ONLY IF NEED TO RUN THIS FILE ON ITS OWN - otherwise comment out.
* file handle frs / name="K:/Data store/FRS".
* cd frs. 


*** open file created by 'change' file. 
get file='FRS HBAI working file.sav' .
DATASET NAME main.


*** 0. Preliminaries. 
dataset activate main. 

* poverty.
var labels low60ahc 'Low income poverty (AHC)'
   /low60bhc 'Low income poverty (BHC)'.
value labels low60ahc low60bhc 0 'Not poor' 1 'Poor'.

* levels.
variable level tenure2 tenure3 tenure4 (nominal).
formats yearcode (f4.0).


* complete cases only - here, this has no effect at present. 
* descriptives tenure2 yearcode age80.
select if (not sysmis(tenure2) and not sysmis(yearcode) and not sysmis(age80)).


*** 1. Make dataset with means of tenure4 by year by region by low60ahc - for line chart. 
dataset activate main.
weight by gs_newbu.   

* sort cases. 
sort cases by low60ahc region yearcode tenure4.

* aggregate to give number in each year/tenure group.
DATASET DECLARE aggr_4.
AGGREGATE
  /OUTFILE='aggr_4' 
  /BREAK=low60ahc region yearcode tenure4
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
sort cases by low60ahc region tenure4 yearcode.
execute.
if (lag(yearcode) lt yearcode) ten4_1=lag(ten4).
execute.
* 2.
sort cases by low60ahc region tenure4 (A) yearcode (D).
execute.
if (lag(yearcode) gt yearcode) ten4_2=lag(ten4).
execute.
* smoother.
compute ten4_12=mean(ten4_1, ten4_2).
compute ten4s=mean(ten4, ten4_12). 
execute.
delete variables ten4_12 ten4_1 ten4_2 .
execute.


*** Figure 6:. Line graph - 4 tenures by year by region by low60ahc. 
dataset activate aggr_4.
* set chart template.
set ctemplate="chart_style 11pt nb.sgt".
* temp. 
compute ten4s=ten4s*100.
formats ten4s(pct3.0).
GGRAPH
/GRAPHDATASET NAME="graphdataset" VARIABLES=low60ahc region yearcode ten4s tenure4
/GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  PAGE: begin(scale(1200px,600px))
  SOURCE: s=userSource(id("graphdataset"))
  DATA: yearcode=col(source(s), name("yearcode"))
  DATA: ten4s=col(source(s), name("ten4s"))
  DATA: tenure4=col(source(s), name("tenure4"), unit.category())
  DATA: low60ahc=col(source(s), name("low60ahc"), unit.category())
  DATA: region=col(source(s), name("region"), unit.category())
  GUIDE: axis(dim(1), label(""))
  GUIDE: axis(dim(2), label(""))
  GUIDE: form.line(position(*, 20), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 40), color(color.darkgrey), shape(shape.dash))
  GUIDE: form.line(position(*, 60), color(color.darkgrey), shape(shape.dash))
  SCALE: linear(dim(1), min(1992), max(2018))
  SCALE: linear(dim(2), min(0), max(70))
  SCALE: cat(aesthetic(aesthetic.color.interior), map(("0", color.darkblue), ("1", color.red), ("2", color.green), ("3", color.purple), ("4", color.darkgrey)))
  ELEMENT: line(position(yearcode * ten4s * region * low60ahc), color.interior(tenure4)), size(size."3px"))
  PAGE: end()
END GPL.


OUTPUT EXPORT
  /CONTENTS  EXPORT=ALL  MODELVIEWS=PRINTSETTING
  /TIF  IMAGEROOT='Fig6.tiff'
     PERCENTSIZE=100.

OUTPUT SAVE NAME=*
 OUTFILE='Figure 6.spv'
 LOCK=NO.


*** write csv file for fig. 
* add string var for tenure.
string tenurename (A20).
if (tenure4=1) tenurename='Owner occupier'.
if (tenure4=2) tenurename='Social rent'.
if (tenure4=3) tenurename='Private rent'.
if (tenure4=4) tenurename='Care of/rent free'.

* add string var for region.
string regionname (A20).
if (region=1) regionname='London'.
if (region=2) regionname='South'.
if (region=3) regionname='Midlands'.
if (region=4) regionname='North/Wales'.
if (region=5) regionname='Scotland'.
if (region=6) regionname='Northern Ireland'.

* poverty. 
rename variables (low60ahc = poverty).
string povertyname (A20).
if (poverty=0) povertyname='Not poor'.
if (poverty=1) povertyname='Poor'.
execute.

* csv - reordering vars.
SAVE TRANSLATE OUTFILE='FRS HBAI - fig 6.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /keep yearcode region regionname tenure4 tenurename poverty povertyname ten4s
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.



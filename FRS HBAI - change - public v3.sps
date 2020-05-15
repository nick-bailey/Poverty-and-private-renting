* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - change - public v3 DanC.sps.
***   v1 - Dec 2018.
***   v2 - Jul 2019: updated for 2017/18 data.
***   v3 - May 2020: updated for 2018/19 data.
***    - also updated all years to bring in vars to measure income quintile/decile.

***   GENERAL NOTES: 
***             WRITTEN BY NICK BAILEY, UNIVERSITY OF GLASGOW. COPYRIGHT CC-BY-SA. 
***             
***             THIS FILE IMPORTS THE FRS AND HBAI DATA, CREATES CONSISTENT VARIABLES FOR ANALYSIS, 
***             AND SAVES RESULT AS 'WORKING FILE'. 


*** IF RUNNING THIS SYNTAX ON ITS OWN, NEED TO SET FILE HANDLE FOR 'FRS' FOLDER HERE.
*** OTHERWISE, COMMENT OUT.
* file handle frs / name= "K:/Data store/FRS".
* cd frs. 


***  1994/95.
file handle temp / name="FRS 9495".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh 
            gs_newhh gs_newbu gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomp hbindhh yearlive monlive schmeal.
dataset name hh.
* correct yearcode.
compute yearcode=1994.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder r01 to r10 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad94.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit par1 par2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch94.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


***  1995/96.
file handle temp / name="FRS 9596".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh 
            gs_newhh gs_newbu gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomp hbindhh yearlive monlive schmeal.
dataset name hh.
* correct yearcode.
compute yearcode=1995.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder r01 to r10 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad95.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit par1 par2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch95.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 1996/7.
file handle temp / name="FRS 9697".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh yearlive monlive schmeal.
dataset name hh.
* correct yearcode.
compute yearcode=1996.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder r01 to r10 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad96.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit par1 par2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch96.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 1997/98.
file handle temp / name="FRS 9798".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hohnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder hoh r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad97.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch97.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 1998/99.
file handle temp / name="FRS 9899".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hohnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder hoh r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad98.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch98.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


* merge six years - ad.
DATASET ACTIVATE ad98.
ADD FILES /FILE=*
  /FILE='ad94'
  /FILE='ad95'
  /FILE='ad96'
  /FILE='ad97'.
EXECUTE.
SAVE OUTFILE='ad9498.sav'.

* merge six years - ch.
DATASET ACTIVATE ch98.
ADD FILES /FILE=*
  /FILE='ch94'
  /FILE='ch95'
  /FILE='ch96'
  /FILE='ch97'.
EXECUTE.
SAVE OUTFILE='ch9498.sav'.
dataset close all.


*** 1999/2000.
file handle temp / name="FRS 9900".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hohnum hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad99.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch99.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2000/01.
file handle temp / name="FRS 0001".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hohnum hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad00.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch00.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2001/02.
file handle temp / name="FRS 0102".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn  
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad01.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch01.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2002/03.
file handle temp / name="FRS 0203".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentype gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad02.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch02.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2003/04.
file handle temp / name="FRS 0304".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad03.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch03.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2004/05.
file handle temp / name="FRS 0405".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad04.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch04.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


* merge six years - ad.
DATASET ACTIVATE ad99.
ADD FILES /FILE=*
  /FILE='ad00'
  /FILE='ad01'
  /FILE='ad02'
  /FILE='ad03'
  /FILE='ad04'.
EXECUTE.
SAVE OUTFILE='ad9904.sav'.

* merge six years - ch.
DATASET ACTIVATE ch99.
ADD FILES /FILE=*
  /FILE='ch00'
  /FILE='ch01'
  /FILE='ch02'
  /FILE='ch03'
  /FILE='ch04'.
EXECUTE.
SAVE OUTFILE='ch9904.sav'.
dataset close all.


*** 2005/06.
file handle temp / name="FRS 0506".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad05.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch05.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2006/07.
file handle temp / name="FRS 0607".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad06.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch06.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2007/08.
file handle temp / name="FRS 0708".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad07.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch07.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2008/09.
file handle temp / name="FRS 0809".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad08.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch08.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2009/10.
file handle temp / name="FRS 0910".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad09.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch09.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2010/11.
file handle temp / name="FRS 1011".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad10.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch10.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


* merge six years - ad.
DATASET ACTIVATE ad05.
ADD FILES /FILE=*
  /FILE='ad06'
  /FILE='ad07'
  /FILE='ad08'
  /FILE='ad09'
  /FILE='ad10'.
EXECUTE.
SAVE OUTFILE='ad0510.sav'.

* merge six years - ch.
DATASET ACTIVATE ch05.
ADD FILES /FILE=*
  /FILE='ch06'
  /FILE='ch07'
  /FILE='ch08'
  /FILE='ch09'
  /FILE='ch10'.
EXECUTE.
SAVE OUTFILE='ch0510.sav'.
dataset close all.


*** 2011/12.
file handle temp / name="FRS 1112".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad11.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch11.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2012/13.
file handle temp / name="FRS 1213".
** make hhold (sernum) file - hh.
***  NB that ovsat + move1/2/reas qns only appears in 2012/13.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive yearwhc monlive schmeal
            ovsat movenxt movef movereas .
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad12.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch12.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.



**** 2013/14.
file handle temp / name="FRS 1314".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive yearwhc monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
***  13/14 only - three additional qns on sat with accomm, living environment and recreation/green space.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc
            accmsat envirsat recsat.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad13.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch13.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.




*** 2014/15.
file handle temp / name="FRS 1415".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive yearwhc monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad14.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch14.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2015/16.
file handle temp / name="FRS 1516".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive yearwhc monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad15.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch15.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2016/17.
file handle temp / name="FRS 1617".
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh tentyp2 gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh  mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearlive yearwhc monlive schmeal.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad16.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch16.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.


*** 2017/18.
file handle temp / name="FRS 1718".
*  from 1718 - hbai file: 
*  - tenure dropped, along with tentype and tentype2; tenhbai replaces but with just 4 cats.
*  - as a result, pick up tentyp2 from hh file.
*  - ptentyp2 added; previously ptentype but renamed; just 6 cats.
*  from 1718, adult file - yearlive dropped.
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh ptentyp2 tenhbai gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearwhc monlive schmeal
            tentyp2.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14 numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad17.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch17.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.

*** 2018/19.
file handle temp / name="FRS 1819".
*  from 1718 - hbai file: 
*  - tenure dropped, along with tentype and tentype2; tenhbai replaces but with just 4 cats.
*  - as a result, pick up tentyp2 from hh file.
*  - ptentyp2 added; previously ptentype but renamed; just 6 cats.
*  from 1718, adult file - yearlive dropped.
** make hhold (sernum) file - hh.
GET
  FILE='temp/hbai.sav'
   /keep sernum benunit 
            adulth depchldh ptentyp2 tenhbai gvtregn newgvtregn 
            low60bhc low60ahc s_oe_ahc s_oe_bhc eqoahchh eqobhchh mdscorech mdch lowincmdch lowincmdchsev mdscorepn mdpn 
            gs_newhh gs_newbu gs_newad gs_newch gs_newpn  gs_newwa  gs_newpp .
dataset name hb.
* take first case for each hhld - all vars at hhld level so no diffs between benunits.
select if (benunit=1).
* flag to identify cases from hb file.
compute hb=1.
sort cases by sernum .
GET
  FILE='temp/househol.sav'
   /keep sernum   
            yearcode benunits hhstat hhcomps hbindhh hrpnum yearwhc monlive schmeal
            tentyp2.
dataset name hh.
sort cases by sernum.
MATCH FILES file=* 
  /file=hb
  /by sernum.
execute.
** make adult file - ad.
GET
  FILE='temp/adult.sav'
   /keep sernum benunit person 
            sex age80 hholder hrpid combid r01 to r14  numjob empstatc.
dataset name ad.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ad18.
** make child file - ch.
GET
  FILE='temp/child.sav'
   /keep sernum benunit person 
            sex age smlit parent1 parent2.
dataset name ch.
sort cases by sernum benunit person.
* merge in hh+hb data.
MATCH FILES file=* 
  /table=hh
  /by sernum.
execute.
dataset copy ch18.
* close datasets. 
dataset close hh.
dataset close hb.
dataset close ad.
dataset close ch.



* merge years - ad.
DATASET ACTIVATE ad11.
ADD FILES /FILE=*
  /FILE='ad12'
  /FILE='ad13'
  /FILE='ad14'
  /FILE='ad15'
  /FILE='ad16'
  /FILE='ad17'
  /FILE='ad18'.
EXECUTE.
SAVE OUTFILE='ad1118.sav'.

* merge years - ch.
DATASET ACTIVATE ch11.
ADD FILES /FILE=*
  /FILE='ch12'
  /FILE='ch13'
  /FILE='ch14'
  /FILE='ch15'
  /FILE='ch16'
  /FILE='ch17'
  /FILE='ch18'.
EXECUTE.
SAVE OUTFILE='ch1118.sav'.
dataset close all.


*** combine the various datasets.
*  ad. 
get file = 'ad9904.sav'.
dataset name ad9904.
get file = 'ad0510.sav'.
dataset name ad0510.
get file = 'ad1118.sav'.
dataset name ad1118.
get file = 'ad9498.sav'.
dataset name ad.
ADD FILES /FILE=*
  /FILE='ad9904'
  /FILE='ad0510'
  /FILE='ad1118'.
* adult and child case flags.
compute ad=1.
compute ch=0.
EXECUTE.
dataset close ad9904.
dataset close ad0510.
dataset close ad1118.

*  ch. 
get file = 'ch9904.sav'.
dataset name ch9904.
get file = 'ch0510.sav'.
dataset name ch0510.
get file = 'ch1118.sav'.
dataset name ch1118.
get file = 'ch9498.sav'.
dataset name ch.
ADD FILES /FILE=*
  /FILE='ch9904'
  /FILE='ch0510'
  /FILE='ch1118'.
* adult and child case flags.
compute ad=0.
compute ch=1.
EXECUTE.
dataset close ch9904.
dataset close ch0510.
dataset close ch1118.

* combine ad + ch.
ADD FILES /FILE=*
  /FILE='ad'.
var labels ad 'Adult case' 
   /ch 'Child case'.
execute.
dataset close ad.





*****  tidy up combined file. 

*** select only cases with hbai data. 
select if (hb=1).

*** year.
* freq yearcode.
* crosstabs yearcode by ad.


*** age - separate adult and child age.
* for adults, merge 'age' for  earlier years into 'age80'  which is present for later years.
if (ad=1 and age gt 0) age80=age.
if (age80 gt 80) age80=80.
var labels age80 'Age'.
* for children, make new var.
if (ch=1) age_ch=age.
var labels age_ch 'Age of child'.
* freq age_ch age80.


*** fix R01 etc. in 94 and 95 as coded diff to later years. 
* and add val label for additional cat from 2010.
do if (yearcode le 1995).
  do repeat var=r01 to r10. 
    if (var gt 1) var=var+1.
  end repeat.
end if.
add value labels r01 to r14 20 'Civil partner'.


*** hhld status - conventional/shared. 
** for 94/5 to 96/7, hhstat coded -1=missing for cases where only 1 benunit in hhld 
* - recode to 1 'conventional' for consistency with later years.
recode hhstat (-1=1) (else=copy). 
** shared hhlds all have more than one benunit. 
* crosstabs benunits by hhstat /missing include.
**  60% of shared hhlds are 3+ ads, no kids and 30% 2 ads (non-pens), no kids. 
* crosstabs hhcomps by hhstat /cells column.
** but only 8% of 3+ ad hhlds are shared. 
* crosstabs hhcomps by hhstat /cells row.
** shared hhlds much more common where 3+ benunits
* i.e. where couple + 1 (2 benunits), rarely shared hhld.
* temp.
* select if (hhcomps=7 or hhcomps=8).
* crosstabs benunits by hhstat /cells row.


*** tenure/tenure2.
* combine tenure vars and recode to 4 cats based on hhld position.
compute tenure=tentype.
if (tentyp2 gt 0)  tenure=tentyp2.
* correct years 97-01 (where 8=squat - make 11).
if (yearcode ge 1997 and yearcode le 2001 and tenure=8) tenure=11.
var labels tenure 'Tenure (hhld)'.
apply dictionary from *
   / SOURCE VARIABLES = tentyp2
   /TARGET VARIABLES = tenure.
add value labels tenure 11 'Squat'.
* crosstabs yearcode by tenure .
* crosstabs yearcode by tenure /cells row.

* recode to tenure2. 
recode tenure (1,2,8,9=2) (3,4=3) (5,6,10=1) (7,11=4) 
     into tenure2.
var labels tenure2 'Tenure (hhld)'.
value labels tenure2 1 'Owner occupier' 2 'Social rented' 3 'Private rented' 4 'Rent free'.
* crosstabs yearcode by tenure2 /cells row.


*** adult relationship to HRP and Hholder. 
* make hrpnum2 from hrpnum (hohnum where hrpnum missing in yrs 97+98) .
* from hhld file so present for all.
compute hrpnum2=hrpnum. 
if (sysmis(hrpnum2)) hrpnum2=hohnum.
var labels hrpnum2 'HRP person number'.

* make hrpid2 from hrpid (hoh where hrpid missing in 97+98) [YN=12]. 
* from adult file so only present for adults.
compute hrpid2=hrpid. 
if (sysmis(hrpid2)) hrpid2=hoh.
if (yearcode ge 1997 and ch=1) hrpid2=2.
var labels hrpid2 'HRP identifier'.
value labels hrpid2 1 'Yes' 2 'No'.
* crosstabs yearcode by hrpnum2 hrpid2 .
execute.

* make hholdernum - number of first person in hhld who is hholder - present for almost all .
*   - some hhlds have no hholder 
*   - many are 'rent free' for no one responsible for mort/rent so - leaves about 0.3%.
* first need to patch hholder for children (set = 3) otherwise sort places them first in hhld.
if (ch=1) hholder=3.
add value labels hholder 3 'Child'.
* and make temp var to flag hholder(s).
recode hholder (1=1) (else=0) into temp. 
sort cases by yearcode sernum hholder person.
AGGREGATE
  /OUTFILE=* mode=ADDVARIABLES
  /BREAK=yearcode sernum 
  /hholdernum=first(person)
  /N_hholder=sum(temp).
execute.
delete variables temp.
* where no hholder, set hholdernum to missing unless tenure=7 (rent free).
if (tenure ne 7 and N_hholder=0) hholdernum=-9.
missing values hholdernum (-9).
* freq hholdernum.
execute.
* restore sort order.
sort cases by yearcode sernum benunit person.

* create variables for adult's relationship to HRP (hrpnum2/hrpid2) and to hholder (hholdernum). 
* R01 etc. only present for adults so these vars only for adults. 
vector rel = r01 to r14.
compute ad_relhrp=rel(hrpnum2).
compute ad_relhholder=rel(hholdernum).
apply dictionary from *
   / SOURCE VARIABLES = r01
   /TARGET VARIABLES = ad_relhrp ad_relhholder.

* where person is hrp (hrpid2=1), ad_relhrp missing so set to zero - only adults.
* should be present all ads but 252 missing vals in 1999 - the only year where hrpnum has '-1' missing values.
if (hrpid2=1) ad_relhrp=0.
var label ad_relhrp 'Relationship to HRP'.
add value labels ad_relhrp 0 'HRP'.

* where indiv is hholder, make ad_relhholder=0 - override previous allocation based on first hholder in hhld - only adults. 
* approx 0.7% missing - consistent across years.
if (hholder=1) ad_relhholder=0.
var label ad_relhholder 'Relationship to Hholder'.
add value labels ad_relhholder 0 'Hholder'.
* freq ad_relhrp ad_relhholder.
* crosstabs yearcode by ad_relhrp ad_relhholder.

* simplified version of ad_relhholder. 
recode ad_relhholder (0 thru 2, 20=1) (3 thru 19=0) 
   into ad_relhholder2.
value labels ad_relhholder2 1 'Hholder/partner' 0 'Not'.
* crosstabs ad_relhholder by ad_relhholder2 .

* NOTES:
* - 91% hholder or partner; 7.7% son/duaghter of hhlder etc.; 0.6% non-rel; 1% other rel. 
* - 90% HRP or partner; 7.7% son/daughter etc.; 1.4% non-rel .
* - 90% are both hholder/partner and HRP/partner.
* crosstabs ad_relhrp by ad_relhholder /cells total.

* where ad_relhrp=18 (other non-relative), v high proportion are private rented (65%) - much higher than any other cat.
* of these cases (ad_relhrp=18 and tenure=3), 73% are 3+ ad hhlds - and most of rest of 2 ads - so look much more like shared hhld.
* but much less clear with ad_relhholder.
* crosstabs ad_relhrp ad_relhholder ad_relhholder2 by tenure2 /cells row.

*** tenure3/tenure4.
* make tenure3 to inc. "care of" category where adult is not hholder/partner - and for all children.
* NB that can't just use hholder as some partners do not identify themselves as hholder [would be interesting to examine why].
compute tenure3=tenure2.
if (ad_relhholder2=0) tenure3=0.
if (ch=1) tenure3=0.
var labels tenure3 'Tenure (indiv - 5 cat)'.
value labels tenure3 0 'Care of' 1 'Owner occupier' 2 'Social rented' 3 'Private rented' 4 'Rent free'.
* make tenure4 - indiv/4 cat.
recode tenure3 (0,4=4) (else=copy) into tenure4.
var labels tenure4 'Tenure (indiv - 4 cat)'.
value labels tenure4 1 'Owner occupier' 2 'Social rented' 3 'Private rented' 4 'Care of/rent free'.
* crosstabs yearcode by tenure2 tenure3 tenure4 /cells row.


*** parten1 - correct tenure3/tenure4 for children.
* merge parent numbers - NB 97 is code for parent not in hhld; -1 is missing values.
if (sysmis(parent1)) parent1=par1.
if (sysmis(parent2)) parent2=par2.
execute.
* relies on having correct sort order from above - yearcode sernum benunit person.
dataset declare temp.
AGGREGATE
  /OUTFILE=temp
  /BREAK=yearcode sernum person
  /tempten3=first(tenure3).
execute.
* make file with one case per hhld and tenure of each person.
dataset activate temp.
SORT CASES BY yearcode sernum person.
CASESTOVARS
  /ID=yearcode sernum
  /INDEX=person
  /GROUPBY=VARIABLE.
* back to main file and attach tenure for each person.
dataset activate ch.
match files file=*
  /table=temp
  /by yearcode sernum.
execute.
* use parent1/2 to pick tenure of parent.
vector tempten = tempten3.1 to tempten3.18.
compute parten1=tempten(parent1).
compute parten2=tempten(parent2).
* parten missing for 1994 and for about 1/3 of cases 95 and 96 - patch with tenure2.
if (ch=1 and yearcode le 1996 and sysmis(parten1)) parten1=tenure2.
apply dictionary from *
   / SOURCE VARIABLES = tenure3
   /TARGET VARIABLES = parten1 parten2.
var labels parten1 'Tenure (parent)'.
* result is near complete agreement so just use parten1; about 1.3% children are 'care of'.
* freq parten1 parten2.
* crosstabs parten1 by parten2.
* crosstabs parten1 by tenure2.
execute.
delete variables tempten3.1 to tempten3.18.


*** tenure6 - owners outright/mort and PRS sole/shared.
***  NB that children all 'care of'.
recode tenure4 (2=3) (3=4) (4=6) (else=copy)
     into tenure6.
** split owners.
if (tenure4=1 and tenure=5) tenure6=2.
** 80% of shared hhlds are in PRS.
* crosstabs tenure by hhstat /cels column.
** for PRS only, split sole from shared.
if (tenure6=4 and hhstat=2) tenure6=5.
var labels tenure6 'Tenure (indiv - 6 cat)'.
value labels tenure6 1 'Own outright' 2 'Own - mortgage' 3 'Social rented' 4 'Private rent - sole' 
   5 'Private rent - shared' 6 'Care of/Rent free'.


*** country.
recode gvtregn (1 thru 11, 13=1) (12=2) 
     into scot.
value labels scot 1 'RoUK' 2 'Scot'.
* freq scot.


*** region group.
recode gvtregn (8=1) (7,9,10 =2) (5,6=3) (1,2,3,4,11=4) (12=5) (13=6)
     into region.
value labels region 1 'London' 2 'South' 3 'Midlands' 4 'North/Wales' 5 'Scotland' 6 'Northern Ireland'.
formats region (f2.0).
* crosstabs gvtregn by region.


*** yearlive - length of residence. 
* 94/95 - recorded in years so recode to cats. 
do if (yearcode le 1995).
  recode yearlive (0=1) (1=2) (2=3) (3,4=4) (5 thru 9=5) (10 thru hi=6).
end if. 
* as 96 only had 6 cats, not seven, recode all others to 6 cats.
recode yearlive (7=6) (else=copy) .
add value labels yearlive 6 '10 or more years'.
* from 2012 onwards, uses yearwhc and monlive, with yearlive as the exception. 
compute temp=yearcode - yearwhc.

recode temp (lo thru 0=1) (1=2) (2=3) (3,4=4) (5 thru 9=5) (10 thru hi=6).
if (temp=1 and monlive gt 12) temp=2.
if (missing(yearlive)) yearlive=temp.
* crosstabs yearcode by yearlive yearwhc monlive /cells row.
execute.
delete variables temp.
execute.


*** poverty.
var labels low60ahc 'Low income poverty (AHC)'
   /low60bhc 'Low income poverty (BHC)'.
value labels low60ahc low60bhc 0 'Not poor' 1 'Poor'.

*** check pov rates against DWP publications - new very close. 
* population level.
* weight by gs_newbu.
* means low60bhc low60ahc by yearcode /cells mean. 

* hhld level.
*** weight by gs_newph - NEED CORRECT HHLD WEIGHT.
* temp.
* select if (person=1).
* means low60bhc low60ahc by yearcode /cells mean. 
execute.

* income deciles and qunitiles.. 
weight by gs_newbu.
* means s_oe_ahc by yearcode.
rank variables = s_oe_ahc by yearcode
   /ntiles(10) into inc_dec. 
rank variables = s_oe_ahc by yearcode
   /ntiles(5) into inc_quin. 
* crosstabs yearcode by inc_quin
   /CELLS count.
execute.


* save file. 
save outfile='FRS HBAI working file.sav' /COMPRESSED.

* erase ad files.
erase file 'ad9498.sav'.
erase file 'ad9904.sav'.
erase file 'ad0510.sav'.
erase file 'ad1118.sav'.
* erase ch files.
erase file 'ch9498.sav'.
erase file 'ch9904.sav'.
erase file 'ch0510.sav'.
erase file 'ch1118.sav'.
execute.

* get file='FRS HBAI working file.sav' .
cd frs.
OUTPUT SAVE NAME=*
 OUTFILE='change.spv'
 LOCK=NO.


# Poverty-and-private-renting

## Aims
This project aims to analyse changes in housing tenure for low-income households in the UK, 1995-2018. In particular, the focus is on measuring the proportion of low income adults and children in private renting. It uses data from the UK Department for Work and Pensions' Family Resources Survey, along with the associated Households Below Average Incomes dataset. 

## Working paper, aggregated data and on-line visualisation tool
Results have been written up as a working paper which will be upload to github shortly (2019). 

The aggregated data which underpin the figures in the working paper can be downloaded here (two csv files for adults and children separately). 

The aggregated data have also been used to produce an [on-line data visualisation tool](https://ubdc-apps.shinyapps.io/data_explorer_adult/). This is hosted by the [Urban Big Data Centre](www.ubdc.ac.uk) on an RShiny server. The on-line tool allows users to experiment with a wide range of colour schemes which may help those with colour-vision impairment. They can explore how the choice of poverty measure influences results, or examine variations between regions in much more detail. The aggregated data can also be downloaded there. 

## SPSS syntax
The code for the analysis was written for IBM's SPSS Statistics software (v.24). The file "FRS HBAI - master - public v2.sps" (the master file) runs the entire analysis, calling the other syntax files in turn (and two further files which format charts). It produces the figures used in the paper but also the two csv files used in the Urban [on-line data visualisation tool](https://ubdc-apps.shinyapps.io/data_explorer_adult/). The master file starts with the following note: 

*    0. INTRODUCTION
*        THE SYNTAX FILE REPRODUCES ALL THE FIGURES IN THE PAPER. 
*           IT ALSO PRODUCES TWO .CSV FILES USED IN AN ON-LINE DATA VISUALISATION TOOL NOTED IN THE PAPER.
*           WHEN RUN ON MY PC, PRODUCES SOME WARNINGS BUT NO ERRORS.
*           THE CODE IS SHARED UNDER A GNU GENERAL PUBLIC LICENCE V3. 
*           YOU ARE WELCOME TO USE IT AND ADAPT THE CODE BUT SHOULD GIVE CREDIT FOR THIS WORK
*           AND SHOULD MAKE ANY RESULTING PRODUCTS AVAILABLE ON THE SAME BASIS.
*        SHARING IS DONE IN THE SPIRIT OF COLLABORATION AND TO SUPPORT TRANSPARENCY AND REPRODUCIBILITY. 
*        NO GUARANTEES ARE GIVEN THAT THIS CODE IS CORRECT AND NO SUPPORT WILL BE PROVIDED. 
*        FEEDBACK ON THE CODE IS WELCOMED. 

## Data sources
This note appears in the 'master' file and explains how to obtain the individual-level survey data. 

*    1. DATA SOURCES
*         THE SYNTAX RUNS ON A SET OF FILES DOWNLOADED FROM THE UK DATA SERVICE.
*         THE DATA ARE FROM THE FAMILY RESOURCES SURVEY (FRS) AND AN ASSOCIATED SET
*            OF DERIVED DATA, THE HOUSEHOLDS BELOW AVERAGE INCOME (HBAI) DATASET.
*            THE PAPER CONTAINS THE FULL METHODOLOGICAL DETAILS. 
*         FRS DATA FILES WERE DOWNLOADED FROM THE UK DATA SERVICE AS ZIP FILES FOR SPSS.
*             UKDS SERIES ID: 200017 [DATASET FOR EACH YEAR HAS ITS OWN DOI]
*             FRS DATA DOWNLOADED AUGUST 2018.
*             SPSS DATA FILES (.SAV) EXTRACTED AND SAVED TO A SEPARATE DIRECTORY FOR EACH YEAR.
*             NAMING DETAILS FOR FILES AND DIRECTORIES IN 2. BELOW.
*             93/94 OMITTED AS NOT INCLUDED IN HBAI DATASET.
*         HBAI DATA FOR ALL YEARS DOWNLOADED FROM THE UK DATA SERVICE AS ONE ZIP FILE FOR SPSS.
*             UKDS STUDY NUMBER: 5828-9  [doi: 10.5255/UKDA-SN-5828-9].
*             SPSS DATA FILE FOR EACH YEAR EXTRACTED AND SAVED WITH FRS DATA FOR THAT YEAR.
*             DATA FILES FOR YEARS 2002/3 ON HAVE SUFFIX '_G4.SAV' IN THE ZIP FILE BUT SUFFIX DROPPED HERE.
*         HBAI DATASET IS FOR "BENEFIT UNITS" (SEE DOCUMENTATION FOR DEFINITIONS - SIMILAR TO HOUSEHOLD) 
*             BUT THIS CODE CREATES FILE WITH ONE CASE FOR EACH ADULT/CHILD IN THE BENEFIT UNIT.
*             ANALYSIS DISTINGUISHES ADULTS WHO ARE HOUSEHOLDERS (OWNER/TENANT OR PARTNER OF SAME) 
*             FROM OTHERS LIVING 'CARE OF' e.g. WITH FAMILY OR FRIENDS, OR LIVING 'RENT FREE'.

## File structure and set-up
This note appears in the master file and explains how to set up the file structure into which the data files are unpacked. 

*    2. FILE STRUCTURE AND SET UP
*        THE SYNTAX ASSUMES FILES ARE ORGANISED WITHIN A FOLDER CALLED 'FRS' WHICH HAS 
*        A PATH NAME <pathname>, AND ARRANGED AS FOLLOWS: 
*           <pathname>\FRS                     - all syntax files, chart format files (.sgt) are placed in this folder
*           <pathname>\FRS\FRS 9495     - three FRS files extracted from UKDS zip files for 1994/95 and named: adult.sav, child.sav, househol.sav
*                                                         - one HBAI file for same year extracted from UKDS zip files and named: hbai.sav
*           <pathname>\FRS\FRS 9596     - files for 1995/96 ... and so on.
*          THE PATH TO "FRS" FOLDER NEEDS TO BE SET BY THE USER IN THE FIRST BLOCK BELOW.
  
## Execution of syntax
This note appears in the master file to explain how to execute the syntax to produce the outputs used in the paper and the two data files used in the on-line visualisation tool. 

*    3. RUNNING THE SYNTAX AND OUTPUTS
*          1. SET UP THE FILES AS DIRECTED 
*          2. SET THE FILE HANDLE IN THE FIRST BLOCK OF CODE BELOW, 
*          3. SELECT ALL LINES IN THIS SYNTAX FILE AND RUN.
*          - ALL TEMPORARY AND WORKING FILES ARE CREATED IN THE 'FRS' FOLDER
*          - OUTPUTS ARE CREATED IN 'FRS' FOLDER: CHARTS FOR THE PAPER AND .CSV FILES.



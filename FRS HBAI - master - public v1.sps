* Encoding: UTF-8.
dataset close all.
output close all.
*** FRS HBAI - master - public v1.sps.
***   Dec 2018.

***   GENERAL NOTES: 
***             WRITTEN BY NICK BAILEY, UNIVERSITY OF GLASGOW. 
***.
***             THIS SET OF SYNTAX FILES PRODUCED THE ANALYSIS FOR:
***                Bailey, Nick (2018) Poverty and the re-growth of private renting in the UK. 
***                
***             
***    0. INTRODUCTION
***        THE SYNTAX FILE REPRODUCES ALL THE FIGURES IN THE PAPER. 
***           IT ALSO PRODUCES TWO .CSV FILES USED IN AN ON-LINE DATA VISUALISATION TOOL NOTED IN THE PAPER.
***           WHEN RUN ON MY PC, PRODUCES SOME WARNINGS BUT NO ERRORS.
***           THE CODE IS SHARED ON A CC-BY-SA (ATTRIBUTION AND SHARE-ALIKE) BASIS. 
***           YOU ARE WELCOME TO USE IT AND ADAPT THE CODE BUT SHOULD GIVE CREDIT FOR THIS WORK
***           AND SHOULD MAKE ANY RESULTING PRODUCTS AVAILABLE ON THE SAME BASIS.
***        SHARING IS DONE IN THE SPIRIT OF COLLABORATION AND TO SUPPORT TRANSPARENCY AND REPRODUCIBILITY. 
***        NO GUARANTEES ARE GIVEN THAT THIS CODE IS CORRECT AND NO SUPPORT WILL BE PROVIDED. 
***        FEEDBACK ON THE CODE IS WELCOMED. 
***    1. DATA SOURCES
***         THE SYNTAX RUNS ON A SET OF FILES DOWNLOADED FROM THE UK DATA SERVICE.
***         THE DATA ARE FROM THE FAMILY RESOURCES SURVEY (FRS) AND AN ASSOCIATED SET
***            OF DERIVED DATA, THE HOUSEHOLDS BELOW AVERAGE INCOME (HBAI) DATASET.
***            THE PAPER CONTAINS THE FULL METHODOLOGICAL DETAILS. 
***         FRS DATA FILES WERE DOWNLOADED FROM THE UK DATA SERVICE AS ZIP FILES FOR SPSS.
***             UKDS SERIES ID: 200017 [DATASET FOR EACH YEAR HAS ITS OWN DOI]
***             FRS DATA DOWNLOADED AUGUST 2018.
***             SPSS DATA FILES (.SAV) EXTRACTED AND SAVED TO A SEPARATE DIRECTORY FOR EACH YEAR.
***             NAMING DETAILS FOR FILES AND DIRECTORIES IN 2. BELOW.
***             93/94 OMITTED AS NOT INCLUDED IN HBAI DATASET.
***         HBAI DATA FOR ALL YEARS DOWNLOADED FROM THE UK DATA SERVICE AS ONE ZIP FILE FOR SPSS.
***             UKDS STUDY NUMBER: 5828-9  [doi: 10.5255/UKDA-SN-5828-9].
***             SPSS DATA FILE FOR EACH YEAR EXTRACTED AND SAVED WITH FRS DATA FOR THAT YEAR.
***             DATA FILES FOR YEARS 2002/3 ON HAVE SUFFIX '_G4.SAV' IN THE ZIP FILE BUT SUFFIX DROPPED HERE.
***         HBAI DATASET IS FOR "BENEFIT UNITS" (SEE DOCUMENTATION FOR DEFINITIONS - SIMILAR TO HOUSEHOLD) 
***             BUT THIS CODE CREATES FILE WITH ONE CASE FOR EACH ADULT/CHILD IN THE BENEFIT UNIT.
***             ANALYSIS DISTINGUISHES ADULTS WHO ARE HOUSEHOLDERS (OWNER/TENANT OR PARTNER OF SAME) 
***             FROM OTHERS LIVING 'CARE OF' e.g. WITH FAMILY OR FRIENDS, OR LIVING 'RENT FREE'.
***    2. FILE STRUCTURE AND SET UP
***        THE SYNTAX ASSUMES FILES ARE ORGANISED WITHIN A FOLDER CALLED 'FRS' WHICH HAS 
***        A PATH NAME <pathname>, AND ARRANGED AS FOLLOWS: 
***           <pathname>\FRS                     - all syntax files, chart format files (.sgt) are placed in this folder
***           <pathname>\FRS\FRS 9495     - three FRS files extracted from UKDS zip files for 1994/95 and named: adult.sav, child.sav, househol.sav
***                                                         - one HBAI file for same year extracted from UKDS zip files and named: hbai.sav
***           <pathname>\FRS\FRS 9596     - files for 1995/96 ... and so on.
***          THE PATH TO "FRS" FOLDER NEEDS TO BE SET BY THE USER IN THE FIRST BLOCK BELOW.
***    3. RUNNING THE SYNTAX AND OUTPUTS
***          1. SET UP THE FILES AS DIRECTED 
***          2. SET THE FILE HANDLE IN THE FIRST BLOCK OF CODE BELOW, 
***          3. SELECT ALL LINES IN THIS SYNTAX FILE AND RUN.
***          - ALL TEMPORARY AND WORKING FILES ARE CREATED IN THE 'FRS' FOLDER
***          - OUTPUTS ARE CREATED IN 'FRS' FOLDER: CHARTS FOR THE PAPER AND .CSV FILES.


***   THIS FILE:
***       1. RUNS 'CHANGE' SYNTAX TO PRODUCE WORKING DATA FILE;
***       2. RUNS SYNTAX FILES WHICH USE WORKING DATA FILE TO PRODUCE AGGREGATED DATA FILES, 
***           AS WELL AS LEXIS SURFACES AND OTHER CHARTS ASSOCIATED WITH PAPER.



*** SET FILE HANDLE FOR 'FRS' DIRECTORY.
file handle frs / name="K:/Data store/FRS".
cd frs. 


* change file
*    combines required data from all the UKDS files into single working file. 
insert file = "FRS HBAI - change - public v1.sps".

* tables file.
*   produces .csv file with data for the Poverty and Housing Tenure data explorer - on-line app.
*   produces heatmaps: Figures 2 and 4. 
insert file = "FRS HBAI - tables - public v1.sps".

* Figure 1a - Line chart - tenure by year - adults and children separately.
insert file = "FRS HBAI - Fig 1a - public v1.sps".

* Figures 5, 6 and 10 - heatmaps for adults.
insert file = "FRS HBAI - Fig 5 - public v1.sps".
insert file = "FRS HBAI - Fig 6 - public v1.sps".
insert file = "FRS HBAI - Fig 10 - public v1.sps".

* tables file - children.
*   produces .csv file with data for the Poverty and Housing Tenure data explorer - on-line app - children.
*   produces heatmaps: Figures 3 and 7. 
insert file = "FRS HBAI - tables ch - public v1.sps".

* Figure 1b - Line chart - tenure by year - adults and children separately.
insert file = "FRS HBAI - Fig 1b - public v1.sps".

* Figures 8a/b/c and 9 - line charts for children.
insert file = "FRS HBAI - Fig 8a - public v1.sps".
insert file = "FRS HBAI - Fig 8b - public v1.sps".
insert file = "FRS HBAI - Fig 8c - public v1.sps".
insert file = "FRS HBAI - Fig 9 - public v1.sps".



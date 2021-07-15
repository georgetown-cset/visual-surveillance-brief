
# Project links 
Project folder, including all Google Sheets: https://drive.google.com/drive/u/2/folders/1cj2AsiNaM-y8MgZDNzNnHJcg1pZOW89s

Project BigQuery database: gcp_cset_projects.surveillance_tasks_brief

Draft: [Surveillance tasks draft](https://docs.google.com/document/d/1kK6TodaNhbwCoTOfSreL_jV1l29q8DDZdKlc-e-5Ruo/edit)

Table 1 comes from the sheet [Top CV tasks - 2019 count and growth rate](https://docs.google.com/spreadsheets/d/1ME_fcszBZUgmMYaSZPc0SSsEtdDrs1GQBMuOW7DYC_I/edit#gid=922508543)

All data for the other tables and figures in the project comes from the sheet [Generating aggregate counts - key figures and tables](https://docs.google.com/spreadsheets/d/1Ls9Q5SM7ApX4pnssdFYw7WgktdS5DlF00H2HX16bhMU/edit). The tabs in the sheet are named for the figures they correspond to.

This document lines up the figure images from the draft with the Google Sheets they correspond to: [Surveillance Tasks  brief - figures with links to source data](https://docs.google.com/document/d/1TXMFZ7WnAf03hK55v6lTrwFwCfBCN2UeVscr4DF1X10/)


## Full methods writeup
[Surveillance tasks - methodology writeup](https://docs.google.com/document/d/1bcNGRmPJWSajLjtkeZABwBRyKiMWNHfcwim8CFdAN7I/edit#).


# Overview 
Our process involves the following steps:

## Identifying relevant papers
directory: identifying surveillance-task papers

### Finding top computer vision tasks
Subdirectory: identifying surveillance-task papers/finding top CV tasks
Relevant Google Sheet: [Top CV tasks - 2019 count and growth rate](https://docs.google.com/spreadsheets/d/1ME_fcszBZUgmMYaSZPc0SSsEtdDrs1GQBMuOW7DYC_I/edit#gid=922508543) 

We identify English-language computer vision papers using the SciBERT classifier, and tag these computer vision papers with tasks based on their abstracts, using the SciREX classifier. 

* Seeing the overall frequency distribution of CV tasks by 
  * query: histogramming CV tasks by frequency.sql
* Finding the most common and fastest-growing computer vision tasks in 2019. 
  * query: listing top CV tasks.sql 
* Grouping together these common tasks by their application areas, and counting papers published with these tasks.
  * query: counting 2019 CV papers in common task categories.sql

### Finding task terms related to our chosen task areas
Subdirectory: identifying surveillance-task papers/finding surveillance-related tasks
Relevant Google sheet: [Identifying related tasks](https://docs.google.com/spreadsheets/d/1TaCwxX-r0GzMyP2rmDfJ4uBEjqCA6F8nGzr_Cps_5lA/edit#gid=1623457572) 




## Computing aggregate statistics for computer vision and surveillance
Counting computer vision and surveillance papers by year.
Note: where a paper has multiple surveillance tasks, such as face recognition and action recognition, we count it as a single surveillance paper in our surveillance task count. But in our task-specific statistics, we would count it as both a face recognition paper and an action recognition paper. However, such papers are relatively rare: only 2.5% of surveillance papers we found were associated with more than one surveillance task.
Associating papers with their authors’ countries of origin and generating country-level counts of paper output.
Note: we divide papers up evenly among their countries of origin: a paper with authors from Stanford University in the United States and Oxford University in the United Kingdom would get counted as one-half of a U.S. paper and one-half of a U.K. paper.
Calculating various aggregate statistics based on query results. These statistics make up most of the figures we report in the brief, such as each country’s share of surveillance tasks in 2019. 
These calculations are done in the Google Sheet Generating aggregate counts - key figures and tables.

## Counting Chinese and world output in AI and overall research
folder: 
We use SciBERT to identify AI papers, and count unique papers in CSET’s merged corpus for overall research.

## Sanity checks




 

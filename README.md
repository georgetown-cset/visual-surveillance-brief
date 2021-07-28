
# Project links 
Project folder, including all Google Sheets: https://drive.google.com/drive/u/2/folders/1cj2AsiNaM-y8MgZDNzNnHJcg1pZOW89s

Project BigQuery database: gcp_cset_projects.surveillance_tasks_brief

Draft: [Surveillance tasks draft](https://docs.google.com/document/d/1kK6TodaNhbwCoTOfSreL_jV1l29q8DDZdKlc-e-5Ruo/edit)

Table 1 comes from the sheet [Top CV tasks - 2019 count and growth rate](https://docs.google.com/spreadsheets/d/1ME_fcszBZUgmMYaSZPc0SSsEtdDrs1GQBMuOW7DYC_I/edit#gid=922508543)

All data for the other tables and figures in the project comes from the sheet [Generating aggregate counts - key figures and tables](https://docs.google.com/spreadsheets/d/1Ls9Q5SM7ApX4pnssdFYw7WgktdS5DlF00H2HX16bhMU/edit). The tabs in the sheet are named for the figures they correspond to.

This document lines up the figure images from the draft with the Google Sheets they correspond to: [Surveillance Tasks  brief - figures with links to source data](https://docs.google.com/document/d/1TXMFZ7WnAf03hK55v6lTrwFwCfBCN2UeVscr4DF1X10/)

## Note for replications
We copied the BigQuery tables referenced in this project to the surveillance_tasks_brief dataset; the relevant BigQuery console commands are shown in the "copying tables via BQ console" file. Referencing the tables in this dataset (e.g. surveillance_tasks_brief.predictions instead of article_classifications.predictions) should replicate the results of our brief. 


## Detailed methods writeup
[Surveillance tasks - methodology writeup](https://docs.google.com/document/d/1bcNGRmPJWSajLjtkeZABwBRyKiMWNHfcwim8CFdAN7I/edit#).


# Overview 
Our process involves the following steps:

**Identifying relevant papers**

Identifying English-language computer vision papers using the SciBERT classifier, and tagging these computer vision papers with tasks based on their abstracts, using the SciREX classifier.
  * Finding common and fast-growing computer vision tasks, and choosing to focus on six common or fast-growing surveillance tasks.
  * Finding the task terms related to our chosen task areas. Starting from an initial list of terms that refer to these tasks, we identify related terms. This leaves us with a final list of terms that refer to surveillance tasks.

**Computing aggregate statistics for computer vision and surveillance**
* Counting computer vision and surveillance papers by year. 
* Counting annual papers by country
  * We associate papers with their authors’ countries of origin and generate country-level counts of paper output.
  * Note: we divide papers up evenly among their countries of origin: a paper with authors from one institution in the United States and three institutions in the United Kingdom would get counted as one-half of a U.S. paper and one-half of a U.K. paper. We chose to do this because our database of institutions is often redundant, counting “Oxford University” and “University of Oxford” as separate entities associated with a paper. 
 
* Calculating various aggregate statistics based on query results. These statistics make up most of the figures we report in the brief, such as each country’s share of surveillance tasks in 2019.

**Counting Chinese and world output in AI and overall research**

We use the SciBERT classifier to identify AI papers, and count unique papers in CSET’s merged corpus to identify overall research output.
These results let us identify whether China's high share of surveillance papers is due to high research output overall, or high concentration of its research output in AI or computer vision. We find that China's research growth rates are slightly larger than the world average, and its focus on computer vision is considerably stronger than the world average.


## Identifying relevant papers
directory: identifying surveillance-task papers

### Finding common and fast-growing computer vision tasks
Subdirectory: identifying surveillance-task papers/finding top CV tasks

Relevant Google Sheet: [Top CV tasks - 2019 count and growth rate](https://docs.google.com/spreadsheets/d/1ME_fcszBZUgmMYaSZPc0SSsEtdDrs1GQBMuOW7DYC_I/edit#gid=922508543) 

We identify English-language computer vision papers using the SciBERT classifier, and tag these computer vision papers with tasks based on their abstracts, using the SciREX classifier. 

* Seeing the overall frequency distribution of CV tasks -- this lets us observe that, while we see many CV tasks overall, very few of them appear in more than 10-20 papers. 
  * query: identifying surveillance-task papers/finding top CV tasks/ histogramming CV tasks by frequency.sql
* Finding the most common and fastest-growing computer vision tasks in 2019. 
  * query: identifying surveillance-task papers/finding top CV tasks/ listing top CV tasks.sql 
* Grouping together these common tasks by their application areas, and counting papers published with these tasks.
  * query: identifying surveillance-task papers/finding top CV tasks/ counting 2019 CV papers in common task categories.sql

**Figures:** We list the most common CV tasks in 2019 in Table 1.

### Finding task terms related to our chosen task areas
Subdirectory: identifying surveillance-task papers/finding surveillance-related tasks

Relevant Google sheet: [Identifying related tasks](https://docs.google.com/spreadsheets/d/1TaCwxX-r0GzMyP2rmDfJ4uBEjqCA6F8nGzr_Cps_5lA/edit#gid=1623457572) 

We want to find terms related to the six surveillance tasks we identified as frequent and/or fast-growing: face recognition, action recognition, crowd analysis, facial expression recognition, face anti-spoofing, and person re-identification. To do so, we identify terms that occur in the same papers and are identified by the SciREX classifier as referring to the same task. (For each paper, the SciREX classifier groups together terms that seem to refer to the same task as part of a "task cluster": we count how often terms overlap within task clusters in recent computer vision papers.)

* Insert the common surveillance task terms we found above into the table surveillance_tasks_brief.task_term_pairs
  * query: identifying surveillance-task papers/finding surveillance-related tasks/ build and iterate all-task dictionary.sql, round = 1  
* Identify terms that commonly overlap with the tasks in this table
  *  identifying surveillance-task papers/finding surveillance-related tasks/ related tasks via task clusters.sql
* Find those terms at paperswithcode.com, or find highly-cited recent papers with those terms, to determine if we should include them.
  * example query: identifying surveillance-task papers/finding surveillance-related tasks/ listing top papers for task terms.sql
* Add these relevant terms into surveillance_tasks_brief.task_term_pairs
   * query: identifying surveillance-task papers/finding surveillance-related tasks/ build and iterate all-task dictionary.sql, round >= 1   

Repeat the above process until we no longer see relevant new terms to add.

* Sanity check: look for terms and overlaps with "general surveillance" terms like "public safety" and "video surveillance". We find that these terms are too broad, and so don't include them. 
  * query: identifying surveillance-task papers/finding surveillance-related tasks/ surveillance-general tasks - find highly overlapping tasks.sql
* Sanity check: see how heavily our results overlap with these "general surveillance" terms
  * query: identifying surveillance-task papers/finding surveillance-related tasks/ surveillance-general tasks - overlap with domain-specific surveillance.sql 
   
For more information on this process, see [the relevant section of the methodology writeup](https://docs.google.com/document/d/1bcNGRmPJWSajLjtkeZABwBRyKiMWNHfcwim8CFdAN7I/edit#heading=h.fswe7ptbiy5h).


## Computing aggregate statistics for computer vision and surveillance
Relevant Google Sheet:  [Generating aggregate counts - key figures and tables](https://docs.google.com/spreadsheets/d/1Ls9Q5SM7ApX4pnssdFYw7WgktdS5DlF00H2HX16bhMU/edit)
Relevant directory: aggregate paper counts

### Overall scale for CV and surveillance per year
* Counting annual computer vision papers
  * query: recent CV papers with a task and country.sql

**Note:** we filter for papers in our merged corpus which have both an associated country and task. When we run a sanity check, we find that these comprise a large share of all computer vision papers. 
  * query: sanity checks / share of CV papers with a task and country.sql 

* Counting annual surveillance papers
  * query: aggregate paper counts/ counting all surveillance papers.sql
* Counting annual surveillance papers by task
  * query: aggregate paper counts/ counting surveillance papers by task.sql    

**Note:** where a paper has multiple surveillance tasks, such as face recognition and action recognition, we count it as a single surveillance paper in our surveillance task count. But in our task-specific statistics, we would count it as both a face recognition paper and an action recognition paper. However, such papers are relatively rare: only 2.5% of surveillance papers we found were associated with more than one surveillance task.
  * These results are found via the query: sanity checks / overlaps between surveillance tasks.sql . 

**Figures:** These results lets us evaluate surveillance as a share of CV research over time (Figure 1). They also let us compare the size and growth rate of surveillance tasks and computer vision (Table 4 and Figure 4).

### Counting papers by country and year
We then associate papers with their authors’ countries of origin and generating country-level counts of paper output.
**Note:** we divide papers up evenly among their countries of origin: a paper with authors from Stanford University in the United States and Oxford University in the United Kingdom would get counted as one-half of a U.S. paper and one-half of a U.K. paper.

* Count annual computer vision papers by country
  * aggregate paper counts/ counting CV papers by country.sql
* Count annual surveillance papers by country
  *  aggregate paper counts/ counting all surv papers by country.sql
* Count annual surveillance papers by country and task
   * aggregate paper counts/ counting surveillance papers by task and country.sql

**Figures:** These results let us compute:
* Each country's share of world surveillance research over time (Figure 2)
* Surveillance as a share of each country's CV research over time (Figure 3)
* China versus US allies' share of surveillance research during the 2015-2019 period (Figure 5)
* China's changing share of surveillance tasks over time (Figure 6)

## Counting Chinese and world output in AI and overall research
directory:  comparing paper growth across surv, CV, AI, all research
Relevant Google Sheet:  [Generating aggregate counts - key figures and tables](https://docs.google.com/spreadsheets/d/1Ls9Q5SM7ApX4pnssdFYw7WgktdS5DlF00H2HX16bhMU/edit)

We count the number of Chinese and world papers on all topics, AI, computer vision, and surveillance. This lets us identify whether China's large share of surveillance research is due to large research output overall, or a particular concentration in AI, computer vision, or surveillance.

* We use SciBERT to identify AI papers, and count unique papers in CSET’s merged corpus for overall research.
 * note: we identify AI papers via the SciBERT classifier, accepting any paper that's flagged as AI, computer vision, robotics, or natural language processing. Our results may differ somewhat from other analyses which use just the SciBERT AI classifier. 
  * comparing paper growth across surv, CV, AI, all research/ counting all research by country.sql
  * comparing paper growth across surv, CV, AI, all research/ counting all AI papers by country.sql
* We also make use of some queries mentioned in the above section
  *  aggregate paper counts / recent CV papers with a task and country.sql
  *  aggregate paper counts / counting surv papers by country.sql
 
**Figures:** We find the biggest divergence between Chinese and world research is that China has a higher share of its AI research going towards computer vision (roughly 40%, vs roughly 30% world). Chinese AI research in general is also growing slightly faster than world AI research. These results are presented in Tables 2 and 3. 




 

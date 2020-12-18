# The project
This is a repo for the visual surveillance data brief written by Max L, Ashwin A, and James D in late 2020 for publication early 2021.

# Our data process

## Task-tagging pipeline (Python)
* We use the tasks and methods tagging system described in https://github.com/georgetown-cset/task-and-method-annotation
    * extract a list of tasks for MAG computer vision articles 
        * (identified as computer vision based on James's tagger) 
    * use regular expression matching to count how many of a paper's tasks match a list of seven "visual surveillance" tasks
        * face recognition, emotion recognition, gait analysis, crowd counting, action recognition, face anti-spoofing, and person recognition
        * we have a dictionary where each of these task areas is associated with a list of regular expressions
        * for each paper in our pipeline, we count how many of its tasks match face recognition terms, how many match emotion recognition terms, etc.
* we save the results in a csv, which I've uploaded to BigQuery as surveillance_tasks_brief.surveillance_task_articles_1109_maxdict 

## Finding papers in surveillance-heavy clusters (BigQuery)

* Using the science_map dataset, we identify 1769 DC5 clusters containing our ~17000 surveillance-tagged papers
* We restrict our analysis to 51 clusters which contain >=30 pipeline papers of which >=50% were tagged with a surveillance task
    * ~9000 of our pipeline papers are contained in these clusters
    
* We compute stats for the papers in these 51 clusters, focusing on papers from 2015-2019
* We aggregate these statistics based on paper affiliations to get country-level statistics by year


## Google Sheets analysis
## Calculating total computer vision numbers, for comparison with surveillance



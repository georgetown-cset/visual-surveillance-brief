# The project
This is a repo for the visual surveillance data brief written by Max L, Ashwin A, and James D in late 2020 for publication early 2021.

# Our data process

## Task-tagging pipeline (Python)
* We use the tasks and methods tagging system described in https://github.com/georgetown-cset/task-and-method-annotation
    * extract a list of tasks for MAG computer vision articles. (Max to upload and describe)
        * (the MAG papers are identified as computer vision based on James's tagger) 
* Before deciding to focus on surveillance, we looked for the most popular tasks, and the tasks which the US focused on more than China (and vice-versa). (finding top tasks.ipynb)
* We then process the results, tagging papers based on the surveillance tasks they work on. (tagging papers as surveillance.ipynb)
    * use regular expression matching to count how many of a paper's tasks match a list of seven "visual surveillance" tasks
        * face recognition, emotion recognition, gait analysis, crowd counting, action recognition, face anti-spoofing, and person recognition
        * we have a dictionary where each of these task areas is associated with a list of regular expressions
        * for each paper in our pipeline, we count how many of its tasks match face recognition terms, how many match emotion recognition terms, etc.
    * we also check that our dictionaries aren't missing associated tasks, by checking for tasks that often occur in the same paper as our regex terms
* We save the resulting list of surveillance-task-flagged papers in a csv, which I've uploaded to BigQuery as [surveillance_tasks_brief.surveillance_task_articles_1109_maxdict](https://console.cloud.google.com/bigquery?project=gcp-cset-projects&p=gcp-cset-projects&d=surveillance_tasks_brief&t=surveillance_task_articles_1109_maxdict&page=table)

## Finding papers in surveillance-heavy clusters (BigQuery)

* Using the science_map dataset, we identify 1769 DC5 clusters containing our ~17000 surveillance-tagged papers
* We restrict our analysis to 51 clusters which contain >=30 pipeline papers of which >=50% were tagged with a surveillance task
    * ~9000 of our pipeline papers are contained in these clusters
    
* We compute stats for the papers in these 51 clusters, focusing on papers from 2015-2019
* We aggregate these statistics based on paper affiliations to get country-level statistics by year


## Google Sheets surveillance analysis
* We then analyze the country-year stats in Google Sheets. https://docs.google.com/spreadsheets/d/1208sb0o4eD8lY98pPUNn33_3dwFkBqg-1qZL9cZyBJQ/edit#gid=663614057
* We create pivot tables to analyze the country-level surveillance results, looking at tasks over time, countries over time, and countries by task.


## Calculating total computer vision numbers, and comparing with surveillance
* We use the same country-affiliation methods to calculate the number of computer vision papers per country by year 
    * Counting papers tagged as CV by James' ArXiv-trained classifier
* We save the CV country-year stats, and a copy of the surveillance country-year stats, in a Google Sheet: https://docs.google.com/spreadsheets/d/1owkiWTt5N5SNMBw4PnaocaWAlGWBwzfxdP1oPgvgpBc/edit#gid=1011004304
* We make pivot tables to get CV publication stats by country and year
    * We compare them to the surveillance stats to get countries' %surveillance over time


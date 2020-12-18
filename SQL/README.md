# Narrowing down to a list of surveillance-heavy research clusters:

## generating all_surv_clusters_task_tagging_1217
* We find the 1769 clusters with at least one paper tagged as surveillance. 
* We calculate relevant stats including:
    * n_cv_task_15_19 (number of pipeline papers)
    * n_cv_surv_15_19 (number of pipeline papers tagged as surveillance)
    * cv_surv_frac_15_19 (= proportion of pipeline papers tagged as surveillance) 
    * p_{task} (proportion of surveillance-tagged pipeline papers tagged w each task), 
* Result is stored in surveillance_tasks_brief.all_surv_clusters_task_tagging_1217
    * previous version: aa2291_sandbox.all_surv_clusters_task_tagging_1217
    * initial version: aa2291_sandbox.all_surv_clusters_task_tagging

## generating surv_clusters_top_1119
Filtering for cv_surv_frac_15_19 >= .5 and n_cv_task_15_19 >= 30 gives the top 51 clusters. The rest of our analysis is based on papers from these clusters published in the years 2015-2019. 
* 51 clusters, with surveillance stats: surveillance_tasks_brief.surv_clusters_top_1119
    * formerly aa2291_sandbox.surv_clusters_task_201119


# Getting the papers in those clusters

## surveillance - generating surveillance_cluster_papers_201119
Get relevant stats for papers in these 51 clusters. 
* Count the number of countries and organizations associated with each paper. Get basic stats (year, title) from corpus_merged.
* result is stored in surveillance_tasks_brief.surveillance_cluster_papers_1119
    * formerly aa2291_sandbox.surveillance_cluster_papers_201119

64,595 papers; 27,550 papers with a year between 2015 and 2019 (inclusive); 22,704 of those papers have at least one associated country

# Generating country-level stats

## surveillance - generating country_stats
* generate the list of affiliated countries for each article in aa2291_sandbox.surveillance_cluster_papers_201119 published between 2015 and 2019
* for each article-country pair generated, count 1/N_a towards exp_surv for the country, where N_a is the number of countries associated with the article
    * Multiply by the article’s p_{task} stat to get its contribution to the task-specific output of that country
* aggregate by country and year, looking only at years between 2015 and 2019.
* tag countries’ membership in disjoint country_groups. This includes EU 27, CANZUK, and also EFTA, ASEAN (Southeast Asia), and a list of Middle Eastern countries.
* result is stored in aa2291_sandbox.surveillance_country_stats_15_19

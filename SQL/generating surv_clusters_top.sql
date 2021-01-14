--from our list of 1769 clusters, filter to those with a significant number of CV pipeline papers (>30) and with a >50% rate of those papers being tagged as surveillance
--empirically, we think this does a fairly good job of capturing surveillance-focused clusters (high precision), although it likely misses a decent number as well (uncertain recall). 

--results are saved in surveillance_tasks_brief.surv_clusters_top_1119
SELECT *
FROM `surveillance_tasks_brief.all_surv_clusters_task_tagging_1217`
WHERE
  cv_surv_fraction_15_19 >= .5
  AND n_cv_task_15_19 >= 30
ORDER BY
  cv_surv_fraction_15_19 DESC

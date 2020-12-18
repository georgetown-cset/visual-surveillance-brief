WITH cv_papers as(
SELECT distinct cset_id as merged_id, year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
WHERE cv_filtered = TRUE
AND country IS NOT NULL
),

cv_task_recent_count as(
SELECT spans as task, 
SUM(CASE WHEN year = 2019 THEN 1 ELSE 0 END) as n_2019, 
FROM tasks_and_methods.tasks
CROSS JOIN UNNEST(spans) as spans
INNER JOIN cv_papers USING(merged_id)
GROUP BY spans
),

cv_task_bins as(
SELECT 
(CASE WHEN n_2019 = 1 THEN 0 ELSE FLOOR(n_2019/10)+1 END) as bin, 
COUNT(*) as n_terms
FROM cv_task_recent_count
GROUP BY bin
ORDER BY bin ASC)

SELECT * from cv_task_bins


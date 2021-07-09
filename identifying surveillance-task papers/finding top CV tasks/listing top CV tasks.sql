WITH cv_papers as (
    SELECT distinct cset_id as merged_id, year
from article_classification.predictions preds
    INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs
ON(preds.cset_id = affs.merged_id)
WHERE cv_filtered = TRUE
  AND country IS NOT NULL
    )
    , cv_task_recent_count as (
SELECT spans as task,
    SUM (CASE WHEN year = 2019 THEN 1 ELSE 0 END) as n_2019,
    SUM (CASE WHEN year = 2018 THEN 1 ELSE 0 END) as n_2018
FROM tasks_and_methods.tasks
    CROSS JOIN UNNEST(spans) as spans
    INNER JOIN cv_papers USING (merged_id)
GROUP BY spans
    ),
    summary_table AS (
SELECT task, n_2019, n_2018,
    (CASE WHEN n_2018 >= 1 THEN n_2019/n_2018 -1 ELSE NULL END) as growth_rate
FROM cv_task_recent_count
ORDER BY n_2019 DESC),
    largest_tasks AS (
SELECT *, "top largest tasks" as category
from summary_table
ORDER BY n_2019 DESC
    LIMIT 100),
    fastest_growing_tasks AS (
SELECT *, "top fastest-growing tasks" as category
from summary_table
WHERE n_2018 >= 10 --filter out very small tasks which may look fast-growing due to noise
ORDER BY growth_rate DESC
    LIMIT 100)

SELECT *
from largest_tasks
UNION ALL
SELECT *
from fastest_growing_tasks

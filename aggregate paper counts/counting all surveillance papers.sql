--unpack surveillance tasks
WITH task_term_pairs AS (
    SELECT DISTINCT base_task, raw_task
    from surveillance_tasks_brief.task_term_pairs),

--filter for recent computer vision papers with a tagged country
     recent_cv_papers AS (
         SELECT distinct cset_id as merged_id, meta.year as year
from article_classification.predictions preds
    INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs
ON(preds.cset_id = affs.merged_id)
    INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING (merged_id)
WHERE cv_filtered = TRUE
  AND country IS NOT NULL
  AND meta.year >= 2015
  AND meta.year <=2019
    ),

--filter for papers that contain at least one surveillance task
    task_papers AS (
SELECT merged_id, raw_task, base_task, year
FROM tasks_and_methods.tasks task_data
    CROSS JOIN UNNEST(spans) as span
    INNER JOIN recent_cv_papers USING (merged_id)
    INNER JOIN task_term_pairs
ON(span = task_term_pairs.raw_task)
    )

--count surveillance paper by year
SELECT year, COUNT (DISTINCT merged_id) as surv_papers
FROM task_papers
GROUP BY year
ORDER BY year DESC

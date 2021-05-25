WITH task_family_pairs AS(
SELECT DISTINCT parent_task as task_family, raw_task 
from surveillance_tasks_brief.task_parent_pairs),

recent_cv_papers AS(
SELECT distinct cset_id as merged_id, meta.year as year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING(merged_id)
WHERE cv = TRUE
AND country IS NOT NULL
AND meta.year >= 2015 AND meta.year <=2019
),

--get recent computer vision papers that contain surveillance tasks
task_papers AS(
SELECT merged_id, raw_task, task_family as base_task, year
FROM tasks_and_methods.tasks task_data
CROSS JOIN UNNEST(spans) as span
INNER JOIN recent_cv_papers USING(merged_id)
INNER JOIN task_family_pairs ON(span = task_family_pairs.raw_task)
)

SELECT year, base_task, COUNT(DISTINCT merged_id) as task_papers
FROM task_papers
GROUP BY year, base_task
ORDER BY year DESC, base_task ASC

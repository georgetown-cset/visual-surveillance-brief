WITH
recent_cv_papers AS(
SELECT distinct cset_id as merged_id, meta.year as year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING(merged_id)
WHERE cv_filtered = TRUE
AND country IS NOT NULL
AND meta.year >= 2015 AND meta.year <=2019
),

--get recent computer vision papers that contain popular or fast-growing surveillance task terms
general_task_papers AS(
SELECT DISTINCT merged_id, "general surveillance tasks" as category
FROM tasks_and_methods.tasks task_data
CROSS JOIN UNNEST(spans) as span
INNER JOIN recent_cv_papers USING(merged_id)
WHERE span IN ('video surveillance', 'visual surveillance', 'public safety', 'surveillance', 'security')

),


--count number of papers with each base task
general_task_count AS(
SELECT category, COUNT(DISTINCT merged_id) as n_general
from general_task_papers
GROUP BY category),

--find tasks that appear in the same papers
overlapping_tasks AS(
SELECT category, spans as overlap_task, COUNT(DISTINCT merged_id) as n_overlap
FROM tasks_and_methods.tasks
CROSS JOIN UNNEST(spans) as spans
INNER JOIN general_task_papers USING(merged_id)
GROUP BY category, spans
),

--count the total appearances (in all CV papers) of these overlapping tasks
overlapping_task_count AS(
SELECT overlap_task, COUNT(DISTINCT merged_id) as n_other
FROM tasks_and_methods.tasks
CROSS JOIN UNNEST(spans) as overlap_task
INNER JOIN overlapping_tasks USING(overlap_task)
INNER JOIN recent_cv_papers USING(merged_id)
GROUP BY overlap_task
),

--combine our statistics
top_overlapping_tasks AS(
SELECT category, overlap_task, n_general, n_other, n_overlap, n_overlap/n_other as overlap_given_other, n_overlap/n_general as overlap_given_base
FROM overlapping_tasks
INNER JOIN overlapping_task_count USING(overlap_task)
INNER JOIN general_task_count USING(category)
)

--generate a list of top overlapping tasks
SELECT *, (n_other-n_overlap)/n_general as added_scale from top_overlapping_tasks
WHERE overlap_given_other < 1 --filter out sub-tasks
AND overlap_given_other >= .01 --filter for tasks that are fairly relevant 
AND (n_other - n_overlap) >= .05 * n_general --filter out tasks that don't add many more papers
ORDER BY category ASC, added_scale DESC

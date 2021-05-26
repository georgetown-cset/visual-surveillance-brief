WITH recent_cv_papers AS(
SELECT distinct cset_id as merged_id, year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
WHERE cv = TRUE
AND country IS NOT NULL
AND year >= 2015 AND year <=2019
),

--get recent computer vision papers that contain popular or fast-growing surveillance task terms
base_task_papers AS(
SELECT merged_id, span as base_task
FROM tasks_and_methods.tasks task_data
CROSS JOIN UNNEST(spans) as span
INNER JOIN recent_cv_papers USING(merged_id)
WHERE span IN ("event detection", "abnormal activity detection", "crowd management", "video surveillance", "visual surveillance", "surveillance", "detection and tracking", "public security", "detecting people")
),


--count number of papers with each base task
base_task_count AS(
SELECT base_task, COUNT(DISTINCT merged_id) as n_base
from base_task_papers
GROUP BY base_task),

--find tasks that appear in the same papers
overlapping_tasks AS(
SELECT spans as overlap_task, base_task, COUNT(DISTINCT merged_id) as n_overlap
FROM tasks_and_methods.tasks
CROSS JOIN UNNEST(spans) as spans
INNER JOIN base_task_papers USING(merged_id)
GROUP BY spans, base_task
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
SELECT base_task, overlap_task, n_base, n_other, n_overlap, n_overlap/n_other as overlap_given_other, n_overlap/n_base as overlap_given_base
FROM overlapping_tasks
INNER JOIN base_task_count USING(base_task)
INNER JOIN overlapping_task_count USING(overlap_task)
)

--generate a list of top overlapping tasks
SELECT *, (n_other-n_overlap)/n_base as added_scale from top_overlapping_tasks
WHERE overlap_given_other < 1 --filter out sub-tasks
AND overlap_task NOT IN (SELECT DISTINCT base_task FROM base_task_papers) --filter out our search terms
AND overlap_given_other >= .05 --filter for tasks that are fairly relevant 
AND (n_other - n_overlap) >= .05 * n_base --filter out tasks that don't add many more papers
AND n_overlap > 1
ORDER BY base_task ASC, added_scale DESC

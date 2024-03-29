WITH task_term_pairs AS (
    SELECT DISTINCT base_task, raw_task
    from surveillance_tasks_brief.task_term_pairs),

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
    )
    ,

--get recent computer vision papers that contain surveillance tasks
    task_papers AS (
SELECT merged_id, raw_task, base_task, year
FROM tasks_and_methods.tasks task_data
    CROSS JOIN UNNEST(spans) as span
    INNER JOIN recent_cv_papers USING (merged_id)
    INNER JOIN task_term_pairs
ON(span = task_term_pairs.raw_task)
    ),

    general_task_papers AS (
SELECT DISTINCT merged_id
FROM tasks_and_methods.tasks task_data
    CROSS JOIN UNNEST(spans) as span
    INNER JOIN recent_cv_papers USING (merged_id)
WHERE span IN ('video surveillance'
    , 'visual surveillance'
    , 'public safety'
    , 'surveillance'
    , 'security')
    )
    ,

--count all papers with general surv tasks
    general_scale AS (
SELECT "all general-surveillance tasks" as category, COUNT (DISTINCT merged_id) as NP
FROM general_task_papers),

--count the overlap between general surv tasks and our domain-specific tasks
    surv_overlaps AS (
SELECT "all general-surveillance tasks" as category, COUNT (DISTINCT merged_id) as covered_papers
FROM task_papers
    INNER JOIN general_task_papers USING (merged_id)
    ),
    overlap_share AS (
SELECT NP, covered_papers, covered_papers/NP as covered_share
FROM general_scale
    LEFT JOIN surv_overlaps USING (category))

SELECT *
from overlap_share

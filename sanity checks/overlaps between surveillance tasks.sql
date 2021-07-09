WITH task_family_pairs AS (
    SELECT DISTINCT parent_task as task_family, raw_task
    from surveillance_tasks_brief.task_parent_pairs),

     recent_cv_papers AS (
         SELECT distinct cset_id as merged_id, meta.year as year
from article_classification.predictions preds
    INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs
ON(preds.cset_id = affs.merged_id)
    INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING (merged_id)
WHERE cv = TRUE
  AND country IS NOT NULL
  AND meta.year >= 2015
  AND meta.year <=2019
    ),

--get recent computer vision papers that contain surveillance tasks
    task_papers AS (
SELECT merged_id, raw_task, task_family as base_task, year
FROM tasks_and_methods.tasks task_data
    CROSS JOIN UNNEST(spans) as span
    INNER JOIN recent_cv_papers USING (merged_id)
    INNER JOIN task_family_pairs
ON(span = task_family_pairs.raw_task)
    ),

--select papers with >1 surveillance task
    task_overlaps AS (
SELECT merged_id, COUNT (DISTINCT base_task) as n_tasks
FROM task_papers
GROUP BY merged_id
    ),


--count total overlaps by task
    total_overlap_count AS (
SELECT base_task, COUNT (DISTINCT merged_id) as multiple_task_papers
FROM task_papers
    INNER JOIN task_overlaps USING (merged_id)
WHERE n_tasks >= 2
GROUP BY base_task),
    all_overlaps AS (
SELECT SUM (1) as NP,
    SUM (CASE WHEN n_tasks >=2 THEN 1 ELSE 0 END) as multiple_task_papers
FROM task_overlaps),

--count all papers for each task
    task_scale AS (
SELECT base_task, COUNT (DISTINCT merged_id) as NP
FROM task_papers
GROUP BY base_task),

--select facerec papers and see how many papers for each task are facerec
    facerec_papers AS (
SELECT DISTINCT merged_id
FROM task_papers
WHERE base_task = "face recognition"
    )
    , facerec_overlaps AS (
SELECT base_task, COUNT (DISTINCT merged_id) as facerec_papers
FROM task_papers
    INNER JOIN facerec_papers USING (merged_id)
WHERE base_task != "face recognition"
GROUP BY base_task
    ),
    overlap_share AS (
SELECT base_task, multiple_task_papers, facerec_papers, NP, multiple_task_papers/NP as overlap_fraction, facerec_papers/NP as facerec_overlap_fraction
FROM task_scale
    LEFT JOIN total_overlap_count USING (base_task)
    LEFT JOIN facereC_overlaps USING (base_task)),
    overall_surv_stats AS (
SELECT "all surveillance" as base_task, multiple_task_papers, NP, multiple_task_papers/NP as overlap_fraction
FROM all_overlaps)

SELECT *
from overlap_share
UNION ALL
SELECT base_task, multiple_task_papers, NULL, NP, overlap_fraction, NULL
from overall_surv_stats

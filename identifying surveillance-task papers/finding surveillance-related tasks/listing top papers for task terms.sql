WITH task_term_pairs AS(
SELECT DISTINCT parent_task as base_task, raw_task 
from surveillance_tasks_brief.task_term_pairs
),

recent_cv_papers AS(
SELECT distinct cset_id as merged_id, meta.year as year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING(merged_id)
WHERE cv_filtered = TRUE
AND country IS NOT NULL
AND meta.year >= 2015 AND meta.year <=2019
),

--get recent CV papers that include surveillance tasks
base_task_papers AS(
SELECT merged_id, raw_task, base_task
FROM tasks_and_methods.tasks task_data
CROSS JOIN UNNEST(spans) as span
INNER JOIN recent_cv_papers USING(merged_id)
INNER JOIN task_term_pairs ON(span = task_term_pairs.raw_task)
),

--get recent computer vision papers that contain tasks of interest
--excluding known surveillance papers: do these task terms add more surveillance papers of interest?

task_papers AS(
SELECT DISTINCT merged_id, span, field_percentile
FROM tasks_and_methods.tasks task_data
INNER JOIN citation_percentiles.citation_percentiles USING(merged_id)
CROSS JOIN UNNEST(spans) as span
WHERE 

-- overlapping tasks from round 4 of iteration with >=5% overlap_given_other:
(span IN(

'ar',
'counting',
'people detection',
'face biometrics',
'facial landmark detection',
'face perception',
'pedestrian tracking'
)
--2.5% - 5% overlap_given_other:
OR span IN(
  'gesture recognition',
'person identification',
'scene recognition',
'anomaly detection',
'human tracking',
'behavior recognition',
'tracking-by-detection',
'gesture recognition',
'face alignment',
'face identification',
'person identification',
'human tracking',
'people detection'
)
)  
AND merged_id NOT IN(SELECT DISTINCT merged_id from base_task_papers)
AND merged_id IN(SELECT DISTINCT merged_id FROM recent_cv_papers)
),

ranked_task_papers AS(
SELECT DISTINCT *, RANK() OVER(PARTITION BY span ORDER BY field_percentile DESC) as cite_rank_for_task
FROM task_papers
)
  
  
  
--generate a list of top papers from overlapping tasks
SELECT merged_id, span, title, abstract, doi, year, field_percentile 
  from ranked_task_papers
LEFT JOIN gcp_cset_links_v2.article_merged_meta USING(merged_id)
WHERE cite_rank_for_task <= 10
  ORDER BY span DESC, cite_rank_for_task ASC

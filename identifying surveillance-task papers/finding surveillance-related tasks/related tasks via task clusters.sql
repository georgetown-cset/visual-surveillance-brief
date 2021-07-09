--get top surveillance tasks
-- base_task = umbrella term for the task
-- raw_task = a string associated with that general task
-- e.g.: "action recognition" is one of our six base_tasks; "human activity recognition" might be a raw task under "action recognition"
WITH task_term_pairs AS (
    SELECT DISTINCT parent_task as base_task, raw_task
    from surveillance_tasks_brief.task_parent_pairs_alltask
),

--filter to CV papers from 2015-19, with at least one country associated with them
--this is the corpus we'll use for the surveillance tasks brief
     recent_cv_papers AS (
         SELECT distinct cset_id as merged_id, year
from article_classification.predictions preds
    INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs
ON(preds.cset_id = affs.merged_id)
WHERE cv_filtered = TRUE
  AND country IS NOT NULL
  AND year >= 2015
  AND year <=2019
    ),

--get recent computer vision papers that contain popular or fast-growing surveillance task terms
    base_task_papers AS (
SELECT merged_id, raw_task, base_task
FROM tasks_and_methods.tasks task_data
    CROSS JOIN UNNEST(spans) as span
    INNER JOIN recent_cv_papers USING (merged_id)
    INNER JOIN task_term_pairs
ON(span = task_term_pairs.raw_task)
    ),

--count number of papers with each base task
    base_task_count AS (
SELECT base_task, COUNT (DISTINCT merged_id) as n_base
from base_task_papers
GROUP BY base_task),

--list all task clusters and their members for papers with a base task
    base_task_paper_clusters AS (
SELECT merged_id, name as cluster_name, member as task
FROM tasks_and_methods.task_clusters
    LEFT JOIN UNNEST(clusters) as unnest_tasks
    LEFT JOIN UNNEST(members)
    as member
    INNER JOIN base_task_papers USING (merged_id)
    ),

--list all task clusters containing a base task
    base_task_clusters AS (
SELECT DISTINCT merged_id, cluster_name, base_task
FROM base_task_paper_clusters
    INNER JOIN task_term_pairs
ON(task_term_pairs.raw_task = base_task_paper_clusters.task)
    ),

--list all tasks that share at least one cluster with a base task, and count the number of overlapping papers for each (overlap_task, base_task) pair
    overlapping_tasks AS (
SELECT task as overlap_task, base_task, COUNT (DISTINCT merged_id) as n_overlap
FROM base_task_paper_clusters
    INNER JOIN base_task_clusters USING (merged_id, cluster_name)
GROUP BY overlap_task, base_task
    ),

--count number of papers each overlap_task appears in
    overlapping_task_count AS (
SELECT overlap_task, COUNT (DISTINCT merged_id) as n_other
FROM tasks_and_methods.tasks
    CROSS JOIN UNNEST(spans) as overlap_task
    INNER JOIN overlapping_tasks USING (overlap_task)
    INNER JOIN recent_cv_papers USING (merged_id)
GROUP BY overlap_task
    ),

--combine our statistics
    top_overlapping_tasks AS (
SELECT base_task, overlap_task, n_base, n_other, n_overlap, n_overlap/n_other as overlap_given_other, n_overlap/n_base as overlap_given_base
FROM overlapping_tasks
    INNER JOIN base_task_count USING (base_task)
    INNER JOIN overlapping_task_count USING (overlap_task)
    )

--generate a list of top overlapping tasks
SELECT *
from top_overlapping_tasks
WHERE overlap_given_other >= .05                                            --filter for tasks that are fairly relevant
  AND (n_other - n_overlap) >= .05 * n_base                                 --filter out tasks that don't add many more papers
  AND overlap_given_other < 1                                               --filter out sub-tasks
  AND overlap_task NOT IN (SELECT DISTINCT raw_task FROM task_term_pairs) --filter out our search terms
ORDER BY base_task ASC, n_other DESC

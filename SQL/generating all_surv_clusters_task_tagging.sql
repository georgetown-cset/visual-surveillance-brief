--binary variables for visual surveillance tasks. Note that a paper can have more than one task
WITH
  task_tagged_articles AS (
    SELECT
      article_id,
      year,
      CASE WHEN facial_recognition_detection > 0 THEN 1 ELSE 0 END AS n_facerec,
      CASE WHEN gait > 0 THEN 1 ELSE 0 END AS n_gait,
      CASE WHEN person_identification > 0 THEN 1 ELSE 0 END AS n_personrec,
      CASE WHEN anti_spoofing > 0 THEN 1 ELSE 0 END AS n_spoof_detection,
      CASE WHEN emotion_expression > 0 THEN 1 ELSE 0 END AS n_emotionrec,
      CASE WHEN crowd_surveillance > 0 THEN 1 ELSE 0 END AS n_crowd,
      CASE WHEN action_recognition > 0 THEN 1 ELSE 0 END AS n_action
-- table that I generated: list of papers + count of which tasks they were tagged with
    FROM `gcp-cset-projects.surveillance_tasks_brief.surveillance_task_articles_1109_maxdict`
    WHERE
      total_matches > 0
  ),

--number of tasks present
  n_tasks_article AS (
    SELECT
      article_id,
        n_facerec + n_gait + n_personrec + n_spoof_detection + n_emotionrec + n_crowd + n_action AS tasks_present
    FROM task_tagged_articles
  ),

--articles divided among task areas based on which task-tags are present
  tag_presence_articles_15_19 AS (
    SELECT
      article_id,
      year,
      n_facerec / tasks_present AS p_facerec_presence,
      n_gait / tasks_present AS p_gait_presence,
      n_personrec / tasks_present AS p_personrec_presence,
      n_spoof_detection / tasks_present AS p_spoof_detection_presence,
      n_emotionrec / tasks_present AS p_emotionrec_presence,
      n_crowd / tasks_present AS p_crowd_presence,
      n_action / tasks_present AS p_action_presence
    FROM task_tagged_articles
    INNER JOIN n_tasks_article USING (article_id)
    WHERE
      year > 2014
      AND year < 2020
  ),

--all CV papers put through the task-tagging pipeline, with publication years 2015-2019
  cv_task_papers_15_19 AS (
    SELECT DISTINCT
      article_id
    FROM surveillance_tasks_brief.surveillance_task_articles_1109_maxdict
    WHERE
      year > 2014
      AND year < 2020
  ),

--count of CV task-tagged papers by cluster
  cv_task_papers_count_15_19 AS (
    SELECT
      count(DISTINCT article_id) AS n_cv_task,
      cluster_id
    FROM cv_task_papers_15_19
    INNER JOIN science_map.dc5_cluster_assignment_stable assign USING (article_id)
    GROUP BY
      cluster_id
  ),

--count of surveillance task-tagged papers by cluster
--formerly called "mag_surveillance_count"
  tagged_surveillance_count_15_19 AS (
    SELECT
      count(DISTINCT article_id) AS n_tagged_surv_15_19,
      cluster_id
    FROM surveillance_tasks_brief.surveillance_task_articles_1109_maxdict
    INNER JOIN science_map.dc5_cluster_assignment_stable assign USING (article_id)
    WHERE
      year > 2014
      AND year < 2020
      AND total_matches > 0
    GROUP BY
      cluster_id
  ),

--fraction of CV task-tagged papers tagged with at least one visual surveillance task, by cluster
  cv_task_papers_prop_15_19 AS (
    SELECT
      cluster_id,
      n_tagged_surv_15_19 AS n_cv_surv_15_19,
      n_cv_task AS n_cv_task_15_19,
      n_tagged_surv_15_19 / n_cv_task AS cv_surv_fraction_15_19,
    FROM cv_task_papers_count_15_19
    INNER JOIN tagged_surveillance_count_15_19 USING (cluster_id)
  ),

--distribution of visual surveillance tasks by cluster
--based on presence of tags in papers (each paper has the same total weight, distributed equally across tasks present in the paper)
  cluster_task_weights_presence AS (
    SELECT
      cluster_id,
      avg(p_facerec_presence) AS p_facerec,
      avg(p_gait_presence) AS p_gait,
      avg(p_personrec_presence) AS p_personrec,
      avg(p_spoof_detection_presence) AS p_spoof_detection,
      avg(p_emotionrec_presence) AS p_emotionrec,
      avg(p_crowd_presence) AS p_crowd,
      avg(p_action_presence) AS p_action,
    FROM tag_presence_articles_15_19
    INNER JOIN science_map.dc5_cluster_assignment_stable assign USING (article_id)
    GROUP BY
      cluster_id
  )

SELECT *
FROM cv_task_papers_prop_15_19
LEFT JOIN cluster_task_weights_presence USING (cluster_id)
ORDER BY
  cv_surv_fraction_15_19 DESC

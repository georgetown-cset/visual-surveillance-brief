WITH task_term_pairs AS (
    SELECT DISTINCT base_task,
                    raw_task
    FROM surveillance_tasks_brief.task_term_pairs
),

     recent_cv_papers AS (
         SELECT DISTINCT cset_id AS merged_id,
                         meta.year AS YEAR
FROM article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING (merged_id)

WHERE
    cv_filtered = TRUE
  AND country IS NOT NULL
  AND meta.year >= 2015
  AND meta.year <=2019 ),


--get recent computer vision papers that contain surveillance tasks
    task_papers AS (
SELECT
    merged_id, raw_task, base_task, YEAR
FROM tasks_and_methods.tasks task_data CROSS JOIN UNNEST(spans) AS span INNER JOIN recent_cv_papers USING (merged_id) INNER JOIN task_term_pairs
ON(span = task_term_pairs.raw_task) ),

    --get all papers with at least one surveillance task
    surv_papers AS (
SELECT
    DISTINCT merged_id, YEAR
FROM task_papers), paper_country_counts AS (
SELECT
    merged_id, COUNT (
    DISTINCT country) AS n_countries
FROM surv_papers INNER JOIN gcp_cset_links_v2.paper_affiliations_merged USING (merged_id)
WHERE
    country IS NOT NULL
GROUP BY
    merged_id ), country_task_counts AS (
SELECT
    country, YEAR, COUNT (
    DISTINCT merged_id) AS NP, SUM (
    1./n_countries) AS NP_norm
FROM paper_country_counts INNER JOIN surv_papers USING (merged_id) INNER JOIN (SELECT DISTINCT merged_id, country FROM gcp_cset_links_v2.paper_affiliations_merged) USING (merged_id)
WHERE
    country IS NOT NULL
GROUP BY
    country, YEAR ),


--tag countries by membership in one of several groups
--note: the groups do not overlap. Countries not included in a specific group are tagged with the "Other" group.
    country_groups AS (
SELECT
    DISTINCT (country), 
        (CASE WHEN country IN ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus", "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania", "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") THEN "EU" 
         WHEN country IN ("United Kingdom", "Canada", "Australia", "New Zealand") THEN "CANZUK" 
         WHEN country IN ("Japan", "Korea", "Taiwan") THEN "East Asian democracy" 
         WHEN country IN ("Malaysia", "Thailand", "Singapore", "Vietnam", "Indonesia", "Philippines", "Myanmar", "Cambodia", "Laos", "Brunei") THEN "SE Asia" 
         WHEN country IN ("Egypt", "Saudi Arabia", "Turkey", "Iran", "Iraq", "Israel", "Yemen", "Oman", "Syria", "Jordan", "Lebanon", "Kuwait", "Qatar", "United Arab Emirates", "Pakistan") THEN "Middle East" 
         WHEN country IN ("China") THEN "China" 
         WHEN country IN ("United States") THEN "United States" 
         WHEN country IN ("India") THEN "India" 
         ELSE "Other" END) AS country_group
FROM `gcp_cset_links_v2.paper_affiliations_merged` )


SELECT
    YEAR, country, NP, NP_norm, country_group
FROM country_task_counts LEFT JOIN country_groups USING (country)
ORDER BY
    YEAR DESC, country_group ASC, country ASC

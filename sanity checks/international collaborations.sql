--for each country publishing surveillance papers,
--find its intl collaboration rate between 2015-2019
--and its top collaborators

--get surveillance papers
WITH task_term_pairs AS (
    SELECT DISTINCT base_task,
                    raw_task
    FROM surveillance_tasks_brief.task_term_pairs
),

     recent_cv_papers AS (
         SELECT DISTINCT cset_id AS merged_id,
                         meta.year AS YEAR
FROM article_classification.predictions preds
INNER JOIN surveillance_tasks_brief.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN surveillance_tasks_brief.article_merged_meta meta USING (merged_id)

WHERE
    cv_filtered = TRUE
  AND country IS NOT NULL
  AND meta.year >= 2015
  AND meta.year <=2019 ),


--get recent computer vision papers that contain surveillance tasks
    task_papers AS (
SELECT
    merged_id, raw_task, base_task, YEAR
FROM surveillance_tasks_brief.tasks task_data CROSS JOIN UNNEST(spans) AS span INNER JOIN recent_cv_papers USING (merged_id) INNER JOIN task_term_pairs
ON(span = task_term_pairs.raw_task) ),

    --get all papers with at least one surveillance task

surv_papers AS (
SELECT
    DISTINCT merged_id, YEAR
FROM task_papers), 

--generate all non-null countries associated with these articles
surv_countries as (
SELECT DISTINCT merged_id, country 
FROM surv_papers 
INNER JOIN (select DISTINCT merged_id, country from surveillance_tasks_brief.paper_affiliations_merged) USING(merged_id)
WHERE country is NOT NULL
),

--count total papers published per country
country_totals AS(
SELECT country, COUNT(DISTINCT merged_id) as NP_total_nonnorm
FROM surv_countries 
GROUP BY country
),

--count total collaborations per country 
--ie, number of papers published by the country which had authors from another country
overall_collabs AS(
SELECT country,
COUNT(DISTINCT merged_id) as N_collaborative_papers

FROM surv_countries a 
INNER JOIN(SELECT merged_id, country as other_country FROM surv_countries) b USING(merged_id)
WHERE a.country != b.other_country

GROUP BY country
ORDER BY country, N_collaborative_papers DESC
),


--count papers from each pair of countries
country_collab_pairs AS(
SELECT country,
other_country,
COUNT(DISTINCT merged_id) as NP_collab

FROM surv_countries a 
INNER JOIN(SELECT merged_id, country as other_country FROM surv_countries) b USING(merged_id)

WHERE a.country != b.other_country

GROUP BY country, other_country
ORDER BY country, NP_collab DESC
),

--find each country's top collaborator country
--and count all papers from each collaborator
country_stats AS(
SELECT country,
STRING_AGG(other_country ORDER BY NP_collab DESC LIMIT 1) as top_collaborator,
MAX(NP_collab) as top_collaborator_papers,
STRING_AGG(CONCAT(other_country, " (", CAST(NP_collab AS STRING), ")") , ", " ORDER BY NP_collab DESC) as collaborators_w_counts,
FROM country_collab_pairs 
GROUP BY country
)

--collect stats
/*note 1: here NP_total counts all unique papers associated with a country -- not fractional counts. 
note 2: if a paper was a US/UK/Russia collaboration, 
it gets counted once in N_collaborative_papers for the US, although multiple collaborators were involved
in other words, N_collaborative papers <= SUM(NP_collab)
*/
SELECT country, NP_total_nonnorm, N_collaborative_papers, top_collaborator, top_collaborator_papers,
N_collaborative_papers/NP_total_nonnorm as share_of_papers_which_are_collabs,
collaborators_w_counts
FROM country_totals 
LEFT JOIN overall_collabs USING(country) 
LEFT JOIN country_stats USING(country)
ORDER BY NP_total_nonnorm DESC

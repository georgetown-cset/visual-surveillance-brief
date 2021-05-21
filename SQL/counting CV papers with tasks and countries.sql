--find all computer vision papers with at least one affiliated country
WITH cv_papers_w_country AS(
SELECT DISTINCT cset_id as merged_id 
FROM article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged aff ON(preds.cset_id = aff.merged_id)
WHERE country IS NOT NULL
AND cv = TRUE
),

--find all computer vision papers without an affiliated country
cv_papers_no_country AS(
SELECT DISTINCT cset_id as merged_id 
FROM article_classification.predictions preds
WHERE cv = TRUE
AND cset_id NOT IN (SELECT merged_id as cset_id FROM cv_papers_w_country)
),

--merge the two results
cv_papers AS(
SELECT merged_id, 1 as country_status
FROM cv_papers_w_country
UNION ALL
SELECT merged_id, 0 as country_status
FROM cv_papers_no_country
),

--tag all computer vision papers based on whether they have at lesat one task
cv_tagged_papers AS(
SELECT DISTINCT merged_id, year, country_status, (CASE WHEN spans IS NOT NULL THEN 1 ELSE 0 END) as has_task
FROM
cv_papers
LEFT JOIN tasks_and_methods.tasks USING(merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta USING(merged_id)
WHERE 2015 <= year AND year <= 2019
)

--generate year-level statistics -- how many papers have a country, a task, both, or neither?
SELECT year, country_status, has_task, COUNT(DISTINCT merged_id) as cv_papers
FROM cv_tagged_papers
GROUP BY year, country_status, has_task
ORDER BY year DESC, country_status DESC, has_task DESC

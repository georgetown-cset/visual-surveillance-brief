--1. tag computer vision papers based on whether they have an affiliated country
--1a. find all computer vision papers with at least one affiliated country
WITH cv_papers_w_country AS(
SELECT DISTINCT cset_id as merged_id 
FROM article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged aff ON(preds.cset_id = aff.merged_id)
WHERE country IS NOT NULL
AND cv_filtered = TRUE
),

--1b. find all computer vision papers without an affiliated country
cv_papers_no_country AS(
SELECT DISTINCT cset_id as merged_id 
FROM article_classification.predictions preds
WHERE cv = TRUE
AND cset_id NOT IN (SELECT merged_id as cset_id FROM cv_papers_w_country)
),

--1c. merge the two results
cv_papers AS(
SELECT merged_id, 1 as country_status
FROM cv_papers_w_country
UNION ALL
SELECT merged_id, 0 as country_status
FROM cv_papers_no_country
),

--2. tag all computer vision papers based on whether they have at lesat one task
cv_tagged_papers AS(
SELECT DISTINCT merged_id, year, country_status, (CASE WHEN spans IS NOT NULL THEN 1 ELSE 0 END) as has_task
FROM
cv_papers
LEFT JOIN tasks_and_methods.tasks USING(merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta USING(merged_id)
WHERE 2015 <= year AND year <= 2019
),

--3. generate year-level statistics: how many papers have a country, a task, both, or neither?
--3a. count up papers in each category
CV_category_counts AS(
SELECT year, country_status, has_task, COUNT(DISTINCT merged_id) as cv_papers
FROM cv_tagged_papers
GROUP BY year, country_status, has_task
ORDER BY year DESC, country_status DESC, has_task DESC),

--3b. count the overall number of CV papers
CV_total_counts AS (
SELECT year, COUNT(DISTINCT merged_id) as cv_papers_total
FROM cv_tagged_papers
GROUP BY year
ORDER BY year DESC
)

--4. generate and display percentages
SELECT year, country_status, has_task, cv_papers, cv_papers/cv_papers_total as share_of_total
FROM CV_category_counts
INNER JOIN CV_total_counts USING(year)
ORDER BY year DESC, country_status DESC, has_task DESC

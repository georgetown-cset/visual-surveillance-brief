--identify all recent computer vision papers with at least one affiliated country
--note: since we are actually looking for paper - country pairs with a non-null country, this result includes multiple rows for papers with multiple countries
WITH recent_cv_papers AS(
SELECT distinct cset_id as merged_id, meta.year as year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING(merged_id)
WHERE cv = TRUE
AND country IS NOT NULL
AND meta.year >= 2015 AND meta.year <=2019
),

--filter for papers with at least one task tagged
cv_tagged_papers AS(
SELECT merged_id, year
FROM
recent_cv_papers
INNER JOIN tasks_and_methods.tasks USING(merged_id)
WHERE year >= 2015 AND year <= 2019
AND spans is NOT NULL
)

--count distinct papers with both a country and a task, by publication year
SELECT year, COUNT( DISTINCT merged_id) as cv_papers
FROM cv_tagged_papers

GROUP BY year
ORDER BY year DESC

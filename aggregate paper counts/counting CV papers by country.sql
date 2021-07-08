--filter for recent CV papers with a country
WITH recent_cv_papers AS(
SELECT distinct cset_id as merged_id, meta.year as year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING(merged_id)
WHERE cv = TRUE
AND country IS NOT NULL
AND meta.year >= 2015 AND meta.year <=2019
),

--filter for recent CV papers with a country and task
recent_cv_task_papers AS(
SELECT merged_id, year
FROM recent_cv_papers
INNER JOIN tasks_and_methods.tasks USING(merged_id)
WHERE spans IS NOT NULL
),

--count the number of countries for each CV paper
paper_country_counts AS(
SELECT merged_id, COUNT(DISTINCT country) as n_countries
FROM recent_cv_task_papers
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged USING(merged_id)
WHERE country IS NOT NULL
GROUP BY merged_id
),

--for each country, count the total share of CV papers associated with that country
-- -- for a given task and year
-- NP_norm = normalized count (dividing a paper across its contributing countries). This is the figure we use for our comparisons.
-- NP = non-normalized count, multiple-counting a paper for each of its countries. 
country_year_counts AS(
SELECT country, year,
COUNT(DISTINCT merged_id) as NP,
SUM(1./n_countries) as NP_norm
FROM paper_country_counts
INNER JOIN (SELECT DISTINCT merged_id, country FROM gcp_cset_links_v2.paper_affiliations_merged) USING(merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta USING(merged_id)
WHERE country IS NOT NULL
GROUP BY country, year
),


--tag countries by membership in one of several groups
--note: the groups do not overlap. Countries not included in a specific group are tagged with the "Other" group.
country_groups AS (
    SELECT DISTINCT
      (country),
      (CASE
        WHEN country IN
             ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus",
              "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania",
              "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") 
        THEN "EU"
     WHEN country IN ("Norway", "Switzerland", "Liechtenstein", "Iceland")
     THEN "EFTA"
     WHEN country IN ("United Kingdom", "Canada", "Australia", "New Zealand")
     THEN "CANZUK"
     WHEN country IN ("Japan", "Korea", "Taiwan")
     THEN "East Asian democracy" 
     WHEN country IN
             ("Malaysia", "Thailand", "Singapore", "Vietnam", "Indonesia", "Philippines", "Myanmar", "Cambodia", "Laos",
              "Brunei") 
        THEN "SE Asia"
     WHEN country IN
             ("Egypt", "Saudi Arabia", "Turkey", "Iran", "Iraq", "Israel", "Yemen", "Oman", "Syria", "Jordan",
              "Lebanon", "Kuwait", "Qatar", "United Arab Emirates", "Pakistan") 
     THEN "Middle East"
     WHEN country IN("China") THEN "China"
     WHEN country IN("United States") THEN "United States"
     WHEN country IN("India") THEN "India"
     ELSE "Other" 
     END) as country_group
    FROM `gcp_cset_links_v2.affiliations_merged`
  )

--present paper counts by country, year, and task. We tag each country with its group so that we can aggregate country-group level stats in the resulting Google Sheet. 
SELECT year, country, "CV" as category, NP, NP_norm, country_group  
FROM country_year_counts
LEFT JOIN country_groups USING(country)
ORDER BY year DESC, country_group ASC, country ASC

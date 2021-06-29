WITH recent_ai_papers AS(
SELECT distinct cset_id as merged_id, meta.year as year 
from article_classification.predictions preds
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs ON(preds.cset_id = affs.merged_id)
INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING(merged_id)
WHERE (ai_filtered = TRUE OR cv_filtered = TRUE OR robotics_filtered = TRUE or nlp_filtered = TRUE)
AND country IS NOT NULL
AND meta.year >= 2015 AND meta.year <=2019
),

paper_country_counts AS(
SELECT merged_id, COUNT(DISTINCT country) as n_countries
FROM recent_ai_papers
INNER JOIN gcp_cset_links_v2.paper_affiliations_merged USING(merged_id)
WHERE country IS NOT NULL
GROUP BY merged_id
),

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
--note: the groups do not overlap. they also don't cover the full set of countries.
  country_groups AS (
    SELECT DISTINCT
      (country),
      (CASE
        WHEN country IN
             ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus",
              "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania",
              "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") 
        THEN "EU"
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

SELECT year, country, "AI" as category, NP, NP_norm, country_group  
FROM country_year_counts
LEFT JOIN country_groups USING(country)
ORDER BY year DESC, country_group ASC, country ASC

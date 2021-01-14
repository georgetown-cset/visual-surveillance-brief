-- list all CV papers from 2015-19 tagged by James' classifier
WITH cv_papers AS (
  SELECT
    cset_id,
    year
  FROM `gcp-cset-projects.article_classification.predictions_2020_11_30` preds
  WHERE
    cv_filtered = TRUE
    AND year IN (2015, 2016, 2017, 2018, 2019)
),

--count number of associated countries per paper
  country_count AS (
    SELECT
      cset_id,
      count(DISTINCT country) AS n_countries
    FROM cv_papers
    LEFT JOIN gcp_cset_links_v2.paper_affiliations_merged paper_affiliations
    ON (paper_affiliations.merged_id = cv_papers.cset_id)
    GROUP BY
      cset_id
  ),

-- -- check: how many papers are we cutting out by filtering for papers with an affiliated country?
-- SELECT n_countries, COUNT(*)
-- from country_count
-- GROUP BY n_countries
-- no null values; 44k of ~310k papers have no country

-- list article-country pairs
  article_distinct_countries AS (
    SELECT DISTINCT
      cset_id,
      country
    FROM cv_papers
    LEFT JOIN `gcp_cset_links_v2.paper_affiliations_merged` paper_affiliations
    ON (paper_affiliations.merged_id = cv_papers.cset_id)
    WHERE
      country IS NOT NULL
  ),

-- calculate country-year stats
-- we'll primarily use n_cv, which counts a cross-country collaboration as 1/N papers for each of the N collaborating countries
  country_year_stats AS (
    SELECT
      country,
      year,
      count(DISTINCT cset_id) AS np,
      avg(n_countries - 1) AS international_collabs_per_paper,
      sum(1.) AS n_cv_nonnorm,
      sum(1. / n_countries) AS n_cv
    FROM article_distinct_countries
    INNER JOIN country_count USING (cset_id)
    INNER JOIN cv_papers USING (cset_id)
    GROUP BY
      country,
      year
    ORDER BY
      n_cv DESC
  ),

--tag countries based on membership in (disjoint, non-exhaustive) groups
  country_groups AS (
    SELECT DISTINCT
      (country),
      CASE
        WHEN country IN
             ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus",
              "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania",
              "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") THEN 1
        ELSE 0
      END AS eu,
      CASE WHEN country IN ("Norway", "Switzerland", "Liechtenstein", "Iceland") THEN 1 ELSE 0 END AS efta,
      CASE WHEN country IN ("United Kingdom", "Canada", "Australia", "New Zealand") THEN 1 ELSE 0 END AS canzuk,
      CASE WHEN country IN ("Japan", "Korea", "Taiwan") THEN 1 ELSE 0 END AS east_asian_democracy,
      CASE
        WHEN country IN
             ("Malaysia", "Thailand", "Singapore", "Vietnam", "Indonesia", "Philippines", "Myanmar", "Cambodia", "Laos",
              "Brunei") THEN 1
        ELSE 0
      END AS se_asia, --ASEAN members
      CASE
        WHEN country IN
             ("Egypt", "Saudi Arabia", "Turkey", "Iran", "Iraq", "Israel", "Yemen", "Oman", "Syria", "Jordan",
              "Lebanon", "Kuwait", "Qatar", "United Arab Emirates", "Pakistan") THEN 1
        ELSE 0
      END AS middle_east
    FROM `gcp_cset_links_v2.affiliations_merged`
  )

--get all country-year stats (to save to a Google Sheet)
SELECT *
FROM country_year_stats
LEFT JOIN country_groups USING (country)
ORDER BY
  n_cv DESC

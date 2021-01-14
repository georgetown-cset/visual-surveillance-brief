WITH article_distinct_countries AS (
--Find all (article, country) pairs for articles in our 51 clusters of interest
  SELECT DISTINCT
    article_id,
    country
--select articles from the previously generated dataset of papers
  FROM `surveillance_tasks_brief.surveillance_cluster_papers_1119` papers
  LEFT JOIN `gcp_cset_links_v2.paper_affiliations_merged` paper_aff ON (paper_aff.merged_id = papers.article_id)
  WHERE
    country IS NOT NULL
),

--for each country, for each year between 2015-19, aggregate stats for articles affiliated with that country
--for the expected value stats below, we weight a paper by the estimated likelihood that a paper in its cluster is a surveillance paper (cv_surv_fraction_15_19)
--for all stats but exp_surv_nonnorm, we also 'normalize' a paper's contributions to sum to 1, weighting its effect on each affiliated country's stats by 1/n_countries. 
  country_year_stats AS (
    SELECT
      country,
      year,
      count(DISTINCT article_id) AS np,
      avg(n_countries - 1) AS international_collabs_per_paper,
      sum(cv_surv_fraction_15_19) AS exp_surv_nonnorm,
      sum(cv_surv_fraction_15_19 * 1. / n_countries) AS exp_surv,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_facerec) AS exp_facerec,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_gait) AS exp_gait,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_personrec) AS exp_personrec,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_spoof_detection) AS exp_spoof_detection,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_emotionrec) AS exp_emotionrec,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_crowd) AS exp_crowd,
      sum(cv_surv_fraction_15_19 * (1. / n_countries) * p_action) AS exp_action,
    FROM article_distinct_countries
    INNER JOIN `surveillance_tasks_brief.surveillance_cluster_papers_1119` papers USING (article_id)
    WHERE
      year IN (2015, 2016, 2017, 2018, 2019)
      AND n_countries > 0
    GROUP BY
      country,
      year
    ORDER BY
      exp_surv DESC
  ),

--tag countries by membership in one of several groups
--note: the groups do not overlap. they also don't cover the full set of countries.
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

--final result is saved in surv_clusters_task_201119
SELECT *
FROM country_year_stats
LEFT JOIN country_groups USING (country)
ORDER BY
  exp_surv DESC

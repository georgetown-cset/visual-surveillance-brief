WITH 

--Find all (article, country) pairs for articles in our 51 clusters of interest
article_distinct_countries AS(
SELECT article_id, country 
--select articles from the previously generated dataset of papers
FROM `surveillance_tasks_brief.surveillance_cluster_papers_1119` papers
LEFT JOIN `gcp_cset_links_v2.paper_affiliations_merged` paper_aff ON(paper_aff.merged_id = papers.article_id)

WHERE country is not null
GROUP BY article_id, country

),

--for each country, for each year between 2015-19, aggregate stats for articles affiliated with that country
--for the expected value stats below, we weight a paper by the estimated likelihood that a paper in its cluster is a surveillance paper (cv_surv_fraction_15_19)
--for all stats but exp_surv_nonnorm, we also 'normalize' a paper's contributions to sum to 1, weighting its effect on each affiliated country's stats by 1/n_countries. 
country_year_stats AS (SELECT country, year, COUNT(distinct article_id) NP,
AVG(n_countries-1) international_collabs_per_paper, 
SUM(cv_surv_fraction_15_19) exp_surv_nonnorm, 
SUM(cv_surv_fraction_15_19*1./n_countries) exp_surv,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_facerec) exp_facerec,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_gait) exp_gait,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_personrec) exp_personrec,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_spoof_detection) exp_spoof_detection,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_emotionrec) exp_emotionrec,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_crowd) exp_crowd,
SUM(cv_surv_fraction_15_19*(1./n_countries) * p_action) exp_action,

FROM
article_distinct_countries
INNER JOIN `surveillance_tasks_brief.surveillance_cluster_papers_1119` papers USING(article_id)

WHERE year in (2015,2016,2017,2018,2019)

GROUP BY country, year
ORDER BY exp_surv DESC
),


--tag countries by membership in one of several groups
--note: the groups do not overlap. they also don't cover the full set of countries.
country_groups as (
SELECT DISTINCT(country), 

CASE WHEN country IN ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus", "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania", "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") THEN 1 ELSE 0 END EU,
CASE WHEN country IN ("Norway", "Switzerland", "Liechtenstein", "Iceland") THEN 1 ELSE 0 END EFTA,
CASE WHEN country IN ("United Kingdom", "Canada", "Australia", "New Zealand") THEN 1 ELSE 0 END CANZUK,
CASE WHEN country IN ("Japan", "Korea", "Taiwan") THEN 1 ELSE 0 END East_Asian_democracy,
CASE WHEN country IN ("Malaysia", "Thailand", "Singapore", "Vietnam", "Indonesia", "Philippines", "Myanmar", "Cambodia", "Laos", "Brunei") THEN 1 ELSE 0 END SE_Asia, --ASEAN members
CASE WHEN country IN ("Egypt", "Saudi Arabia", "Turkey", "Iran", "Iraq", "Israel", "Yemen", "Oman", "Syria", "Jordan", "Lebanon", "Kuwait", "Qatar", "United Arab Emirates", "Pakistan") THEN 1 ELSE 0 END Middle_East


FROM `gcp_cset_links_v2.affiliations_merged`)


--final result is saved in surv_clusters_task_201119 
SELECT * from country_year_stats
LEFT JOIN country_groups USING(country)
ORDER BY exp_surv DESC
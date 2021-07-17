--get all recent (2011-2019) AI papers
--count up number of papers per salient task per country and year
-- -- normalizing: each paper has weight of 1, spread out across its salient tasks
-- -- and spread out across its contributing countries

--get weights for papers of interest
with 
paper_task_pairs AS(
SELECT merged_id, span as task
    FROM `gcp-cset-projects.tasks_and_methods.salient_tasks`
    CROSS JOIN unnest(spans) as span
),


salient_task_weights AS(
SELECT DISTINCT merged_id, year, field_percentile, 1./N_salient_tasks as task_weight

FROM
(SELECT merged_id, COUNT(span) as N_salient_tasks 
    FROM `gcp-cset-projects.tasks_and_methods.salient_tasks`
    CROSS JOIN unnest(spans) as span

GROUP BY merged_id) task_counts

--get year
INNER JOIN 
(SELECT merged_id, year FROM gcp_cset_links_v2.corpus_merged) USING(merged_id)

--filter for papers w countries
INNER JOIN 
(SELECT DISTINCT merged_id from gcp_cset_links_v2.paper_affiliations_merged WHERE country IS NOT NULL) USING(merged_id)

--get citation percentile
LEFT JOIN
(SELECT merged_id, field_percentile FROM citation_percentiles.citation_percentiles) USING(merged_id)


WHERE year >= 2011 AND year <= 2019
),

--get per-year stats for salient tasks
task_year_counts AS(
SELECT year, span as task, SUM(task_weight) as task_total
FROM `gcp-cset-projects.tasks_and_methods.salient_tasks`
    CROSS JOIN unnest(spans) as span
    INNER JOIN salient_task_weights USING(merged_id)
GROUP BY year, span
),

-- for each salient task, find "year 0": the year it went from <10 to >=10 papers 
-- -- note: this year may not exist, for tasks that were already large.
-- -- note: make sure we deal with NULLs appropriately - going from NULL to >=10 papers also counts
task_y0_unfiltered AS(
SELECT a.year as y0, a.task as task
FROM task_year_counts a
LEFT JOIN task_year_counts b ON(b.year = a.year -1 AND b.task = a.task) 

WHERE
a.task_total >= 10
AND (b.task_total IS NULL OR b.task_total < 10)
),

task_min_after AS(
SELECT task, y0, MIN(task_total) as min_total
FROM task_year_counts
INNER JOIN task_y0_unfiltered USING(task)
WHERE year >= y0

GROUP BY task, y0
),

--filter for the earliest year 0 where, after that year, the task is consistently above 10 papers/year
task_y0 AS(
SELECT task, MIN(y0) as y0
FROM task_y0_unfiltered 
INNER JOIN task_min_after USING(task, y0)
WHERE min_total >= 10
GROUP by task
),


--find paper counts by country for y0, y1
papers_countries AS(
    SELECT DISTINCT merged_id, country
    FROM salient_task_weights
    INNER JOIN paper_task_pairs USING(merged_id)
    INNER JOIN gcp_cset_links_v2.paper_affiliations_merged USING(merged_id)
    INNER JOIN task_y0 USING(task)
),

paper_n_countries AS(
    SELECT merged_id, COUNT(DISTINCT country) as NC
    FROM papers_countries
    GROUP BY merged_id
),

task_country_weights AS(
    SELECT task, country, year, SUM(task_weight * 1./NC) as weight
    FROM paper_n_countries
    INNER JOIN salient_task_weights USING(merged_id)
    INNER JOIN paper_task_pairs USING(merged_id)
    INNER JOIN papers_countries USING(merged_id)
    GROUP BY task, country, year
),

blocs AS(
    SELECT DISTINCT country, 
    (CASE WHEN country IN("China", "United States", "India") THEN country 
    WHEN country IN ("Austria", "Italy", "Belgium", "Latvia", "Bulgaria", "Lithuania", "Croatia", "Luxembourg", "Cyprus", "Malta", "Czechia", "Netherlands", "Denmark", "Poland", "Estonia", "Portugal", "Finland", "Romania", "France", "Slovakia", "Germany", "Slovenia", "Greece", "Spain", "Hungary", "Sweden", "Ireland") THEN "EU" 
    WHEN country IN ("United Kingdom", "Australia", "Canada", "New Zealand") THEN "CANZUK"
    ELSE "Other" END
    ) as country_group
    FROM gcp_cset_links_v2.paper_affiliations_merged
),    

task_bloc_weights AS(
    SELECT task, country_group, year, SUM(weight) as bloc_weight
    FROM task_country_weights
    INNER JOIN blocs USING(country)
    GROUP BY task, country_group, year
),    

--note - we should figure out how to break ties
task_topblocs AS(
    SELECT task, year, STRING_AGG(country_group ORDER BY bloc_weight DESC LIMIT 1) as top_bloc    
    FROM task_bloc_weights
    GROUP BY task, year
),

task_key_info AS(
    SELECT * from task_topblocs 
    INNER JOIN task_y0 USING(task)
    LEFT JOIN
        (SELECT task, task_total as total_2019 FROM task_year_counts WHERE year = 2019) count_2019  USING(task) 

)

SELECT * FROM
    (SELECT task, y0, total_2019, top_bloc as top_bloc_y0 FROM task_key_info WHERE year = y0
    ) 

LEFT JOIN 
    (SELECT task, top_bloc as top_bloc_y1 FROM task_key_info WHERE year = y0+1
    ) USING(task)

LEFT JOIN 
    (SELECT task, top_bloc as top_bloc_y2 FROM task_key_info WHERE year = y0+2
    ) USING(task)


-- note: ideally we do a bunch of case studies to check that the year 1 country continues to dominate. 
--I think Max did some exploration of this when he was looking at this before

--also: maybe this is more meaningful to do with tasks rather than tasks?

--get all papers associated with our 51 clusters of interest
WITH surveillance_cluster_articles as (
SELECT * from 
science_map.dc5_cluster_assignment_stable
INNER JOIN `surveillance_tasks_brief.surv_clusters_top_1119` USING(cluster_id)
ORDER BY cv_surv_fraction_15_19 DESC, cluster_id ),

--count number of organizations and countries affiliated with the paper, based on paper_affiliations_merged
paper_affiliation_counts as (
SELECT merged_id as article_id, COUNT(DISTINCT org_name) as n_orgs, COUNT(DISTINCT country) as n_countries
FROM gcp_cset_links_v2.paper_affiliations_merged affiliations
INNER JOIN surveillance_cluster_articles ON(surveillance_cluster_articles.article_id = affiliations.merged_id)
GROUP BY merged_id),

--get papers' publication year and title from corpus_merged
paper_years AS(
SELECT merged_id as article_id, year, doctype, title_english, title_foreign
FROM gcp_cset_links_v2.corpus_merged corpus_merged
INNER JOIN surveillance_cluster_articles ON(surveillance_cluster_articles.article_id = corpus_merged.merged_id)
)

--collect these stats
--results are saved to surveillance_cluster_papers_201119
SELECT * from
surveillance_cluster_articles
LEFT JOIN paper_affiliation_counts USING(article_id)
LEFT JOIN paper_years USING(article_id)


--this query demonstrates the rough scale of common task areas in computer vision, based on tasks appearing in the top 100 most common CV tasks in 2019. 
--In particular, we can see that visual surveillance of humans is a fairly common task area; aside from very common domain-general tasks (e.g. "classification"), it is the most common.

--select computer vision papers from 2019
WITH cv_papers AS (
    SELECT distinct cset_id as merged_id, meta.year as year
from article_classification.predictions preds
    INNER JOIN gcp_cset_links_v2.paper_affiliations_merged affs
ON(preds.cset_id = affs.merged_id)
    INNER JOIN gcp_cset_links_v2.article_merged_meta meta USING (merged_id)
WHERE cv_filtered = TRUE
  AND country IS NOT NULL
  AND meta.year = 2019
    ),

--tag papers with a common task category ("general", "surveillance", "medical", etc.) if they are tagged with at least one relevant task term
-- -- terms are taken from the top 100 terms, so we are missing some alternative phrasings, e.g. "fer" for facial expression recognition
    CV_paper_tasks AS (
SELECT merged_id,
                            
    MAX (CASE WHEN span in ('classification', 'segmentation', 'detection', 'computer vision', 'image processing', 'object detection', 'recognition', 'feature extraction', 'image segmentation', 'image classification', 'semantic segmentation', 'tracking', 'identification', 'artificial intelligence', 'object recognition', 'prediction', 'machine learning', 'image recognition', 'registration', 'data augmentation', 'reconstruction', 'image analysis', 'training', 'pattern recognition', 'retrieval', 'image retrieval', 'learning', 'optimization', 'localization', 'analysis', 'denoising', 'generalization', 'computer vision tasks', 'clustering', 'machine vision', 'matching', 'inference', 'image denoising', 'object tracking', 'edge detection', 'image enhancement', 'training process', 'image registration', 'change detection', 'visual tracking', 'preprocessing', 'deep learning', '3d reconstruction', 'image fusion', 'computer vision applications', 'image acquisition', 'robotics', 'real-world applications', 'classification task', 'image reconstruction', 'processing', 'image restoration', 'optimization problem', 'ai', 'image captioning', 'classification tasks', 'image preprocessing', 'saliency detection', 'pre-processing', 'manual segmentation', 'validation', 'dr') THEN 1 ELSE 0 END) as general,
    MAX (CASE WHEN span in ('face recognition', 'action recognition', 'face detection', 'facial expression recognition', 'video surveillance', 'security', 'human action recognition', 're-id', 'surveillance') THEN 1 ELSE 0 END) as surveillance,
    MAX (CASE WHEN span in ('diagnosis', 'medical imaging', 'breast cancer', 'medical image analysis', 'diabetic retinopathy', 'fusion', 'medical image segmentation', 'computer-aided diagnosis', 'treatment') THEN 1 ELSE 0 END) as medical,
    MAX (CASE WHEN span in ('remote sensing', 'sar', 'target detection', 'remote sensing images') THEN 1 ELSE 0 END) as remote_sensing,
    MAX (CASE WHEN span in ('autonomous driving', 'autonomous vehicles') THEN 1 ELSE 0 END) as autonomous_vehicles,
    MAX (CASE WHEN span in ('sr', 'pose estimation', 'hyperspectral image classification', 'super-resolution', 'pedestrian detection', 'agriculture', 'image super-resolution', 'depth estimation') THEN 1 ELSE 0 END) as other

FROM tasks_and_methods.tasks task_data
    CROSS JOIN UNNEST(spans) as span
    INNER JOIN cv_papers USING (merged_id)

GROUP BY merged_id
    ),

--for each category, count the 2019 CV papers in which a relevant term appears 
    category_counts AS (
SELECT
    SUM (general) as general,
    SUM (surveillance) as surveillance,
    SUM (medical) as medical,
    SUM (remote_sensing) as remote_sensing,
    SUM (autonomous_vehicles) as autonomous_vehicles,
    SUM (other) as other
FROM CV_paper_tasks)


SELECT *
from category_counts

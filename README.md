# The project
This is a repo for the visual surveillance data brief written by Max L, Ashwin A, and James D in late 2020 for publication early 2021.

# Our process


## Data processing: Extracting tasks from computer vision papers (Python)
* We took a source set of computer vision papers published between 2015 and 2019 *TBD - confirm this* from the Microsoft Academic Graph database.
    * We identified these papers as computer vision using CSET’s ArXiv-trained AI paper classifier, requiring an estimated probability of >X% computer vision *TBD*. For more information on this classifier, see https://arxiv.org/abs/2002.07143  
* We used the tasks and methods tagging system described in https://github.com/georgetown-cset/task-and-method-annotation to extract a list of tasks for these computer vision articles. 
    * For more information on this process, see the upcoming Technical Supplement. *TBD*

## Analytic decision-making: Finding tasks of interest within computer vision (Python)
We found that computer vision research was distributed over a wide range of tasks. Table X reports the top 10 most popular computer vision tasks worldwide from 2015-19, and the proportion of computer vision papers tagged with each task.

<details> <summary> Table X: Face recognition and action recognition are among the most popular computer vision tasks </summary>

![Table X](https://github.com/aa2291/visual-surveillance-brief/blob/adding-appendix-content-to-readme/readme%20images/table%20x.png)

Source: Microsoft Academic Graph; CSET analysis. Results generated December 18, 2020.
</details>



It appears that these tasks are quite granular compared to computer vision as a whole. Even the most popular task, object detection, appeared in less than 4% of computer vision papers. Most of these common computer vision tasks are general purpose, with relevance to a very wide range of computer vision applications. These tasks include object detection, image classification, denoising, image retrieval, object recognition, semantic segmentation, and super-resolution. Meanwhile, face recognition, pose estimation, and action recognition are more domain-specific. Of these three more applied tasks, face recognition and action recognition can be used in visual surveillance applications. 

We also looked for tasks which attracted unusually high interest in the United States compared to China, and vice-versa. Since China publishes more computer vision papers than the U.S., we looked for tasks which made up a higher percentage of U.S. than Chinese computer vision papers, and vice-versa. As with the list of most common tasks, we found a large number of general-purpose tasks, as well as a few domain-specific tasks. Several of these domain-specific tasks— “activity recognition” for the U.S. and “face recognition” and “person re-identification” for China— were relevant to visual surveillance. The tasks more popular in China also included “visual tracking” and “object tracking”, or the tracking of objects in video feeds. While less specific to surveilling humans, these tasks can be used in visual surveillance systems.


<details> <summary> Table Y: Computer vision tasks that get disproportionate research focus from the US relative to China include activity recognition </summary>

![Table Y](https://github.com/aa2291/visual-surveillance-brief/blob/adding-appendix-content-to-readme/readme%20images/table%20y.png)

Source: Microsoft Academic Graph; CSET analysis. Results generated December 18, 2020.
</details>


<details> <summary> Table Z: Computer vision tasks that get disproportionate research focus from China include face recognition and person re-identification </summary>
   
![Table Z](https://github.com/aa2291/visual-surveillance-brief/blob/adding-appendix-content-to-readme/readme%20images/table%20z.png)

Source: Microsoft Academic Graph; CSET analysis. Results generated December 18, 2020.
</details>


## Identifying papers with surveillance tasks
### Analytic decision-making: identifying families of surveillance-relevant tasks
First, we looked through all the tasks on the PapersWithCode website, and the papers associated with those tasks. We then grouped certain synonymous tasks in the same category, identified potential synonyms or overlapping tasks by their high likelihood of co-occurring with our terms of interest, and caught variations on the same task using regular expression search terms.

For each surveillance task, we looked for occurrences of the following corresponding phrases:

* Face recognition: “face detection," “facial detection," “face recognition," and “facial recognition.”
* Person identification: “person re-identification," “person identification," “person recognition," “person retrieval," and “person search.”
* Crowd surveillance: “crowd counting.”
* Gait recognition: “gait recognition," "gait identification," and “gait-based person re-identification.”
* Emotion recognition: “emotion recognition” and “expression recognition.”
* Action recognition: “activity recognition," “action recognition," and “human interaction recognition.”
* Spoof detection: “spoof detection," “presentation attack detection," “face anti-spoofing," “facial anti-spoofing," and “face liveness detection.”

### Data processing
* The above process is enacted in tagging papers as surveillance.ipynb
    * We have a dictionary where each of these task areas is associated with a list of regular expressions
    * For each paper in our pipeline, we counted how many of its tasks matched face recognition terms, how many matched emotion recognition terms, etc.
* We also checked that our dictionaries weren't missing associated tasks, by checking for tasks that often occur in the same paper as our regex terms
* We saved the resulting list of surveillance-task-flagged papers in a csv, which has been uploaded to CSET’s BigQuery database as surveillance_tasks_brief.surveillance_task_articles_1109_maxdict

## Analytic decision-making: Identifying surveillance-relevant research clusters
We extended our analysis to the full CSET database of papers from MAG, Dimensions, the Web of Science Core Collection (WOS), and the China National Knowledge Infrastructure (CNKI) by identifying the clusters of research papers most likely to contain visual surveillance papers. 
   
Our research clusters are non-overlapping sets of papers, usually between several hundred and several thousand publications. [1] We identified 51 clusters of research papers which met the following criteria: they contained more than 30 MAG computer vision papers, of which more than 50% were tagged by our system as papers with surveillance tasks. (In other words, we  estimated the proportion of papers with surveillance-relevant tasks in these clusters was greater than 50%.) We excluded from analysis clusters with very few computer vision papers because they could have high proportions but small numbers of surveillance-relevant computer vision papers. We chose the 50% cutoff after examining random samples of 50 papers each from various clusters. We found that clusters with a greater than 50% estimated proportion of surveillance were reliably surveillance-focused, while clusters with 40% or 30% estimated demonstrated a sharp dropoff in the number of surveillance papers. 

Our task-tagging method has limited precision and recall, and is restricted to papers with English-language abstracts. Identifying surveillance-heavy research clusters allowed us to capture an expanded set of papers that was more reliably surveillance-focused and was not restricted to English-language papers. We further restricted our count to surveillance papers only by weighting each paper by the proportion of task-tagged papers in its cluster which were tagged with surveillance tasks. As a result, our method likely undercounts the number of surveillance papers by restricting to surveillance-weighted papers within our 51 clusters of interest. </details>

## Data processing: Finding papers in surveillance-heavy clusters (BigQuery)
* Using CSET’s science_map dataset, we identified 1769 DC5 clusters containing our ~17000 surveillance-tagged seed papers
* We restricted our analysis to 51 clusters which contain at least 30 pipeline papers, of which at least 50% were tagged with a surveillance task
    * ~9000 of our seed papers are contained in these clusters
* We computed stats for the papers in these 51 clusters, focusing on papers from 2015-2019
* We aggregated these statistics based on paper affiliations to get country-level statistics by year. (See below for a description of how we attributed papers to countries.)

## Analytic decision-making: Attributing computer vision papers to countries
For each paper, we identified the institutions associated with its authors at the time of publication, as reported in the paper itself. We used those institutions to generate a list of countries associated with the paper. If the paper was associated with more than one country, we counted it as a fraction of a paper for each of those countries. For example, if a paper's authors came from Stanford University in the U.S. and Oxford University in the U.K., we counted it as half a paper for each country. 

We did so regardless of the number of institutions per country. For example, if a paper’s authors were associated with one US institution and three UK institutions, we still counted it as half a paper for each country. We chose to do this because our database of institutions is often redundant, counting “Oxford University” and “University of Oxford” as separate entities associated with a paper.

Our process may undercount visual surveillance research from countries with small, insular, and/or non-English-speaking research communities. Our initial set of visual surveillance papers is identified by an algorithm that was trained on English-language ArXiv preprints, and therefore only works on papers with English-language abstracts. Our final set of papers comes from identifying research clusters which contain at least 30 papers parseable by our algorithm, of which at least 50% were tagged with visual surveillance tasks. These clusters are defined as sets of papers which tend to cite one another. Therefore, we may miss research clusters which focus on visual surveillance but do not tend to cite or be cited by the English-language literature on the subject. 

In addition, our combined corpus (which combines data from Dimensions, Microsoft Academic Graph, Web of Science, and the Chinese National Knowledge Infrastructure) is likely to capture well-known research from countries that are integrated with the international research community, as well as Chinese research via CNKI. It may be more likely to exclude research from countries with small, little-known, or secretive research communities. </details>

## Data processing: Google Sheets surveillance analysis
* We then analyzed the country-year stats in Google Sheets. https://docs.google.com/spreadsheets/d/1208sb0o4eD8lY98pPUNn33_3dwFkBqg-1qZL9cZyBJQ/edit#gid=663614057
* We created pivot tables to analyze the country-level surveillance results, looking at tasks over time, countries over time, and countries by task.

## Data processing: Calculating total computer vision numbers, and comparing with surveillance
* We identified computer vision papers in CSET’s combined corpus using the classifier trained on ArXiv preprints. The resulting corpus included about 310,000 papers published between 2015-2019 which were identified as computer vision. Of these, 262,762 had at least one associated author affiliation country. For this report we restricted our analysis to the latter set of papers.

* We used the same country-attribution methods described above to calculate the number of overall computer vision papers per country by year.
 
* We saved the computer vision country-year stats, and a copy of the surveillance country-year stats, in a Google Sheet: https://docs.google.com/spreadsheets/d/1owkiWTt5N5SNMBw4PnaocaWAlGWBwzfxdP1oPgvgpBc/edit#gid=1011004304

* We made pivot tables to list computer vision publication stats by country and year
    * This lets us calculate the growth rate of computer vision research
    * We took the ratio of surveillance country-year publication counts to computer vision country-year counts to calculate countries' focus on surveillance research over time


[1] For more information on research clusters, see Klavans, Richard, Kevin W. Boyack, and Dewey A. Murdick. "A novel approach to predicting exceptional growth in research." PLOS ONE 15, no. 9 (2020): e0239177.



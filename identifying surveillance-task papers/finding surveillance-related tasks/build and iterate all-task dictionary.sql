--create a table of the surveillance task terms we found in the top-50 task lists 
--associate together the terms that correspond to the same broader task
CREATE TABLE surveillance_tasks_brief.task_term_pairs
(
    base_task STRING,
    raw_task    STRING,
    round       INT64
);
INSERT INTO surveillance_tasks_brief.task_term_pairs (base_task, raw_task, round)
VALUES ("face recognition", "face recognition", 1),
       ("face recognition", "face detection", 1),
       ("person re-identification", "person re-identification", 1),
       ("person re-identification", "reid", 1),
       ("facial expression recognition", "facial expression recognition", 1),
       ("action recognition", "action recognition", 1),
       ("face anti-spoofing", "face anti-spoofing", 1),
       ("crowd counting", "crowd density estimation", 1);

INSERT INTO surveillance_tasks_brief.task_term_pairs (base_task, raw_task, round)
VALUES ("action recognition", "human action recognition", 2),
       ("action recognition", "action classification", 2),
       ("crowd counting", "crowd counting", 2),
       ("crowd counting", "crowd analysis", 2),
       ("crowd counting", "crowd count", 2),
       ("crowd counting", "crowd density", 2),
       ("crowd counting", "crowd scene understanding", 2),
       ("crowd counting", "crowd behavior recognition", 2),
       ("face anti-spoofing", "face liveness detection", 2),
       ("face anti-spoofing", "face spoofing attacks", 2),
       ("face anti-spoofing", "face spoofing", 2),
       ("face anti-spoofing", "face presentation attacks", 2),
       ("face anti-spoofing", "face antispoofing", 2),
       ("facial expression recognition", "facial emotion recognition", 2),
       ("facial expression recognition", "fer", 2),
       ("facial expression recognition", "facial expression analysis", 2),
       ("person re-identification", "re-id", 2),
       ("person re-identification", "person reidentification", 2);

INSERT INTO surveillance_tasks_brief.task_term_pairs (base_task, raw_task, round)
VALUES ("action recognition", "human activity recognition", 3),
       ("action recognition", "har", 3),
       ("crowd counting", "people counting", 3),
       ("crowd counting", "crowd behavior analysis", 3),
       ("crowd counting", "counting people", 3),
       ("face anti-spoofing", "face spoofing detection", 3),
       ("face anti-spoofing", "face presentation attack detection", 3),
       ("facial expression recognition", "expression recognition", 3),
       ("facial expression recognition", "emotion recognition", 3),
       ("person re-identification", "person detection", 3);

INSERT INTO surveillance_tasks_brief.task_term_pairs (base_task, raw_task, round)
VALUES ("action recognition", "activity recognition", 4),
       ("crowd counting", "crowded scenes", 4),
       ("crowd counting", "people tracking", 4);

  
  
  
  
  
  
  
  
  
  
  


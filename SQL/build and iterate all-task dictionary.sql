--create a table of the surveillance task terms we found in the top-50 task lists 
--associate together the terms that correspond to the same broader task
CREATE TABLE surveillance_tasks_brief.task_parent_pairs_alltask (parent_task STRING, raw_task STRING, round INT64);
INSERT INTO surveillance_tasks_brief.task_parent_pairs_alltask (parent_task, raw_task, round)
VALUES 
  ("face recognition", "face recognition", 1),
  ("face recognition", "face detection", 1),
  ("person re-identification", "person re-identification", 1),
  ("person re-identification", "reid", 1),
  ("facial expression recognition", "facial expression recognition", 1),
  ("action recognition", "action recognition", 1),
  ("face anti-spoofing", "face anti-spoofing", 1),
  ("crowd counting", "crowd density estimation", 1);
  
-- add in tasks that we find via their overlap with the above task groups
-- iterate until there are no more relevant overlapping tasks to add

INSERT INTO surveillance_tasks_brief.task_parent_pairs_alltask (parent_task, raw_task, round)
VALUES 
  ("action recognition", "human action recognition", 2),
  ("action recognition", "action classification", 2),
  ("crowd counting", "dense crowd counting", 2),
  ("crowd counting", "crowd behavior recognition", 2),
  ("crowd counting", "analyzing crowd behavior", 2),
  ("crowd counting", "crowd scene analysis", 2),
  ("crowd counting", "counting people in crowded scenes", 2),
  ("face anti-spoofing", "face spoofing detection", 2),
  ("face anti-spoofing", "face spoofing attacks", 2),
  ("face anti-spoofing", "face spoofing detection", 2),
  ("face anti-spoofing", "face spoofing", 2),
  ("face anti-spoofing", "face presentation attacks", 2),
  ("face anti-spoofing", "face antispoofing", 2),
  ("facial expression recognition", "fer", 2),
  ("facial expression recognition", "expression recognition", 2),
  ("facial expression recognition", "facial expression analysis", 2),
  ("person re-identification", "re-id", 2),
  ("person re-identification", "re-identification", 2),
  ("person re-identification", "person reidentification", 2)
  ;

--others of interest:
--crowd counting: surveillance camera system
--person re-identification: 
      --intelligent video surveillance 
      -- public security
  
  
INSERT INTO surveillance_tasks_brief.task_parent_pairs_alltask (parent_task, raw_task, round)
VALUES 
  ("action recognition",	"har", 3),
("crowd counting",	"crowd analysis", 3),
("crowd counting",	"crowd density", 3),
('crowd counting', 'crowd monitoring', 3),
('crowd counting', 'crowd detection', 3),
('crowd counting', 'crowd count', 3),
('crowd counting', 'crowd scene understanding', 3),
('crowd counting', 'estimation of crowd density', 3),
('crowd counting', 'abnormal crowd detection', 3),
('crowd counting', 'anomaly detection in crowded scenes', 3),
('face anti-spoofing', 'face liveness detection', 3),
('face anti-spoofing', 'face presentation attack detection', 3),
('facial expression recognition', 'emotion recognition', 3),
('facial expression recognition', 'facial expression', 3),
('facial expression recognition', 'facial emotion recognition', 3);


INSERT INTO surveillance_tasks_brief.task_parent_pairs_alltask (parent_task, raw_task, round)
VALUES 
  ("crowd counting",	"crowd counting", 4);

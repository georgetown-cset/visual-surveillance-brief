--create a table of the surveillance task terms we found in the top-50 task lists 
--associate together the terms that correspond to the same broader task
CREATE TABLE surveillance_tasks_brief.task_parent_pairs_alt (parent_task STRING, raw_task STRING, round INT64);
INSERT INTO surveillance_tasks_brief.task_parent_pairs_alt (parent_task, raw_task, round)
VALUES 
  ("face recognition", "face recognition", 1),
  ("face recognition", "face detection", 1),
  ("person re-identification", "person re-identification", 1),
  ("person re-identification", "reid", 1),
  ("facial expression recognition", "facial expression recognition", 1),
  ("action recognition", "action recognition", 1),
  ("action recognition", "human action recognition", 1),
  ("action recognition", "skeleton-based action recognition", 1),
  ("action recognition", "human activity recognition", 1),
  ("face anti-spoofing", "face anti-spoofing", 1),
  ("crowd counting", "crowd counting", 1);



--add in tasks that we find via their overlap with the above task groups
--iterate until there are no more relevant overlapping tasks to add

INSERT INTO surveillance_tasks_brief.task_parent_pairs_alt (parent_task, raw_task, round)
VALUES 
  ("action recognition", "activity recognition", 2),
  ("crowd counting", "crowd density estimation", 2),
  ("face anti-spoofing", "face spoofing detection", 2),
  ("face anti-spoofing", "face spoofing attacks", 2),
  ("face anti-spoofing", "face spoofing attack", 2),
  ("face anti-spoofing", "face spoofing", 2),
  ("face anti-spoofing", "face antispoofing", 2),
  ("face anti-spoofing", "face presentation attacks", 2),
  ("face anti-spoofing", "face spoofing detection", 2),
  ("facial expression recognition", "fer", 2), 
  ("facial expression recognition", "facial emotion recognition", 2),  
  ("facial expression recognition", "expression recognition", 2),  
  ("facial expression recognition", "facial expression analysis", 2),  
  ("person re-identification", "re-id", 2);
  

  
INSERT INTO surveillance_tasks_brief.task_parent_pairs_alt (parent_task, raw_task, round)
VALUES 
  ("face anti-spoofing", "face liveness detection", 3),
  ("face anti-spoofing", "face presentation attack detection", 3),
  ("facial expression recognition", "emotion recognition", 3);  

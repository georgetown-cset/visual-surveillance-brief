--create a table of the surveillance task terms we found in the top-50 task lists 
--associate together the terms that correspond to the same broader task
CREATE TABLE surveillance_tasks_brief.task_dictionary (task_family STRING, raw_tasks ARRAY <STRING>);
INSERT INTO surveillance_tasks_brief.task_dictionary (task_family, raw_tasks)
VALUES 
  ("face recognition", ["face recognition", "face detection"]),
  ("person re-identification", ["person re-identification", "reid"]),
  ("facial expression recognition", ["facial expression recognition"]),
  ("action recognition", ["action recognition", "human action recognition", "skeleton-based action recognition", "human activity recognition"]),
  ("face anti-spoofing", ["face anti-spoofing"]),
  ("crowd counting", ["crowd counting"]);

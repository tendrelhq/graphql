begin
;

-- Create a 'Trackable' type tag.
select *
from util.create_type('Trackable', 'Template Type', 895)
;

-- Create an 'Runtime' type tag.
select *
from util.create_type('Runtime', 'Template Type', 895)
;

-- Create an 'Idle Time' type tag.
select *
from util.create_type('Idle Time', 'Template Type', 895)
;

-- Create a 'Downtime' type tag.
select *
from util.create_type('Downtime', 'Template Type', 895)
;

commit
;

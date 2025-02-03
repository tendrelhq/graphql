begin
;

-- Create an 'Runtime' type tag.
select *
from util.create_type('Runtime', 895)
;

-- Create an 'Idle Time' type tag.
select *
from util.create_type('Idle Time', 895)
;

-- Create a 'Downtime' type tag.
select *
from util.create_type('Downtime', 895)
;

commit
;

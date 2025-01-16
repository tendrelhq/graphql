begin
;

-- Create an 'Runtime' type tag.
select *
from util.create_type('Runtime')
;

-- Create an 'Idle Time' type tag.
select *
from util.create_type('Idle Time')
;

-- Create a 'Downtime' type tag.
select *
from util.create_type('Downtime')
;

commit
;

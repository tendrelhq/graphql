# Runtime

## Setup

```sql
-- $1 is your workerinstanceid -> modifiedby
begin
;

-- Create an 'Runtime' type tag.
select *
from ast.create_system_type('Runtime', 'Template Type', $1)
;

-- Create an 'Idle Time' type tag.
select *
from ast.create_system_type('Idle Time', 'Template Type', $1)
;

-- Create a 'Downtime' type tag.
select *
from ast.create_system_type('Downtime', 'Template Type', $1)
;

commit
;
```

## Create a demo customer

```sql
begin
;

select *
from
    runtime.create_demo(
        customer_name := 'Frozen Tendy Factory',
        admins := array[
            'worker_d3ebf472-606c-4d26-9a19-d99f187e9c92',
            'worker_a5d1d16f-4264-45e7-97c6-1ef534b8875f'
        ],
        modified_by := 895
    )
;

commit
;
```

begin
;

update public.systag
set systagparentid = 882, -- 'Template Type'
    systagmodifieddate = now(),
    systagmodifiedby = 895 -- rugg
where
    systagparentid = 1
    and systagtype in ('Trackable', 'Runtime', 'Idle Time', 'Downtime')
;

commit
;

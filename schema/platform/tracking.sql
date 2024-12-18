select wt.id, wtts.systagtype as group
-- sum(
-- extract(epoch from (wi.workinstancecompleteddate - wi.workinstancestartdate))
-- ) as value
from public.worktemplate as wt
inner join
    public.worktemplatetype as wtt on wt.id = wtt.worktemplatetypeworktemplateuuid
inner join public.systag as wtts on wtt.worktemplatetypesystaguuid = wtts.systaguuid
-- inner join
-- public.workinstance as wi
-- on wt.worktemplateid = wi.workinstanceworktemplateid
-- and wi.workinstancestartdate is not null
-- and wi.workinstancecompleteddate is not null
where
    wtts.systagtype in ('Production', 'Planned Downtime', 'Unplanned Downtime')
    and wt.worktemplatecustomerid = 99
;

-- this sql grabs all of the chains for the given worktemplate.
-- note that this is irrespective of location, which is what we want for the
-- history screen (although we do eventually want the ability to filter by location).
select
    encode(('workinstance:' || chain.id)::bytea, 'base64') as id,
    extract(
        epoch from chain.workinstancecompleteddate - chain.workinstancestartdate
    ) as dt
from public.worktemplate as parent
inner join
    public.worktemplatetype as wtt on parent.id = wtt.worktemplatetypeworktemplateuuid
inner join public.systag as tag on wtt.worktemplatetypesystaguuid = tag.systaguuid
inner join
    public.workinstance as chain
    on parent.worktemplateid = chain.workinstanceworktemplateid
    and chain.workinstanceid = chain.workinstanceoriginatorworkinstanceid
-- fixme; to filter by location we need to join in workresultinstance here
where
    -- fixme; temporary during development
    parent.worktemplatecustomerid = 99
    -- this is the 'Production' template, the "root"
    -- parent.id = 'work-template_1bf31cd5-8fc2-47b1-a28f-e4bc5513e028'
    and tag.systagtype in ('Trackable')
    and chain.workinstancecompleteddate is not null
order by chain.workinstancecompleteddate desc
;


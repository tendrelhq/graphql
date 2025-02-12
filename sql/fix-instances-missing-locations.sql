select
    workinstancecustomerid,
    workinstanceworktemplateid,
    workinstanceid,
    workinstancepreviousid,
    workresultinstanceid,
    workresultinstancevalue
from public.workinstance
inner join
    public.workresultinstance on workinstanceid = workresultinstanceworkinstanceid
inner join
    public.workresult
    on workresultinstanceworkresultid = workresultid
    and workresultentitytypeid = 852
where
    exists (
        select 1
        from public.worktemplatetype
        inner join
            public.systag
            on worktemplatetypesystagid = systagid
            and systagtype in ('Trackable', 'Idle Time', 'Downtime')
        where worktemplatetypeworktemplateid = workinstanceworktemplateid
    )
    and workresultinstancevalue is null
order by workinstancepreviousid
;

-- fmt: off
with
    cte as (
        select workresultinstanceid, workinstancepreviousid
        from public.workinstance
        inner join
            public.workresultinstance
            on workinstanceid = workresultinstanceworkinstanceid
        inner join
            public.workresult
            on workresultinstanceworkresultid = workresultid
            and workresultentitytypeid = 852
        where
            exists (
                select 1
                from public.worktemplatetype
                inner join
                    public.systag
                    on worktemplatetypesystagid = systagid
                    and systagtype in ('Trackable', 'Idle Time', 'Downtime')
                where worktemplatetypeworktemplateid = workinstanceworktemplateid
            )
            and workresultinstancevalue is null
    ),

    cte2 as (
        select cte.workresultinstanceid, wri.workresultinstancevalue
        from cte
        inner join
            public.workinstance as p on cte.workinstancepreviousid = p.workinstanceid
        inner join
            public.workresultinstance as wri
            on p.workinstanceid = wri.workresultinstanceworkinstanceid
        inner join
            public.workresult
            on wri.workresultinstanceworkresultid = workresultid
            and workresultentitytypeid = 852
    )

update public.workresultinstance as t
set workresultinstancevalue = cte2.workresultinstancevalue
from cte2
where t.workresultinstanceid = cte2.workresultinstanceid
returning t.workresultinstanceid, t.workresultinstancevalue
;
-- fmt: on

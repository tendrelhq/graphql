# Yield and/or MFT and/or ...?

## to track or not to track?

Locations and Tasks can be opted into "tracking" by "tagging" them as such. In
the Location case, `locationcategoryid` must be a sub-type of a 'Trackable'
systag. In the Task case, the same 'Trackable' systag must be exist as a
`worktemplatetype` for the given Task. The following sql ties the two together,
via `worktemplateconstraint`;

```sql
-- Given a location id in $1, find all "trackable" worktemplates at that location.
with
    location_type as (
        select c.custaguuid as user_type, s.systaguuid as sys_type
        from public.location as l
        inner join public.custag as c on l.locationcategoryid = c.custagid
        inner join public.systag as s on c.custagsystagid = s.systagid
        where l.locationuuid = $1 and s.systagtype = 'Trackable'
    )

select encode(('worktemplate:' || wt.id)::bytea, 'base64') AS id
from location_type as lt
inner join
    public.worktemplateconstraint as wtc
    on lt.user_type = wtc.worktemplateconstraintconstraintid
    and lt.sys_type = wtc.worktemplateconstraintconstrainedtypeid
inner join public.worktemplate as wt on wtc.worktemplateconstrainttemplateid = wt.id
;
```

## task as a state machine

`worktemplatenexttemplate` rules can be used to build "state machines", which
end up dictating how the user interacts with the client application. The Task
tagged as 'Trackable' is the "entrypoint", i.e. it is the only valid
"transition" when first starting a run, i.e. "Start Run" (from the mocks). From
there, next templates dictate that "Idle Time" and "Downtime" are the only valid
"transitions" when in "Runtime" (again from the mocks). So, based on the mocks,
the only next-template rules that exist are the following;

- previous: Run, next: Idle Time
- previous: Run, next: Downtime

IMPORTANT! transitioning does NOT end the currently active task. It simply makes
the next task the active task. For example, from the moment you "Start Run"
until the moment you "End Run", Run is in progress, even if you enter "Idle
Time" or "Downtime" (any number of times) in between. **The only way to end a
task is to hit the end button**.

Anyways... more sql;

```sql
-- compute the state machine for the task id in $1.
with recursive
    chain as (
        select *
        from public.workinstance
        where
            workinstanceworktemplateid in (
                select wt.worktemplateid from public.worktemplate as wt where wt.id = $1
            )
            and workinstancestatusid in (
                select s.systagid
                from public.systag as s
                where s.systagparentid = 705 and s.systagtype in ('Open', 'In Progress')
            )
        union all
        select wi.*
        from chain, public.workinstance as wi
        where chain.workinstanceid = wi.workinstancepreviousid
    ),

    active as (
        select
            chain.workinstanceworktemplateid as _template,
            encode(('workinstance:' || chain.id)::bytea, 'base64') as id
        from chain
        inner join public.systag on chain.workinstancestatusid = systag.systagid
        where systag.systagtype = 'In Progress'
        order by chain.workinstancepreviousid desc nulls last
    ),

    transition as (
        select encode(('worktemplate:' || wt.id)::bytea, 'base64') as id
        from public.worktemplatenexttemplate as nt
        inner join
            public.worktemplate as wt
            on nt.worktemplatenexttemplatenexttemplateid = wt.worktemplateid
        where
            exists (
                select 1
                from active
                where active._template = nt.worktemplatenexttemplateprevioustemplateid
            )
            and nt.worktemplatenexttemplateviaworkresultid is null
    )

select active.id as active, array_remove(array_agg(transition.id), null) as transitions
from active
left join transition on true
group by active.id
;
```

This behaves like a stack. The "active" task is the most recently In Progress
task. Transitions are next-template rules whose _previous_ is the active task.
At each step, the client can choose to act on _either_ the active task or a
valid transition. Acting on the active task conceptually maps to either "start
task" or "end task" (depending on what state the active task is in). _Ending the
active task_ will effectively pop that task from the stack and land you back in
whatever was previously the active task, if any.

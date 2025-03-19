-- Deploy graphql:002-engine to pg
begin
;

create schema engine0;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema engine0 from graphql;
    grant usage on schema engine0 to graphql;
    alter default privileges in schema engine0 grant execute on routines to graphql;
  end if;
end $$;

create or replace function engine0.execute(task_id text, modified_by bigint)
returns table(instance text)
as $$
begin
  return query
    with
        stage1 as (
            select p0.*
            from
                engine0.build_instantiation_plan(task_id) as p0,
                engine0.evaluate_instantiation_plan(
                    target := p0.target,
                    target_type := p0.target_type,
                    conditions := p0.ops
                ) as p1
            where p1.result = true
        ),

        -- FIXME: we shouldn't need to do this per se. Really we need to replace
        -- engine0.instantiate with a better procedure, one that takes uuids
        -- instead of typenames.
        stage2 as (
            select distinct
                s1.target,
                s1.target_parent,
                ts.systagtype as target_state,
                tt.systagtype as target_type
            from stage1 s1
            inner join public.systag as ts
                -- FIXME: this should be configurable. For now our goal is 1:1
                -- parity with the existing rules engine; this is the implicit
                -- configuration for that system at the moment.
                on ts.systagparentid = 705 and ts.systagtype = 'Open'
            inner join public.systag as tt
                on s1.target_type = tt.systaguuid
            where s1.i_mode = 'eager'
        ),

        stage3 as (
            select i.*
            from stage2 s2, engine0.instantiate(
                template_id := s2.target,
                location_id := s2.target_parent,
                target_state := s2.target_state,
                target_type := s2.target_type,
                chain_prev_id := task_id,
                modified_by := modified_by
            ) i
        )

    select s3.instance
    from stage3 s3
    group by s3.instance
  ;

  return;
end $$
language plpgsql
strict
;

comment on function engine0.execute is $$

# engine0.execute

$$;

create type engine0.closure as (
    f regproc,
    ctx jsonb
);

comment on type engine0.closure is $$

# engine0.closure

A "closure" encapsulates both a procedure, via `f`, as well as the arguments
that we intend to invoke it with, via `ctx`.

$$;

create or replace function engine0.invoke(x engine0.closure)
returns setof record
as $$
begin
  return query execute format('select * from %s($1)', x.f) using x.ctx;
end $$
language plpgsql
strict
;

-- fmt: off
create or replace function engine0.build_instantiation_plan(task_id text)
returns
    table(
        count bigint,
        ops engine0.closure[],
        i_mode text,
        target text,
        target_parent text,
        target_type text
    )
as $$
begin
  return query
    with
        root as (
            select
                i.*,
                (
                    select locationuuid
                    from public.location
                    where locationid = parent.workresultinstancevalue::bigint
                ) as parent_id
            from public.workinstance as i
            inner join public.workresultinstance as parent
                on i.workinstanceid = parent.workresultinstanceworkinstanceid
            inner join public.workresult as parent_t
                on i.workinstanceworktemplateid = parent_t.workresultworktemplateid
                and parent.workresultinstanceworkresultid = parent_t.workresultid
                and parent_t.workresulttypeid = 848
                and parent_t.workresultentitytypeid = 852
                and parent_t.workresultisprimary = true
            where i.id = task_id
        ),

        dst as (
            -- instantiation rules; prev != next
            select
                -- 'On Demand' implies lazy instantiation, everything else is eager
                case when t.systagtype = 'On Demand' then 'lazy'
                     else 'eager'
                end as i_mode,
                nt.worktemplatenexttemplateid as _id,
                root.id as task,
                root.parent_id as task_parent,
                n.id as next_task_id,
                f.id as curr_field_id,
                f_op.systaguuid as curr_field_op_id,
                s.systaguuid as curr_state_id,
                t.systaguuid as next_type_id
            from root
            inner join public.worktemplatenexttemplate as nt
                on  root.workinstanceworktemplateid = nt.worktemplatenexttemplateprevioustemplateid
                and root.workinstanceworktemplateid != nt.worktemplatenexttemplatenexttemplateid
                and (
                    nt.worktemplatenexttemplateenddate is null
                    or nt.worktemplatenexttemplateenddate > now()
                )
            inner join public.worktemplate as n
                on nt.worktemplatenexttemplatenexttemplateid = n.worktemplateid
            left join public.workresult as f
                on nt.worktemplatenexttemplateviaworkresultid = f.workresultid
            left join public.systag as f_op
                on nt.worktemplatenexttemplateviaworkresultcontstraintid = f_op.systagid
            left join public.systag as s
                on nt.worktemplatenexttemplateviastatuschangeid = s.systagid
            inner join public.systag as t
                on nt.worktemplatenexttemplatetypeid = t.systagid
            union all
            -- recurrence rules; prev = next
            -- FIXME: the only reason we have to differentiate here is because
            -- worktemplatenexttemplate only has the single column "typeid"
            -- which specifies the type of the *next* task. What we want in
            -- addition to this is a column that specifies the *mode*, i.e.
            -- eager or lazy.
            select
                'eager' as i_mode, -- rrules are always eager
                nt.worktemplatenexttemplateid as _id,
                root.id as task,
                root.parent_id as task_parent,
                root_t.id as next_task_id,
                null::text as curr_field_id,
                null::text as curr_field_op_id,
                s.systaguuid as curr_state_id,
                t.systaguuid as next_type_id
            from root
            inner join public.worktemplatenexttemplate as nt
                on  root.workinstanceworktemplateid = nt.worktemplatenexttemplateprevioustemplateid
                and root.workinstanceworktemplateid = nt.worktemplatenexttemplatenexttemplateid
                and (
                    nt.worktemplatenexttemplateenddate is null
                    or nt.worktemplatenexttemplateenddate > now()
                )
            inner join public.worktemplate as root_t
                on root.workinstanceworktemplateid = root_t.worktemplateid
            inner join public.systag as s
                on nt.worktemplatenexttemplateviastatuschangeid = s.systagid
            inner join public.systag as t
                on nt.worktemplatenexttemplatetypeid = t.systagid
        ),

        field_dst as (
            select
                dst.*,
                (
                    'engine0.eval_field_condition',
                    jsonb_build_object(
                        'field',
                        dst.curr_field_id,
                        'field_operator',
                        dst.curr_field_op_id,
                        'task',
                        dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.curr_field_id is not null and dst.curr_state_id is null
        ),

        state_dst as (
            select
                dst.*,
                (
                    'engine0.eval_state_condition',
                    jsonb_build_object(
                        'state',
                        dst.curr_state_id,
                        'task',
                        dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.curr_field_id is null and dst.curr_state_id is not null
        ),

        field_and_state_dst as (
            select
                dst.*,
                (
                    'engine0.eval_field_and_state_condition',
                    jsonb_build_object(
                        'field',
                        dst.curr_field_id,
                        'field_operator',
                        dst.curr_field_op_id,
                        'state',
                        dst.curr_state_id,
                        'task',
                        dst.task
                    )
                )::engine0.closure as op
            from dst
            where dst.curr_field_id is not null and dst.curr_state_id is not null
        ),

        plan as (
            select * from field_dst
            union all
            select * from state_dst
            union all
            select * from field_and_state_dst
        )

    select
        count(*) as count,
        array_agg(plan.op) as ops,
        plan.i_mode as i_mode,
        plan.next_task_id as target,
        plan.task_parent as target_parent,
        plan.next_type_id as target_type
    from plan
    group by plan.next_task_id, plan.next_type_id, plan.task_parent, plan.i_mode
  ;

  return;
end $$
language plpgsql
strict
;
-- fmt: on

comment on function engine0.build_instantiation_plan is $$

# engine0.build_instantiation_plan

Build an instantiation plan based on the current state of the system.

$$;

create or replace function
    engine0.evaluate_instantiation_plan(
        target text, target_type text, conditions engine0.closure[]
    )
returns table(system regproc, result boolean)
as $$
declare
  x engine0.closure;
begin
  foreach x in array conditions loop
    return query 
      select x.f as system, fx.ok
      from engine0.invoke(x) as fx(ok boolean)
    ;
  end loop;

  return;
end $$
language plpgsql
strict
;

comment on function engine0.evaluate_instantiation_plan is $$

# engine0.evaluate_instantiation_plan

Evaluate an instantiation plan.

$$;

create or replace function engine0.eval_field_condition(ctx jsonb)
returns table(ok boolean)
as $$
begin
  return query
    select false as ok
    from jsonb_to_record(ctx) as x(
        field text, field_operator text, state text, task text
    )
  ;

  return;
end $$
language plpgsql
strict
;

create or replace function engine0.eval_state_condition(ctx jsonb)
returns table(ok boolean)
as $$
begin
  return query
    select true as ok
    from jsonb_to_record(ctx) as x(state text, task text)
    inner join public.workinstance as i on x.task = i.id
    inner join public.systag as s
        on  x.state = s.systaguuid
        and i.workinstancestatusid = s.systagid
  ;

  return;
end $$
language plpgsql
strict
;

create or replace function engine0.eval_field_and_state_condition(ctx jsonb)
returns table(ok boolean)
as $$
begin
  return query 
    select true as ok
    from
        engine0.eval_field_condition(ctx) as f,
        engine0.eval_state_condition(ctx) as s
    where f.ok and s.ok
  ;

  return;
end $$
language plpgsql
strict
;

-- FIXME: ensure template is instantiable at location according to
-- worktemplateconstraint.
create or replace function
    engine0.instantiate(
        template_id text,
        location_id text,
        target_state text,
        target_type text,
        modified_by bigint,
        -- fmt: off
        chain_root_id text = null,
        chain_prev_id text = null
        -- fmt: on
    )
returns table(instance text, field text, value text)
as $$
declare
  ins_instance text;
begin
  insert into public.workinstance (
      workinstancecustomerid,
      workinstancesiteid,
      workinstanceworktemplateid,
      workinstanceoriginatorworkinstanceid,
      workinstancepreviousid,
      workinstancestatusid,
      workinstancetypeid,
      workinstancesoplink,
      workinstancestartdate,
      workinstancetargetstartdate,
      workinstancetimezone,
      workinstancemodifiedby
  )
  select
      task_t.worktemplatecustomerid,
      task_t.worktemplatesiteid,
      task_t.worktemplateid,
      chain_root.workinstanceid,
      chain_prev.workinstanceid,
      task_state_t.systagid,
      task_type_t.systagid,
      task_t.worktemplatesoplink,
      null, -- start date
      rr.target_start_time,
      location.locationtimezone,
      modified_by
  from
      public.worktemplate as task_t,
      public.location as location,
      public.systag as task_state_t,
      public.systag as task_type_t,
      engine0.evaluate_rrules(
          task_id := task_t.id,
          task_parent_id := location.locationuuid,
          task_prev_id := chain_prev_id,
          task_root_id := chain_root_id
      ) as rr
  left join public.workinstance as chain_root on chain_root.id = chain_root_id
  left join public.workinstance as chain_prev on chain_prev.id = chain_prev_id
  where
      task_t.id = template_id
      and location.locationuuid = location_id
      and (task_state_t.systagparentid, task_state_t.systagtype) = (705, target_state)
      and (task_type_t.systagparentid, task_type_t.systagtype) = (691, target_type)
  returning id into ins_instance
  ;
  --
  if not found then
    raise exception 'failed to create instance';
  end if;
  --
  return query select ins_instance as instance, null, null
  ;

  -- invariant: originator must not be null :sigh:
  update public.workinstance
  set workinstanceoriginatorworkinstanceid = workinstanceid
  where id = ins_instance and workinstanceoriginatorworkinstanceid is null
  ;

  -- default instantiate fields
  insert into public.workresultinstance (
      workresultinstancecustomerid,
      workresultinstanceworkinstanceid,
      workresultinstanceworkresultid,
      workresultinstancestartdate,
      workresultinstancecompleteddate,
      workresultinstancevalue,
      workresultinstancetimezone,
      workresultinstancemodifiedby
  )
  select
      i.workinstancecustomerid,
      i.workinstanceid,
      f.workresultid,
      i.workinstancestartdate,
      i.workinstancecompleteddate,
      f.workresultdefaultvalue,
      i.workinstancetimezone,
      modified_by
  from public.workinstance as i
  inner join public.workresult as f
      on i.workinstanceworktemplateid = f.workresultworktemplateid
  where
      i.id = ins_instance
      and f.workresultdeleted = false
      and f.workresultdraft = false
      and (f.workresultenddate is null or f.workresultenddate > now())
  on conflict do nothing
  ;

  -- Ensure the location primary field is set.
  with upd_value as (
      select field.workresultinstanceid as _id
      from public.workinstance as i
      inner join public.workresult as field_t
          on i.workinstanceworktemplateid = field_t.workresultworktemplateid
          and field_t.workresulttypeid = 848
          and field_t.workresultentitytypeid = 852
          and field_t.workresultisprimary = true
      inner join public.workresultinstance as field
          on  i.workinstanceid = field.workresultinstanceworkinstanceid
          and field_t.workresultid = field.workresultinstanceworkresultid
      where i.id = ins_instance
  )
  update public.workresultinstance
  set
      workresultinstancevalue = location.locationid::text,
      workresultinstancemodifiedby = modified_by,
      workresultinstancemodifieddate = now()
  from public.location, upd_value
  where
      workresultinstanceid = upd_value._id
      and location.locationuuid = location_id
  ;
  --
  if not found then
    -- Not an error? In theory primary location is not required at this level of
    -- abstraction. "Primary Location" is really an "Activity" invariant (recall
    -- that "Activity" is a Task + Location + Worker). We *should* try to
    -- generically enforce such invariants here however. One way that I can
    -- think to accomplish this is to treat primaries as "constructor" arguments
    -- and if they are `workresultisrequired` without a value, error.
    raise warning 'no primary location field for instance %', ins_instance;
  end if;

  return query
    select
        ins_instance as instance,
        field.workresultinstanceuuid as field,
        field.workresultinstancevalue as value
    from public.workresultinstance as field
    where field.workresultinstanceworkinstanceid in (
        select workinstanceid
        from public.workinstance
        where id = ins_instance
    )
  ;

  return;
end $$
language plpgsql
;

comment on function engine0.instantiate is $$

# engine0.instantiate

Instantiate a worktemplate at the given location and in the specified target state.
Note that this procedure does NOT protect against duplicates, nor perform any
validation aside from input validation. This procedure is a simple, low-level
primitive that implements generic instantiation.

## usage

```sql
select *
from engine0.instantiate(
    template_id := $1,     -- worktemplate.id (uuid)
    location_id := $2,     -- location.id (uuid), i.e. primary location
    target_state := $3,    -- 'Work Status' variant, e.g. 'Open'
    target_type := $4,     -- 'Work Type' variant, e.g. 'On Demand'
    chain_root_id := $5,   -- workinstance.id (uuid), i.e. originator
    chain_prev_id := $6,   -- workinstance.id (uuid), i.e. previous
    modified_by := $7      -- workerinstance.id (bigint)
);
```

$$;

create or replace function
    engine0.evaluate_rrules(
        -- fmt: off
        task_id text,
        task_parent_id text,
        task_prev_id text = null,
        task_root_id text = null
        -- fmt: on
    )
returns table(target_start_time timestamptz)
as $$
begin
  return query
    select coalesce(
        engine0.compute_rrule_next_occurrence(
            freq := freq.systagtype,
            interval_v := rr.workfrequencyvalue,
            dtstart := prev.workinstancecompleteddate
        ),
        now()
    ) as target_start_time
    from public.worktemplate as t
    left join public.workinstance as prev on prev.id = task_prev_id
    left join public.workfrequency as rr
        on  rr.workfrequencyworktemplateid = t.worktemplateid
        and (
            rr.workfrequencyenddate is null
            or rr.workfrequencyenddate > now()
        )
    left join public.systag as freq
        on  rr.workfrequencytypeid = freq.systagid
        and freq.systagtype != 'one time'
    where t.id = task_id
  ;

  if not found then
    return query select now() as target_start_time;
  end if;

  return;
end $$
language plpgsql
stable
;

-- fmt: off
create or replace function
    engine0.compute_rrule_next_occurrence(
        freq text, interval_v numeric, dtstart timestamptz
    )
returns timestamptz
as $$
declare
  freq_type text := case when freq = 'quarter' then 'month' else freq end;
  base_freq interval := format('1 %s', freq_type)::interval;
begin
  if freq = 'quarter' then
    base_freq := '3 month'::interval;
  end if;

  return dtstart + (base_freq / interval_v);
end $$
language plpgsql
immutable
strict
;
-- fmt: on

commit
;

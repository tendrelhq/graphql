-- Deploy graphql:template to pg
-- requires: name
begin
;

create function
    util.create_task_t(
        customer_id text,
        language_type text,
        task_name text,
        task_parent_id text,
        modified_by bigint,
        task_order integer = 0
    )
returns table(_id bigint, id text)
as $$
declare
  ins_template text;
begin
  with ins_name as (
    select *
    from util.create_name (
        customer_id := customer_id,
        modified_by := modified_by,
        source_language := language_type,
        source_text := task_name
    )
  )
  insert into public.worktemplate (
      worktemplatecustomerid,
      worktemplatesiteid,
      worktemplatenameid,
      worktemplateallowondemand,
      worktemplateworkfrequencyid,
      worktemplateisauditable,
      worktemplateorder,
      worktemplatemodifiedby
  )
  select
      customer.customerid,
      location.locationid,
      ins_name._id,
      true,
      1404,
      -- FIXME: implement audits
      false,
      task_order,
      modified_by
  from public.customer, public.location, ins_name
  where customer.customeruuid = customer_id and location.locationuuid = task_parent_id
  returning worktemplate.id into ins_template
  ;
  --
  if not found then
    raise exception 'failed to create template';
  end if;

  perform *
  from
      (
          values ('Location'::text, 'Entity'::text, 'Location'::text),
                 ('Worker', 'Entity', 'Worker'),
                 ('Time At Task', 'Time At Task', null)
      ) as field (f_name, f_type, f_ref_type),
      util.create_field_t(
          customer_id := customer_id,
          modified_by := modified_by,
          language_type := language_type,
          template_id := ins_template,
          field_name := field.f_name,
          field_type := field.f_type,
          field_reference_type := field.f_ref_type,
          field_is_primary := true,
          field_order := 0
      )
  ;
  --
  if not found then
    raise exception 'failed to create primary fields [location, worker, time at task]';
  end if;

  return query
    select worktemplateid as _id, worktemplate.id
    from public.worktemplate
    where worktemplate.id = ins_template
  ;

  return;
end $$
language plpgsql
strict
;

create function
    util.create_template_type(template_id text, systag_id text, modified_by bigint)
returns table(id text)
as $$
  insert into public.worktemplatetype (
      worktemplatetypecustomerid,
      worktemplatetypeworktemplateuuid,
      worktemplatetypeworktemplateid,
      worktemplatetypesystaguuid,
      worktemplatetypesystagid,
      worktemplatetypemodifiedby
  )
  select
      t.worktemplatecustomerid,
      t.id,
      t.worktemplateid,
      tt.systaguuid,
      tt.systagid,
      modified_by
  from public.worktemplate as t, public.systag as tt
  where t.id = template_id and tt.systaguuid = systag_id
  returning worktemplatetypeuuid as id
$$
language sql
strict
;

create function
    util.create_template_constraint_on_location(
        template_id text, location_id text, modified_by bigint
    )
returns table(id text)
as $$
begin
  return query
    insert into public.worktemplateconstraint (
        worktemplateconstraintcustomerid,
        worktemplateconstrainttemplateid,
        worktemplateconstraintconstrainedtypeid,
        worktemplateconstraintconstraintid,
        worktemplateconstraintmodifiedby
    )
    select
        t.worktemplatecustomerid,
        t.id,
        s.systaguuid,
        lt.custaguuid,
        modified_by
    from public.worktemplate as t
    inner join public.systag as s
        on s.systagparentid = 849 and s.systagtype = 'Location'
    inner join public.location as l
        on t.worktemplatesiteid = l.locationsiteid
        and l.locationuuid = location_id
    inner join public.custag as lt
        on l.locationcategoryid = lt.custagid
    where t.id = template_id
    returning worktemplateconstraintid as id
  ;

  if not found then
    raise exception 'failed to create template constraint on location';
  end if;

  return;
end $$
language plpgsql
strict
;

comment on function util.create_template_constraint_on_location is $$

# util.create_template_constraint_on_location

Create a template constraint that indicates that the given template can be
instantiated at the given location.

$$;

-- TODO: I wonder if we should create a separate function for creating fields of
-- reference type?
create function
    util.create_field_t(
        customer_id text,
        language_type text,
        template_id text,
        field_name text,
        field_type text,
        field_reference_type text,
        field_is_primary boolean,
        field_order integer,
        modified_by bigint
    )
returns table(id text)
as $$
  with
      ins_name as (
          select *
          from util.create_name(
              customer_id := customer_id,
              modified_by := modified_by,
              source_language := language_type,
              source_text := field_name
          )
      ),

      ins_type as (
          select t.systagid as _type, r.systagid as _ref_type
          from public.systag as t
          left join public.systag as r
              on r.systagparentid = 849
              and r.systagtype = field_reference_type
          where
              t.systagparentid = 699
              and t.systagtype = field_type
      )

  insert into public.workresult (
      workresultcustomerid,
      workresultdefaultvalue,
      workresultentitytypeid,
      workresultforaudit,
      workresultfortask,
      workresultisprimary,
      workresultisrequired,
      workresultlanguagemasterid,
      workresultorder,
      workresultsiteid,
      workresultsoplink,
      workresulttypeid,
      workresultwidgetid,
      workresultworktemplateid,
      workresultmodifiedby
  )
  select
      wt.worktemplatecustomerid,
      null,
      ins_type._ref_type,
      false,
      true,
      field_is_primary,
      false,
      ins_name._id,
      field_order,
      wt.worktemplatesiteid,
      null,
      ins_type._type,
      null,
      wt.worktemplateid,
      modified_by
  from
      public.worktemplate as wt,
      ins_name,
      ins_type
  where wt.id = template_id
  returning id;
$$
language sql
;

create function
    util.create_instantiation_rule(
        prev_template_id text,
        next_template_id text,
        state_condition text,
        type_tag text,
        modified_by bigint
    )
returns table(prev text, next text)
as $$
begin
  return query
    with cte as (
        insert into public.worktemplatenexttemplate(
            worktemplatenexttemplatecustomerid,
            worktemplatenexttemplatesiteid,
            worktemplatenexttemplateprevioustemplateid,
            worktemplatenexttemplatenexttemplateid,
            worktemplatenexttemplateviastatuschange,
            worktemplatenexttemplateviastatuschangeid,
            worktemplatenexttemplatetypeid,
            worktemplatenexttemplatemodifiedby
        )
        select
            prev.worktemplatecustomerid,
            prev.worktemplatesiteid,
            prev.worktemplateid,
            next.worktemplateid,
            true,
            s.systagid,
            tt.systagid,
            modified_by
        from public.worktemplate as prev
        inner join public.worktemplate as next on next.id = next_template_id
        inner join public.systag as s
            on s.systagparentid = 705 and s.systagtype = state_condition
        inner join public.systag as tt
            on tt.systagparentid = 691 and tt.systagtype = type_tag
        where prev.id = prev_template_id
        returning
            worktemplatenexttemplateprevioustemplateid as _prev,
            worktemplatenexttemplatenexttemplateid as _next
    )

    select prev.id as prev, next.id as next
    from cte
    inner join public.worktemplate as prev on cte._prev = prev.worktemplateid
    inner join public.worktemplate as next on cte._next = next.worktemplateid
  ;

  if not found then
    raise exception 'failed to create instantiation rule';
  end if;

  return;
end $$
language plpgsql
strict
;

create function
    util.create_rrule(
        task_id text,
        frequency_type text,
        frequency_interval numeric,
        modified_by bigint
    )
returns table(_id bigint)
as $$
begin
  return query
    with
        task as (
            select *
            from public.worktemplate
            where id = task_id
        ),

        type as (
            select *
            from public.systag
            where systagparentid = 738 and systagtype = frequency_type
        ),

        ins_freq as (
            insert into public.workfrequency (
                workfrequencycustomerid,
                workfrequencyworktemplateid,
                workfrequencytypeid,
                workfrequencyvalue,
                workfrequencymodifiedby
            )
            select
                task.worktemplatecustomerid,
                task.worktemplateid,
                type.systagid,
                frequency_interval,
                modified_by
            from task, type
            where not exists (
                select 1
                from public.workfrequency as wf
                inner join task on wf.workfrequencyworktemplateid = task.worktemplateid
                inner join type on wf.workfrequencytypeid = type.systagid
                where wf.workfrequencyvalue = frequency_interval
            )
            returning workfrequencyid
        )

    select workfrequencyid as _id
    from ins_freq
    union all
    select wf.workfrequencyid as _id
    from task, type, public.workfrequency as wf
    where
        wf.workfrequencyworktemplateid = task.worktemplateid
        and wf.workfrequencytypeid = type.systagid
        and wf.workfrequencyvalue = frequency_interval
  ;
  --
  if not found then
    raise exception 'failed to create recurrence rule';
  end if;

  return;
end $$
language plpgsql
strict
;

create function
    util.evaluate_rrules(
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
        util.compute_rrule_next_occurrence(
            freq := freq.systagtype,
            interval_v := rr.workfrequencyvalue,
            dtstart := prev.workinstancecompleteddate,
            tzid := prev.workinstancetimezone
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
create function
    util.compute_rrule_next_occurrence(
        freq text, interval_v numeric, dtstart timestamptz, tzid text = 'utc'
    )
returns timestamptz
as $$
declare
  -- normalize our inputs
  -- 1. adjust dtstart for the correct timezone
  dtstart_norm timestamptz := timezone(tzid, dtstart);
  -- 2. convert 'quarter' frequency to 'month'
  freq_norm text := case when freq = 'quarter' then 'month' else freq end;
  --
  base_freq interval := format('1 %s', freq_norm)::interval;
begin
  if freq = 'quarter' then
    base_freq := '3 month'::interval;
  end if;

  return dtstart_norm + (base_freq / interval_v);
end $$
language plpgsql
stable
strict
;
-- fmt: on

-- FIXME: ensure template is instantiable at location according to
-- worktemplateconstraint.
create function
    util.instantiate(
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
      util.evaluate_rrules(
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

comment on function util.instantiate is $$

# util.instantiate

Instantiate a worktemplate at the given location and in the specified target state.
Note that this procedure does NOT protect against duplicates, nor perform any
validation aside from input validation. This procedure is a simple, low-level
primitive that implements generic instantiation.

## usage

```sql
select *
from util.instantiate(
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

commit
;

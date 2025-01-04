-- Deploy graphql:template to pg
-- requires: name
begin
;

create function
    util.create_task_t(
        customer_id text, language_type text, task_name text, task_parent_id text
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
      worktemplateisauditable
  )
  select
      customer.customerid,
      location.locationid,
      ins_name._id,
      -- FIXME: implement scheduling
      true,
      1404,
      -- FIXME: implement audits
      false
  from public.customer, public.location, ins_name
  where customer.customeruuid = customer_id and location.locationuuid = task_parent_id
  returning worktemplate.id into ins_template
  ;
  --
  if not found then
    raise exception 'failed to create template';
  end if;

  perform * from (
                values ('Location'::text, 'Location'::text), ('Worker', 'Worker')
            ) as field (f_name, f_ref_type)
            cross join
                lateral util.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_template,
                    field_name := field.f_name,
                    field_type := 'Entity'::text,
                    field_reference_type := field.f_ref_type,
                    field_is_primary := true,
                    field_order := 0
                )
  ;
  --
  if not found then
    raise exception 'failed to create location primary field';
  end if;

  return query select worktemplateid as _id, worktemplate.id
               from public.worktemplate
               where worktemplate.id = ins_template
  ;

  return;
end $$
language plpgsql
strict
;

create function util.create_template_type(template_id text, systag_id text)
returns table(id text)
as $$
  insert into public.worktemplatetype (
      worktemplatetypecustomerid,
      worktemplatetypeworktemplateuuid,
      worktemplatetypeworktemplateid,
      worktemplatetypesystaguuid,
      worktemplatetypesystagid
  )
  select
      t.worktemplatecustomerid,
      t.id,
      t.worktemplateid,
      tt.systaguuid,
      tt.systagid
  from public.worktemplate as t, public.systag as tt
  where t.id = template_id and tt.systaguuid = systag_id
  returning worktemplatetypeuuid as id
$$
language sql
strict
;

create function
    util.create_template_constraint_on_location(template_id text, location_id text)
returns table(id text)
as $$
begin
  return query insert into public.worktemplateconstraint (
                           worktemplateconstraintcustomerid,
                           worktemplateconstrainttemplateid,
                           worktemplateconstraintconstrainedtypeid,
                           worktemplateconstraintconstraintid
                       )
                       select
                           t.worktemplatecustomerid,
                           t.id,
                           s.systaguuid,
                           lt.custaguuid
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
        field_order integer
    )
returns table(id text)
as $$
  with
      ins_name as (
          select *
          from util.create_name(
              customer_id := customer_id,
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
      workresultworktemplateid
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
      wt.worktemplateid
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
    util.create_morphism(prev_template_id text, next_template_id text, type_tag text)
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
            worktemplatenexttemplatetypeid
        )
        select
            prev.worktemplatecustomerid,
            prev.worktemplatesiteid,
            prev.worktemplateid,
            next.worktemplateid,
            true,
            s.systagid,
            tt.systagid
        from public.worktemplate as prev
        inner join public.worktemplate as next on next.id = next_template_id
        inner join public.systag as s
            on s.systagparentid = 705 and s.systagtype = 'In Progress'
        inner join public.systag as tt
            on tt.systagparentid = 691 and tt.systagtype = type_tag
        where prev.id = prev_template_id
        returning
            worktemplatenexttemplateprevioustemplateid as _prev,
            worktemplatenexttemplatenexttemplateid as _next
    )

    select prev.id as prev, next.id as next
    from cte
    inner join public.worktemplate as prev
        on cte._prev = prev.worktemplateid
    inner join public.worktemplate as next
        on cte._next = next.worktemplateid
  ;

  if not found then
    raise exception 'failed to create morphism';
  end if;

  return;
end $$
language plpgsql
strict
;

-- FIXME: ensure template is instantiable at location according to
-- worktemplateconstraint.
create function
    util.instantiate(
        -- fmt: off
        template_id text,
        location_id text,
        target_state text,
        target_type text,
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
      workinstancetimezone
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
      now(), -- target start date, FIXME: implement scheduling
      location.locationtimezone
  from
      public.worktemplate as task_t,
      public.location as location,
      public.systag as task_state_t,
      public.systag as task_type_t
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
  return query select ins_instance as instance, null, null
  ;
  --
  if not found then
    raise exception 'failed to create instance';
  end if;

  -- invariant: originator must not be null :sigh:
  update public.workinstance
  set workinstanceoriginatorworkinstanceid = workinstanceid
  where id = ins_instance
  ;

  -- default instantiate fields
  insert into public.workresultinstance (
      workresultinstancecustomerid,
      workresultinstanceworkinstanceid,
      workresultinstanceworkresultid,
      workresultinstancestartdate,
      workresultinstancecompleteddate,
      workresultinstancevalue,
      workresultinstancetimezone
  )
  select
      i.workinstancecustomerid,
      i.workinstanceid,
      f.workresultid,
      i.workinstancestartdate,
      i.workinstancecompleteddate,
      f.workresultdefaultvalue,
      i.workinstancetimezone
  from public.workinstance as i
  inner join public.workresult as f
      on i.workinstanceworktemplateid = f.workresultworktemplateid
  where
      i.id = ins_instance
      and (f.workresultenddate is null or f.workresultenddate > now())
  ;

  -- ensure the location primary field is correct
  with upd_value as (
      select field.workresultinstanceid as _id, l.locationid::text as value
      from public.workinstance as i
      inner join public.location as l
          on l.locationuuid = location_id
      inner join public.workresult as field_t
          on i.workinstanceworktemplateid = field_t.workresultworktemplateid
          and field_t.workresulttypeid = 848
          and field_t.workresultentitytypeid = 852
          and field_t.workresultisprimary = true
      inner join public.workresultinstance as field
          on i.workinstanceid = field.workresultinstanceworkinstanceid
          and field_t.workresultid = field.workresultinstanceworkresultid
      where i.id = ins_instance
  )
  update public.workresultinstance
  set workresultinstancevalue = upd_value.value
  from upd_value
  where workresultinstanceid = upd_value._id
  ;
  --
  if not found then
    raise exception 'failed to find primary location field';
  end if;

  return query select
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
    location_id := $2,     -- location.id (uuid)
    target_state := $3,    -- 'Work Status' variant, e.g. 'Open'
    target_type := $4,     -- 'Work Type' variant, e.g. 'On Demand'
    chain_root_id := $5,   -- workinstance.id (uuid), i.e. originator
    chain_prev_id := $6    -- workinstance.id (uuid), i.e. previous
);
```

$$;

-- create type chain_strategy as enum (
-- 'branch',
-- 'continue'
-- );
--
-- create type field_input as (
-- field text,
-- value text
-- );
--
-- create function
-- util.chain_into(
-- -- fmt: off
-- -- required
-- from_instance text,
-- into_instance_or_template text,
-- strategy chain_strategy = 'continue',
-- -- optional
-- carry_over_assignments boolean = null,
-- field_overrides field_input[] = null
-- -- fmt: on
-- )
-- returns table(id text)
-- as $$
-- begin
-- if from_instance is null then
-- raise exception 'chain_into: from_instance is required';
-- end if;
-- if into_instance_or_template is null then
-- raise exception 'chain_into: into_instance_or_template is required';
-- end if;
-- if strategy is null then
-- raise exception 'chain_into: strategy is required';
-- end if;
--
-- raise exception 'not yet implemented';
-- end $$
-- language plpgsql
-- ;
--
-- comment on function util.chain_into is $$
--
-- # util.chain_into
--
-- ## Usage
--
-- ```sql
-- select *
-- from util.chain_into(
-- from_instance := $1,
-- into_instance_or_template := $2,
-- strategy := $3,
-- carry_over_assignments := $4,
-- field_overrides := $5
-- );
-- ```
--
-- $$;
commit
;


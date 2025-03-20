-- Deploy graphql:004-legacy-entities to pg
begin
;

create schema legacy0;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema legacy0 from graphql;
    grant usage on schema legacy0 to graphql;
    alter default privileges in schema legacy0 grant execute on routines to graphql;
  end if;

  if exists (select 1 from pg_roles where rolname = 'tendrelservice') then
    revoke all on schema legacy0 from tendrelservice;
    grant usage on schema legacy0 to tendrelservice;
    alter default privileges in schema legacy0 grant execute on routines to tendrelservice;
  end if;
end $$;

-- fmt: off
create or replace function
    legacy0.create_location(
        customer_id text,
        language_type text,
        location_name text,
        location_parent_id text,
        location_timezone text,
        location_typename text,
        modified_by bigint
    )
returns table(_id bigint, id text)
as $$
-- fmt: on
declare
  ins_location text;
begin
  perform 1
  from public.location
  where locationuuid = location_parent_id;
  --
  if location_parent_id is not null and not found then
    raise exception 'given parent % does not exist', location_parent_id;
  end if;

  with ins_name as (
    select *
    from public.create_name(
        customer_id := customer_id,
        source_language := language_type,
        source_text := location_name,
        modified_by := modified_by
    )
  ),

  location_type as (
    select *
    from ast.create_user_type(
        customer_id := customer_id,
        language_type := language_type,
        type_name := location_typename,
        type_hierarchy := 'Location Category',
        modified_by := modified_by
    )
  )

  insert into public.location (
      locationcategoryid,
      locationcornerstoneorder,
      locationcustomerid,
      locationistop,
      locationiscornerstone,
      locationlookupname,
      locationmodifiedby,
      locationnameid,
      locationparentid,
      locationsiteid,
      locationtimezone
  )
  select
      location_type._id,
      0, -- cornerstone order
      c.customerid,
      location_parent_id is null,
      false,
      location_name, -- lookup name
      modified_by,
      ins_name._id,
      p.locationid,
      p.locationsiteid,
      location_timezone
  from
      public.customer as c,
      ins_name,
      location_type
  left join public.location as p
      on p.locationuuid = location_parent_id
  where c.customeruuid = customer_id
  returning locationuuid into ins_location
  ;
  --
  if not found then
    raise exception 'failed to create location';
  end if;

  return query select locationid as _id, locationuuid as id
               from public.location
               where locationuuid = ins_location
  ;

  -- invariant: locationsiteid must not be null
  update public.location
  set locationsiteid = locationid
  where locationuuid = ins_location and locationsiteid is null
  ;

  return;
end $$
language plpgsql
;

create or replace function
    legacy0.create_worker(
        customer_id text, user_id text, user_role text, modified_by bigint
    )
returns table(_id bigint, id text)
as $$
  insert into public.workerinstance (
      workerinstancecustomerid,
      workerinstancecustomeruuid,
      workerinstanceworkerid,
      workerinstanceworkeruuid,
      workerinstancelanguageid,
      workerinstancelanguageuuid,
      workerinstanceuserroleid,
      workerinstanceuserroleuuid,
      workerinstancemodifiedby
  )
  select
      c.customerid,
      c.customeruuid,
      u.workerid,
      u.workeruuid,
      l.systagid,
      l.systaguuid,
      r.systagid,
      r.systaguuid,
      modified_by
  from public.customer as c
  inner join public.worker as u
      on u.workeruuid = user_id
  inner join public.systag as l
      on u.workerlanguageid = l.systagid
  inner join public.systag as r
      on r.systagparentid = 772 and r.systagtype = user_role
  where c.customeruuid = customer_id
  returning workerinstanceid as _id, workerinstanceuuid as id;
$$
language sql
strict
;

create or replace function
    legacy0.create_task_t(
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
    from public.create_name (
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
      legacy0.create_field_t(
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

create or replace function
    legacy0.create_template_type(template_id text, systag_id text, modified_by bigint)
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

create or replace function
    legacy0.create_template_constraint_on_location(
        template_id text, location_id text, modified_by bigint
    )
returns table(id text)
as $$
begin
  return query
    with ins as (
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
        on conflict do nothing
        returning worktemplateconstraintid as id
    )

    select * from ins
    union all
    select wtc.worktemplateconstraintid as id
    from public.worktemplateconstraint as wtc
    inner join public.worktemplate as t
        on t.id = template_id
        and wtc.worktemplateconstrainttemplateid = t.id
    inner join public.location as l
        on t.worktemplatesiteid = l.locationsiteid
        and l.locationuuid = location_id
    where
        wtc.worktemplateconstraintconstrainedtypeid = (
            select systaguuid
            from public.systag
            where systagparentid = 849 and systagtype = 'Location'
        )
        and wtc.worktemplateconstraintconstraintid = (
            select custaguuid
            from public.custag
            where custagid = l.locationcategoryid
        )
    limit 1
  ;

  if not found then
    raise exception 'failed to create template constraint on location';
  end if;

  return;
end $$
language plpgsql
strict
;

comment on function legacy0.create_template_constraint_on_location is $$

# legacy0.create_template_constraint_on_location

Create a template constraint that indicates that the given template can be
instantiated at the given location.

$$;

-- TODO: I wonder if we should create a separate function for creating fields of
-- reference type?
create or replace function
    legacy0.create_field_t(
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
          from public.create_name(
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

create or replace function
    legacy0.create_instantiation_rule(
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

create or replace function
    legacy0.create_rrule(
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

COMMIT;

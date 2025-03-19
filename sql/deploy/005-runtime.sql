-- Deploy graphql:005-runtime to pg
begin
;

create schema runtime;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema runtime from graphql;
    grant usage on schema runtime to graphql;
    alter default privileges in schema runtime grant execute on routines to graphql;
  end if;
end $$;

create or replace function
    runtime.create_customer(customer_name text, language_type text, modified_by bigint)
returns table(_id bigint, id text)
as $$
declare
  ins_customer text;
begin
  with ins_name as (
    select t.*
    from public.customer as c
    cross join
        lateral public.create_name(
            customer_id := c.customeruuid,
            source_language := language_type,
            source_text := customer_name,
            modified_by := modified_by
        ) as t
    where c.customerid = 0
  )
  insert into public.customer (
      customername,
      customerlanguagetypeid,
      customerlanguagetypeuuid,
      customernamelanguagemasterid,
      customermodifiedby
  )
  select
      customer_name,
      s.systagid,
      s.systaguuid,
      ins_name._id,
      modified_by
  from ins_name
  inner join public.systag as s on s.systagparentid = 2 and s.systagtype = language_type
  returning customeruuid into ins_customer;
  --
  if not found then
    raise exception 'failed to create customer';
  end if;

  -- update the name to point at the right customer :sigh:
  update public.languagemaster as lm
  set languagemastercustomerid = c.customerid
  from public.customer as c
  where lm.languagemasterid = c.customernamelanguagemasterid
  and c.customeruuid = ins_customer;

  -- create a customerrequestedlanguage
  perform 1
  from i18n.add_language_to_customer(
      customer_id := ins_customer,
      language_code := language_type,
      modified_by := modified_by
  );

  return query select customerid as _id, customeruuid as id
               from public.customer
               where customeruuid = ins_customer;

  return;
end $$
language plpgsql
strict
;

create or replace function
    runtime.create_location(
        customer_id text,
        modified_by bigint,
        language_type text,
        timezone text,
        location_name text,
        location_parent_id text,
        location_typename text
    )
returns table(_id bigint, id text)
as $$
begin
  return query
    select *
    from legacy0.create_location(
        customer_id := customer_id,
        language_type := language_type,
        location_name := location_name,
        location_parent_id := location_parent_id,
        location_timezone := timezone,
        location_typename := location_typename,
        modified_by := modified_by
    );

  return;
end $$
language plpgsql
strict
;

create or replace function
    runtime.create_demo(customer_name text, admins text[], modified_by bigint)
returns table(op text, id text)
as $$
declare
  default_language_type text := 'en';
  default_user_role text := 'Admin';
  default_timezone text := 'UTC';
  --
  ins_customer text;
begin
  select t.id into ins_customer
  from
      runtime.create_customer(
          customer_name := customer_name,
          language_type := default_language_type,
          modified_by := modified_by
      ) as t
  ;
  --
  return query select '+customer', ins_customer;

  return query
    select ' +worker', t.id
    from
        public.worker as w,
        legacy0.create_worker(
            customer_id := ins_customer,
            user_id := w.workeruuid,
            user_role := default_user_role,
            modified_by := modified_by
        ) as t
    where w.workeruuid = any(admins)
  ;
  --
  if not found and array_length(admins, 1) > 0 then
    raise exception 'failed to create admin workers';
  end if;

  return query
    select *
    from runtime.add_demo_to_customer(
        customer_id := ins_customer,
        language_type := default_language_type,
        modified_by := modified_by,
        timezone := default_timezone
    )
  ;
  --
  if not found then
    raise exception 'failed to add runtime to customer';
  end if;

  return;
end $$
language plpgsql
strict
;

create or replace function
    runtime.add_demo_to_customer(
        customer_id text, language_type text, modified_by bigint, timezone text
    )
returns table(op text, id text)
as $$
declare
  ins_site text;
  ins_locations text[];
  --
  ins_template text;
  --
  loop0_x text;
begin
  select t.id into ins_site
  from
      -- NOTE: we use the internal function here since the runtime version does
      -- not all creating top-level locations (i.e. no parent).
      legacy0.create_location(
          customer_id := customer_id,
          language_type := language_type,
          location_name := 'Frozen Tendy Factory',
          location_parent_id := null,
          location_timezone := timezone,
          location_typename := 'Frozen Tendy Factory',
          modified_by := modified_by
      ) as t
  ;
  --
  if not found then
    raise exception 'failed to create site';
  end if;
  --
  return query select '+site', ins_site;

  with
      inputs(location_name, location_typename) as (
          values
              ('Mixing Line'::text, 'Runtime Location'::text),
              ('Fill Line', 'Runtime Location'),
              ('Assembly Line', 'Runtime Location'),
              ('Cartoning Line', 'Runtime Location'),
              ('Packaging Line', 'Runtime Location')
      )
  select array_agg(t.id) into ins_locations
  from
      inputs,
      runtime.create_location(
          customer_id := customer_id,
          language_type := language_type,
          timezone := timezone,
          location_name := inputs.location_name,
          location_parent_id := ins_site,
          location_typename := inputs.location_typename,
          modified_by := modified_by
      ) as t
  ;
  --
  if not found then
    raise exception 'failed to create locations';
  end if;
  --
  return query select ' +location', t.id from unnest(ins_locations) as t (id);

  select t.id into ins_template
  from legacy0.create_task_t(
      customer_id := customer_id,
      language_type := language_type,
      task_name := 'Run',
      task_parent_id := ins_site,
      modified_by := modified_by
  ) as t;
  --
  if not found then
    raise exception 'failed to create template';
  end if;
  --
  return query select ' +task', ins_template;

  return query
    select '  +type', t.id
    from
        public.systag as s,
        legacy0.create_template_type(
            template_id := ins_template,
            systag_id := s.systaguuid,
            modified_by := modified_by
        ) as t
    where s.systagparentid = 882 and s.systagtype in ('Trackable', 'Runtime')
  ;
  --
  if not found then
    raise exception 'failed to create template type';
  end if;

  return query
    with field (f_name, f_type, f_is_primary, f_order) as (
        values
            ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
            ('Override End Time', 'Date', true, 1),
            ('Run Output', 'Number', false, 2),
            ('Reject Count', 'Number', false, 3),
            ('Comments', 'String', false, 99)
    )
    select '  +field', t.id
    from
        field,
        legacy0.create_field_t(
            customer_id := customer_id,
            language_type := language_type,
            template_id := ins_template,
            field_name := field.f_name,
            field_type := field.f_type,
            field_reference_type := null,
            field_is_primary := field.f_is_primary,
            field_order := field.f_order,
            modified_by := modified_by
        ) as t
  ;
  --
  if not found then
    raise exception 'failed to create template fields';
  end if;

  -- The canonical on-demand in-progress "respawn" rule. This rule causes a new,
  -- Open task instance to be created when a task transitions to InProgress.
  return query
    select '  +irule', t.next
    from legacy0.create_instantiation_rule(
        prev_template_id := ins_template,
        next_template_id := ins_template,
        state_condition := 'In Progress',
        type_tag := 'On Demand',
        modified_by := modified_by
    ) as t;
  --
  if not found then
    raise exception 'failed to create canonical on-demand in-progress irule';
  end if;

  -- Create the constraint for the root template at each child location.
  <<loop0>>
  foreach loop0_x in array ins_locations loop
    return query
      with
          ins_constraint as (
              select *
              from legacy0.create_template_constraint_on_location(
                  template_id := ins_template,
                  location_id := loop0_x,
                  modified_by := modified_by
              ) as t
          ),

          ins_instance as (
              select *
              from engine0.instantiate(
                  template_id := ins_template,
                  location_id := loop0_x,
                  target_state := 'Open',
                  target_type := 'On Demand',
                  modified_by := modified_by
              )
          )

      select '  +constraint', t.id
      from ins_constraint as t
      union all
      (
        select '   +instance', t.instance
        from ins_instance as t
        group by t.instance
      )
    ;
  end loop loop0;
  --
  if not found then
    raise exception 'failed to create location constraint/initial instance';
  end if;

  -- Create the Idle Time template, which is a transition from Runtime.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := customer_id,
                language_type := language_type,
                task_name := 'Idle Time',
                task_parent_id := ins_site,
                task_order := 1,
                modified_by := modified_by
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Idle Time'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_next.id,
                    field_name := field.f_name,
                    field_type := field.f_type,
                    field_reference_type := null,
                    field_is_primary := field.f_is_primary,
                    field_order := field.f_order,
                    modified_by := modified_by
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand',
                    modified_by := modified_by
                ) as t
        ),

        ins_constraint as (
            select t.*
            from
                unnest(ins_locations) as ins_location(id),
                ins_next,
                legacy0.create_template_constraint_on_location(
                    template_id := ins_next.id,
                    location_id := ins_location.id,
                    modified_by := modified_by
                ) as t
        )

        select '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Idle Time)';
  end if;

  -- Create the Downtime template, which is a transition from Runtime.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override Start Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from legacy0.create_task_t(
                customer_id := customer_id,
                language_type := language_type,
                task_name := 'Downtime',
                task_parent_id := ins_site,
                task_order := 0,
                modified_by := modified_by
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral legacy0.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid,
                modified_by := modified_by
            ) as t
            where s.systagtype = 'Downtime'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral legacy0.create_field_t(
                    customer_id := customer_id,
                    language_type := language_type,
                    template_id := ins_next.id,
                    field_name := field.f_name,
                    field_type := field.f_type,
                    field_reference_type := null,
                    field_is_primary := field.f_is_primary,
                    field_order := field.f_order,
                    modified_by := modified_by
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral legacy0.create_instantiation_rule(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    state_condition := 'In Progress',
                    type_tag := 'On Demand',
                    modified_by := modified_by
                ) as t
        ),

        ins_constraint as (
            select t.*
            from
                unnest(ins_locations) as ins_location(id),
                ins_next,
                legacy0.create_template_constraint_on_location(
                    template_id := ins_next.id,
                    location_id := ins_location.id,
                    modified_by := modified_by
                ) as t
        )

        select '  +next', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
        union all
        select '   +constraint', ins_constraint.id
        from ins_constraint
  ;
  --
  if not found then
    raise exception 'failed to create next template (Downtime)';
  end if;

  return;
end $$
language plpgsql
strict
;

create or replace function runtime.destroy_demo(customer_id text)
returns text
as $$
declare
  _customer_id bigint;
begin
  select customerid into _customer_id
  from public.customer
  where customeruuid = customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.apikey
  where apikeycustomerid = _customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.customerconfig
  where customerconfigcustomeruuid = customer_id;

  delete from public.workdescription
  where workdescriptioncustomerid = _customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.worktemplateconstraint
  where worktemplateconstraintcustomerid = _customer_id;

  -- FIXME: CASCADE deletes.
  delete from public.worktemplatetype
  where worktemplatetypecustomerid = _customer_id;

  delete from public.customer
  where customeruuid = customer_id;

  return 'ok';
end $$
language plpgsql
strict
;


commit
;

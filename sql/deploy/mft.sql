-- Deploy graphql:mft to pg
begin
;

create schema mft
;

create function mft.create_customer(customer_name text, language_type text)
returns table(_id bigint, id text)
as $$
declare
  ins_customer text;
begin
  with ins_name as (
    select t.*
    from public.customer as c
    cross join
        lateral util.create_name(
            customer_id := c.customeruuid,
            source_language := language_type,
            source_text := customer_name
        ) as t
    where c.customerid = 0
  )
  insert into public.customer (
      customername,
      customerlanguagetypeid,
      customerlanguagetypeuuid,
      customernamelanguagemasterid
  )
  select
      customer_name,
      s.systagid,
      s.systaguuid,
      ins_name._id
  from ins_name
  inner join public.systag as s on s.systagparentid = 2 and s.systagtype = language_type
  returning customeruuid into ins_customer;

  if not found then
    raise exception 'failed to create customer';
  end if;

  -- update the name to point at the right customer :sigh:
  update public.languagemaster as lm
  set languagemastercustomerid = c.customerid
  from public.customer as c
  where lm.languagemasterid = c.customernamelanguagemasterid
  and c.customeruuid = ins_customer;

  if not found then
    raise exception 'invariant violated';
  end if;

  return query select customerid as _id, customeruuid as id
               from public.customer
               where customeruuid = ins_customer;

  return;
end $$
language plpgsql
strict
;

create function
    mft.create_location(
        customer_id text,
        language_type text,
        timezone text,
        location_name text,
        location_parent_id text,
        location_typename text
    )
returns table(_id bigint, id text)
as $$
begin
  return query select *
               from util.create_location(
                  customer_id := customer_id,
                  language_type := language_type,
                  location_name := location_name,
                  location_parent_id := location_parent_id,
                  location_typename := location_typename,
                  location_type_hierarchy := 'Trackable',
                  location_timezone := timezone
               );

  return;
end $$
language plpgsql
strict
;

create function mft.create_demo(customer_name text, admins text[])
returns table(op text, id text)
as $$
declare
  default_language_type text := 'en';
  default_user_role text := 'Admin';
  default_timezone text := current_setting('timezone');
  --
  ins_customer text;
  ins_site text;
  ins_location text[];
  --
  ins_template text;
  --
  loop0_t text;
begin
  select t.id into ins_customer
  from
      mft.create_customer(
          customer_name := customer_name,
          language_type := default_language_type
      ) as t
  ;
  --
  return query select '+customer', ins_customer;

  return query select ' +worker', t.id
               from public.worker as w
               cross join
                   lateral util.create_worker(
                       customer_id := ins_customer,
                       user_id := w.workeruuid,
                       user_role := default_user_role
                   ) as t
               where w.workeruuid = any(admins)
  ;
  --
  if not found and array_length(admins, 1) > 0 then
    raise exception 'failed to create admin workers';
  end if;

  select t.id into ins_site
  from
      util.create_location(
          customer_id := ins_customer,
          language_type := default_language_type,
          location_name := 'Frozen Tendy Factory',
          location_parent_id := null,
          location_typename := 'Tendy Factory',
          location_type_hierarchy := 'Location Category',
          location_timezone := default_timezone
      ) as t
  ;
  --
  if not found then
    raise exception 'failed to create site';
  end if;
  --
  return query select '+site', ins_site;

  select t.id into ins_template
  from util.create_task_t(
      customer_id := ins_customer,
      language_type := default_language_type,
      task_name := 'Run',
      task_parent_id := ins_site
  ) as t;
  --
  if not found then
    raise exception 'failed to create template';
  end if;
  --
  return query select ' +task', ins_template;

  return query select '  +type', t.id
               from public.systag as s
               cross join lateral util.create_template_type(
                   template_id := ins_template,
                   systag_id := s.systaguuid
               ) as t
               where s.systagtype in ('Trackable', 'Runtime')
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
    from field
    cross join
        lateral util.create_field_t(
            customer_id := ins_customer,
            language_type := default_language_type,
            template_id := ins_template,
            field_name := field.f_name,
            field_type := field.f_type,
            field_reference_type := null,
            field_is_primary := field.f_is_primary,
            field_order := field.f_order
        ) as t
  ;
  --
  if not found then
    raise exception 'failed to create template fields';
  end if;

  -- Create the Idle Time template, which is a transition from Runtime.
  return query
    with
        field (f_name, f_type, f_is_primary, f_order) as (
            values
                ('Override State Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from util.create_task_t(
                customer_id := ins_customer,
                language_type := default_language_type,
                task_name := 'Idle Time',
                task_parent_id := ins_site
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral util.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid
            ) as t
            where s.systagtype = 'Idle Time'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral util.create_field_t(
                    customer_id := ins_customer,
                    language_type := default_language_type,
                    template_id := ins_next.id,
                    field_name := field.f_name,
                    field_type := field.f_type,
                    field_reference_type := null,
                    field_is_primary := field.f_is_primary,
                    field_order := field.f_order
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral util.create_morphism(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    type_tag := 'Task'
                ) as t
        )

        select '  +task', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
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
                ('Override State Time'::text, 'Date'::text, true::boolean, 0::integer),
                ('Override End Time', 'Date', true, 1),
                ('Description', 'String', false, 2)
        ),

        ins_next as (
            select t.*
            from util.create_task_t(
                customer_id := ins_customer,
                language_type := default_language_type,
                task_name := 'Downtime',
                task_parent_id := ins_site
            ) as t
        ),

        ins_type as (
            select t.*
            from ins_next, public.systag as s
            cross join lateral util.create_template_type(
                template_id := ins_next.id,
                systag_id := s.systaguuid
            ) as t
            where s.systagtype = 'Downtime'
        ),

        ins_field as (
            select t.*
            from field, ins_next
            cross join
                lateral util.create_field_t(
                    customer_id := ins_customer,
                    language_type := default_language_type,
                    template_id := ins_next.id,
                    field_name := field.f_name,
                    field_type := field.f_type,
                    field_reference_type := null,
                    field_is_primary := field.f_is_primary,
                    field_order := field.f_order
                ) as t
        ),

        ins_nt_rule as (
            select t.*
            from ins_next
            cross join
                lateral util.create_morphism(
                    prev_template_id := ins_template,
                    next_template_id := ins_next.id,
                    type_tag := 'Task'
                ) as t
        )

        select '  +task', ins_nt_rule.next
        from ins_nt_rule
        union all
        select '   +type', ins_type.id
        from ins_type
        union all
        select '   +field', ins_field.id
        from ins_field
  ;
  --
  if not found then
    raise exception 'failed to create next template (Downtime)';
  end if;

  with
      inputs(location_name, location_typename) as (
          values
              ('Mixing Line'::text, 'Mixing Tracking'::text),
              ('Fill Line', 'Fill Tracking'),
              ('Assembly Line', 'Assembly Tracking'),
              ('Cartoning Line', 'Cartoning Tracking'),
              ('Packaging Line', 'Packaging Tracking')
      )
  select array_agg(t.id) into ins_location
  from inputs
  cross join
      lateral mft.create_location(
          customer_id := ins_customer,
          language_type := default_language_type,
          timezone := default_timezone,
          location_name := inputs.location_name,
          location_parent_id := ins_site,
          location_typename := inputs.location_typename
      ) as t
  ;
  --
  if not found then
    raise exception 'failed to create locations';
  end if;

  <<loop0>>
  foreach loop0_t in array ins_location loop
    return query
      with
          ins_constraint as (
              select *
              from util.create_template_constraint_on_location(
                  template_id := ins_template,
                  location_id := loop0_t
              ) as t
          ),

          ins_instance as (
              select *
              from util.instantiate(
                  template_id := ins_template,
                  location_id := loop0_t,
                  target_state := 'Open',
                  target_type := 'On Demand'
              )
          )

      select ' +location', loop0_t
      union all
      select '  +constraint', t.id
      from ins_constraint as t
      union all
      (
        select '  +instance', t.instance
        from ins_instance as t
        group by t.instance
      )
    ;
  end loop loop0;

  return;
end $$
language plpgsql
strict
;

create function mft.destroy_demo(customer_id text)
returns text
as $$
begin
  -- FIXME: CASCADE deletes.
  delete from public.worktemplateconstraint
  where worktemplateconstraintcustomerid = (
      select customerid
      from public.customer
      where customeruuid = customer_id
  );

  -- FIXME: CASCADE deletes.
  delete from public.worktemplatetype
  where worktemplatetypecustomerid = (
      select customerid
      from public.customer
      where customeruuid = customer_id
  );

  delete from public.customer
  where customeruuid = customer_id
  ;

  return 'ok';
end $$
language plpgsql
strict
;

commit
;


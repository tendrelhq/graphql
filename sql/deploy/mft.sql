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
  -- create the customer
  with ins_name as (
    select * from util.create_name(
        customer_id := 'customer_42cb94ee-ec07-4d33-88ed-9d49659e68be', -- 0
        source_language := language_type,
        source_text := customer_name
    )
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
  ins_worker text[];
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

  select array_agg(t.id) into ins_worker
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
  return query select ' +worker', w from unnest(ins_worker) as t(w);

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
               where s.systagtype = 'Trackable'
  ;
  --
  if not found then
    raise exception 'failed to create template type';
  end if;

  -- return query select '+constraint', t.id
  --              from util.create_template_constraint_foreach_child_location(
  --                  template_id := ins_template,
  --                  location_parent_id := location_id
  --              ) as t
  -- ;
  --
  -- if not found then
  --   raise exception 'failed to create template constraints for child locations';
  -- end if;

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
  --

  <<loop0>>
  foreach loop0_t in array ins_location loop
    return query
      with
          log as (
              values (' +location', loop0_t)
          ),

          ins_constraint as (
              select '  +constraint', t.id
              from util.create_template_constraint_on_location(
                  template_id := ins_template,
                  location_id := loop0_t
              ) as t
          )

      select * from log
      union all
      select * from ins_constraint
    ;
  end loop loop0;

  return;
end $$
language plpgsql
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


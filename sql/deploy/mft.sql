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
        customer_id := 'customer_42cb94ee-ec07-4d33-88ed-9d49659e68be',
        source_language := language_type,
        source_text := customer_name
    )
  )
  insert into public.customer (
      customeruuid,
      customername,
      customerlanguagetypeid,
      customerlanguagetypeuuid,
      customernamelanguagemasterid
  )
  select
      'customer_a9d514cc-472d-47b6-875c-dccb51818f38',
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

create function
    mft.create_tracking_system(customer_id text, language_type text, location_id text)
returns table(action text, id text)
as $$
declare
  ins_root text;
begin
  select t.id into ins_root
  from util.create_task_t(
      customer_id := customer_id,
      language_type := language_type,
      task_name := 'Run',
      task_parent_id := location_id
  ) as t;
  return query select '+task', ins_root;

  -- opt this template into tracking
  return query select '+tag', t.id
               from public.systag as s
               cross join lateral util.create_template_type(
                   template_id := ins_root,
                   systag_id := s.systaguuid
               ) as t
               where s.systagtype = 'Trackable'
  ;

  -- create a template constraint at each trackable location beneath
  -- `location_id` for this template
  return query select '+constraint', t.id
               from util.create_template_constraint_foreach_child_location(
                   template_id := ins_root,
                   location_parent_id := location_id
               ) as t
  ;

  if not found then
    raise exception 'failed to create template constraints for child locations';
  end if;

  return;
end $$
language plpgsql
strict
;

comment on function mft.create_tracking_system is $$

# mft.create_tracking_system

## usage

```sql
select *
from mft.create_tracking_system(
    customer_id := 'your customer uuid',
    language_type := 'en',
    task_name := 'some task i want to start tracking',
    task_parent_id := 'my site uuid'
);
```

## description

Creates a "tracking system" at the given customer and site. The name of the root
task in the tracking system is specified via the `task_name` argument. The
`language_type` argument, as usual, indicates the source language for all
localized content created as a result of this function call, most notably the
`task_name` argument (which is destined for languagemaster).

TOMORROW: pick up here!

$$
;

create function mft.create_demo(customer_name text, admins text[])
returns table(action text, id text)
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
  ins_root_task_t text;
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
  return query select '+worker', w from unnest(ins_worker) as t(w);

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
  return query select ' +location', l from unnest(ins_location) as t(l);

  return query select *
               from mft.create_tracking_system(
                   customer_id := ins_customer,
                   language_type := default_language_type,
                   location_id := ins_site
               )
  ;
  if not found then
    raise exception 'failed to create tracking system';
  end if;

  return
  ;
end $$
language plpgsql
;

commit
;


-- noqa: disable=AM04,CV06
--
-- NOTE: this is a work-in-progress collection of utilities for the test suite.
--
begin
;

create schema if not exists util;

drop function if exists util.inspect
;

create function util.inspect(r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: %', r;
  return r;
end $$
language plpgsql
;

comment on function util.inspect is $$

# util.inspect

Log $1 and then return it.

Usage:

```sql
select util.inspect(foo.id) as id from foo;

NOTICE:  inspect: 1007
NOTICE:  inspect: 1008
NOTICE:  inspect: 1009
  id
------
 1007
 1008
 1009
(3 rows)
```

$$;

drop function if exists util.inspect_t
;

create function util.inspect_t(t text, r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: % := %', t, r;
  return r;
end $$
language plpgsql
;

comment on function util.inspect_t is $$

# util.inspect_t

Log $1 and $2, then return $2. This is the tagged version of `util.inspect`.

Usage:

```sql
select util.inspect_t('foo.id', foo.id)
from foo;
-- NOTICE:  inspect: foo.id := 1007
-- NOTICE:  inspect: foo.id := 1008
-- NOTICE:  inspect: foo.id := 1009
```

$$;

drop function if exists util.create_user_type
;

create function
    util.create_user_type(
        customer_id text, language_type text, type_name text, type_hierarchy text
    )
returns table(_id bigint, id text)
as $$
  with ins_type as (
    insert into public.custag (
      custagcustomerid,
      custagsystagid,
      custagtype
    )
    select
      c.customerid,
      s.systagid,
      type_name
    from public.customer as c, public.systag as s
    where c.customeruuid = customer_id and s.systagtype = type_hierarchy
    on conflict do nothing
    returning custagid as _id, custaguuid as id
  )

  select *
  from ins_type
  union all
  select custagid as _id, custaguuid as id
  from public.custag
  where
      custagcustomerid = (
          select customerid
          from public.customer
          where customeruuid = customer_id
      )
      and custagsystagid = (
          select systagid
          from public.systag
          where systagtype = type_hierarchy
      )
      and custagtype = type_name
  ;
$$
language sql
strict
;

drop function if exists util.create_name
;

create function
    util.create_name(customer_id text, source_language text, source_text text)
returns table(_id bigint, id text)
as $$
  insert into public.languagemaster (
    languagemastercustomerid,
    languagemastersourcelanguagetypeid,
    languagemastersource
  )
  select
    c.customerid,
    s.systagid,
    source_text
  from public.customer as c, public.systag as s
  where
    c.customeruuid = customer_id
    and s.systagparentid = 2
    and s.systagtype = source_language
  returning languagemasterid as _id, languagemasteruuid as id;
$$
language sql
strict  -- null on null input
;

drop function if exists util.create_location
;

create function
    util.create_location(
        customer_id text,
        language_type text,
        location_name text,
        location_parent_id text,
        location_typename text,
        location_type_hierarchy text,
        location_timezone text
    )
returns table(_id bigint, id text)
as $$
declare
  ins_location text;
begin
  with ins_name as (
    select *
    from util.create_name(
        customer_id := customer_id,
        source_language := language_type,
        source_text := location_name
    )
  ),

  location_type as (
    select *
    from util.create_user_type(
        customer_id := customer_id,
        language_type := language_type,
        type_name := location_typename,
        type_hierarchy := location_type_hierarchy
    )
  )

  insert into public.location (
    locationcustomerid,
    locationsiteid,
    locationistop,
    locationiscornerstone,
    locationcornerstoneorder,
    locationcategoryid,
    locationnameid,
    locationtimezone
  )
  select
    c.customerid,
    p.locationid,
    location_parent_id is null,
    false,
    0,
    util.inspect_t('location_type._id', location_type._id),
    ins_name._id,
    location_timezone
  from public.customer as c, ins_name, location_type
  left join public.location as p
    on p.locationuuid = location_parent_id
  where c.customeruuid = customer_id
  returning locationuuid into ins_location
  ;

  if not found then
    raise exception 'failed to create location';
  end if;

  return query select locationid as _id, locationuuid as id
               from public.location
               where locationuuid = ins_location
  ;

  -- the following is a datawarehouse invariant;
  update public.location
  set locationsiteid = locationid
  where locationuuid = ins_location and location_parent_id is null
  ;

  return;
end $$
language plpgsql
;

drop function if exists util.create_task_t
;

create function
    util.create_task_t(
        customer_id text, language_type text, task_name text, task_parent_id text
    )
returns table(_id bigint, id text)
as $$
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
    -- FIXME: implement scheduling, auditing
    true,
    1404,
    false
  from public.customer, public.location, ins_name
  where customer.customeruuid = customer_id and location.locationuuid = task_parent_id
  returning worktemplate.worktemplateid as _id, worktemplate.id
  ;
$$
language sql
strict
;

drop function if exists util.create_template_type
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

drop function if exists util.create_template_constraint_foreach_child_location
;

create function
    util.create_template_constraint_foreach_child_location(
        template_id text, location_id text
    )
returns table(id text)
as
    $$
  insert into public.worktemplateconstraint (
      worktemplateconstraintcustomerid,
      worktemplateconstrainttemplateid,
      worktemplateconstraintconstrainedtypeid,
      worktemplateconstraintconstraintid
  )
  select
      t.worktemplatecustomerid,
      t.id,
      tt.worktemplatetypesystaguuid,
      lt.custaguuid
  from public.worktemplate as t
  inner join public.worktemplatetype as tt on t.worktemplateid = tt.worktemplatetypeworktemplateid
  inner join public.location as l
      on l.locationparentid = (
          select p.locationid
          from public.location as p
          where p.locationuuid = location_id
      )
  inner join public.custag as lt on l.locationcategoryid = lt.custagid
  where t.id = template_id
  returning worktemplateconstraintid as id
  ;
$$
language sql
strict
;

create schema if not exists mft;

drop function if exists mft.create_customer
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

drop function if exists mft.create_worker
;

create function mft.create_worker(customer_id text, user_id text, user_role text)
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
      workerinstanceuserroleuuid
  )
  select
      c.customerid,
      c.customeruuid,
      u.workerid,
      u.workeruuid,
      l.systagid,
      l.systaguuid,
      r.systagid,
      r.systaguuid
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

drop function if exists mft.create_location
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

  if not found then
    raise exception 'failed to create location';
  end if;

  return;
end $$
language plpgsql
strict
;

drop function if exists mft.create_tracking_system
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
                   location_id := location_id
               ) as t
  ;

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

$$;

drop function if exists mft.create_demo
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
      lateral mft.create_worker(
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
  return query select '+location', l from unnest(ins_location) as t(l);

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
--
-- test
--
begin
;

select *
from
    mft.create_demo(
        customer_name := 'Frozen Tendy Factory',
        admins := array[
            'worker_d3ebf472-606c-4d26-9a19-d99f187e9c92',
            'worker_a5d1d16f-4264-45e7-97c6-1ef534b8875f'
        ]
    )
;

commit
;

--
-- cleanup
--
begin
;

delete from public.worktemplateconstraint
where worktemplateconstraintcustomerid > 99
;

delete from public.worktemplatetype
where worktemplatetypecustomerid > 99
;

delete from public.customer
where customerid > 99
;

commit
;

-- check all nontrigger plpgsql functions
select p.oid, p.proname, plpgsql_check_function(p.oid)
from pg_catalog.pg_namespace n
join pg_catalog.pg_proc p on pronamespace = n.oid
join pg_catalog.pg_language l on p.prolang = l.oid
where l.lanname = 'plpgsql' and p.prorettype <> 2279 and n.nspname in ('util', 'mft')
;


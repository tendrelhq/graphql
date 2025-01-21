-- Deploy graphql:location to pg
-- requires: udt
-- requires: name
begin
;

-- fmt: off
create function
    util.create_location(
        customer_id text,
        -- identity_id text,
        language_type text,
        location_name text,
        location_parent_id text,
        location_typename text,
        location_type_hierarchy text,
        location_timezone text
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
    from util.create_name(
        customer_id := customer_id,
        -- identity_id := identity_id,
        source_language := language_type,
        source_text := location_name
    )
  ),

  location_type as (
    select *
    from util.create_user_type(
        customer_id := customer_id,
        -- identity_id := identity_id,
        language_type := language_type,
        type_name := location_typename,
        type_hierarchy := location_type_hierarchy
    )
  )

  insert into public.location (
      locationcustomerid,
      locationsiteid,
      locationparentid,
      locationistop,
      locationiscornerstone,
      locationcornerstoneorder,
      locationcategoryid,
      locationnameid,
      locationtimezone,
      locationmodifiedby
  )
  select
      c.customerid,
      p.locationsiteid,
      p.locationid,
      location_parent_id is null,
      false,
      0,
      location_type._id,
      ins_name._id,
      location_timezone,
      null -- TODO: modified by
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

commit
;

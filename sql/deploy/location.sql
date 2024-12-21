-- Deploy graphql:location to pg
-- requires: udt
-- requires: name
begin
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

commit
;


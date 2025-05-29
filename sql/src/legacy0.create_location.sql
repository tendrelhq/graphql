BEGIN;

/*
DROP FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint);
*/


-- Type: FUNCTION ; Name: legacy0.create_location(text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_location(customer_id text, language_type text, location_name text, location_parent_id text, location_timezone text, location_typename text, modified_by bigint)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
AS $function$
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
    from i18n.create_localized_content(
        owner := customer_id,
        content := location_name,
        language := language_type
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

  -- invariant: locationparentid must not be null
  update public.location
  set locationparentid = locationid
  where locationuuid = ins_location and locationparentid is null
  ;

  -- invariant: locationcornerstoneid must not be null
  update public.location
  set locationcornerstoneid = locationid
  where locationuuid = ins_location and locationcornerstoneid is null
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_location(text,text,text,text,text,text,bigint) TO graphql;

END;

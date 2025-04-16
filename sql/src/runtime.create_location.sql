
-- Type: FUNCTION ; Name: runtime.create_location(text,bigint,text,text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION runtime.create_location(customer_id text, modified_by bigint, language_type text, timezone text, location_name text, location_parent_id text, location_typename text)
 RETURNS TABLE(_id bigint, id text)
 LANGUAGE plpgsql
 STRICT
AS $function$
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
end $function$;


REVOKE ALL ON FUNCTION runtime.create_location(text,bigint,text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.create_location(text,bigint,text,text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION runtime.create_location(text,bigint,text,text,text,text,text) TO tendreladmin WITH GRANT OPTION;

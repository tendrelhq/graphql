
-- Type: FUNCTION ; Name: api.fields(api.z_20250407_instance); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.fields(api.z_20250407_instance)
 RETURNS SETOF api.z_20250409_instance_field
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  select *
  from api.instance_field
  where instance = $1.id;
$function$;


REVOKE ALL ON FUNCTION api.fields(api.z_20250407_instance) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.fields(api.z_20250407_instance) TO tendreladmin WITH GRANT OPTION;

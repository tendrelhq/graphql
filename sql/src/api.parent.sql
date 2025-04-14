
-- Type: FUNCTION ; Name: api.parent(api.z_20250409_instance_field); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.parent(api.z_20250409_instance_field)
 RETURNS SETOF api.z_20250407_instance
 LANGUAGE sql
 STABLE SECURITY DEFINER ROWS 1
AS $function$
  select *
  from api.instance
  where id = $1.instance;
$function$;


REVOKE ALL ON FUNCTION api.parent(api.z_20250409_instance_field) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.parent(api.z_20250409_instance_field) TO tendreladmin WITH GRANT OPTION;


-- Type: FUNCTION ; Name: api.type(api.z_20250409_template_field); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.type(api.z_20250409_template_field)
 RETURNS SETOF api.z_20250407_instance
 LANGUAGE sql
 STABLE SECURITY DEFINER ROWS 1
AS $function$
  select *
  from api.instance
  where id = $1.type_id;
$function$;


REVOKE ALL ON FUNCTION api.type(api.z_20250409_template_field) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.type(api.z_20250409_template_field) TO tendreladmin WITH GRANT OPTION;

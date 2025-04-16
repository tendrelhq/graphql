
-- Type: FUNCTION ; Name: api.display_name(api.z_20250407_instance); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.display_name(api.z_20250407_instance)
 RETURNS SETOF api.localized
 LANGUAGE sql
 STABLE SECURITY DEFINER ROWS 1
AS $function$
  select n.*
  from
      api.template as t,
      api.display_name(t.*) as n
  where t.id = $1.template;
$function$;


REVOKE ALL ON FUNCTION api.display_name(api.z_20250407_instance) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.display_name(api.z_20250407_instance) TO tendreladmin WITH GRANT OPTION;

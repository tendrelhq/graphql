
-- Type: FUNCTION ; Name: api.template(api.z_20250409_instance_field); Owner: bombadil

CREATE OR REPLACE FUNCTION api.template(api.z_20250409_instance_field)
 RETURNS SETOF api.z_20250409_template_field
 LANGUAGE sql
 STABLE SECURITY DEFINER ROWS 1
AS $function$
  select *
  from api.template_field
  where id = $1.template;
$function$;


REVOKE ALL ON FUNCTION api.template(api.z_20250409_instance_field) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.template(api.z_20250409_instance_field) TO bombadil WITH GRANT OPTION;

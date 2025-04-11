
-- Type: FUNCTION ; Name: api.z_20250409_update_template_field(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.z_20250409_update_template_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  raise sqlstate 'PT405' using detail = 'not yet implemented';
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_update_template_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_update_template_field() TO bombadil WITH GRANT OPTION;


-- Type: FUNCTION ; Name: api.z_20250409_delete_template_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.z_20250409_delete_template_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  del_row api.template_field%rowtype;
begin
  call entity.crud_entityfield_delete(
      create_entityfieldownerentityuuid := old.owner,
      create_entityfieldentityuuid := old.id,
      create_modifiedbyid := 895
  );

  select * into del_row
  from api.template_field
  where id = old.id;

  return del_row;
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_delete_template_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_delete_template_field() TO tendreladmin WITH GRANT OPTION;

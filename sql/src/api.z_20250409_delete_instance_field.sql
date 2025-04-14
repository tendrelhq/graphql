
-- Type: FUNCTION ; Name: api.z_20250409_delete_instance_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.z_20250409_delete_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  del_row api.instance_field%rowtype;
begin
  call entity.crud_entityfieldinstance_delete(
      create_entityfieldinstanceownerentityuuid := old.owner,
      create_entityfieldinstanceentityuuid := old.id,
      create_modifiedbyid := 895
  );

  select * into del_row
  from api.instance_field
  where id = old.id;

  return del_row;
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_delete_instance_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_delete_instance_field() TO tendreladmin WITH GRANT OPTION;

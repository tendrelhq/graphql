
-- Type: FUNCTION ; Name: api.z_20250409_delete_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.z_20250409_delete_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  del_row api.instance%rowtype;
begin
  call entity.crud_entityinstance_delete(
    create_entityinstanceownerentityuuid := old.owner,
    create_entityinstanceentityuuid := old.id,
    create_modifiedbyid := 895
  );

  select * into del_row
  from api.instance
  where id = old.id;

  return del_row;
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_delete_instance() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_delete_instance() TO tendreladmin WITH GRANT OPTION;

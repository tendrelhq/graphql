
-- Type: FUNCTION ; Name: api.create_entity_instance_file(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.create_entity_instance_file()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_file%rowtype;
begin
	call entity.crud_entityfileinstance_create(
		create_entityfileinstanceownerentityuuid := new.owner, 
		create_entityfileinstanceentityentityinstanceentityuuid := new.instance, 
		create_entityfileinstanceentityfieldinstanceentityuuid := new.field_instance, 
		create_entityfileinstancestoragelocation := new.file_link, 
		create_entityfileinstancemimetypeuuid := new.file_mime_type, 
		create_languagetypeuuid := null::uuid,  -- wire this in later
		create_entityfileinstancedeleted := new._deleted, 
		create_entityfileinstancedraft := new._draft, 
		create_entityfileinstanceentityuuid := ins_entity, 
		create_modifiedbyid := 895  -- wire this in later
  );

  select * into ins_row
  from api.entity_instance_file
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_instance_file() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_file() TO bombadil WITH GRANT OPTION;

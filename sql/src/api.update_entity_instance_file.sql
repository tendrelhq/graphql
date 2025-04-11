
-- Type: FUNCTION ; Name: api.update_entity_instance_file(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.update_entity_instance_file()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_file%rowtype;
begin

if old.id = new.id 
	then 
		call entity.crud_entityfileinstance_update(
			update_entityfileinstanceentityuuid := new.id,
			update_entityfileinstanceownerentityuuid := new.owner,
			update_entityfileinstanceentityentityinstanceentityuuid := new.instance,
			update_entityfileinstanceentityfieldinstanceentityuuid := new.field_instance,
			update_entityfileinstancestoragelocation := new.file_link,
			update_entityfileinstancemimetypeuuid := new.file_mime_type,
			update_entityfileinstancedeleted := new._deleted,
			update_entityfileinstancedraft := new._draft,
			update_entityfileinstancemodifiedbyuuid := null::text,
			update_languagetypeuuid := null::uuid
		);

end if;

  select * into ins_row
  from api.entity_instance_file
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_instance_file() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_file() TO bombadil WITH GRANT OPTION;


-- Type: FUNCTION ; Name: api.update_entity_instance_field(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.update_entity_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_field%rowtype;
begin

if old.id = new.id 
	then 
		call entity.crud_entityfieldinstance_update(
			update_entityfieldinstanceentityuuid := new.id,
			update_entityfieldinstanceownerentityuuid := new.owner,
			update_entityfieldinstanceentityinstanceentityuuid := new.instance,
			update_entityfieldinstanceentityfieldentityuuid := new.field,
			update_entityfieldinstancevalue := new.value,
			update_entityfieldinstanceentityfieldname := null::text,
			update_entityfieldinstanceexternalid := null::text,
			update_entityfieldinstanceexternalsystemuuid := null::uuid,
			update_entityfieldinstancedeleted := new._deleted,
			update_entityfieldinstancedraft := new._draft,
			update_entityfieldinstancestartdate := new.activated_at,
			update_entityfieldinstanceenddate := new.deactivated_at,
			update_entityfieldinstancemodifiedbyuuid := null::text,
			update_languagetypeuuid := null::uuid
		);



end if;

  select * into ins_row
  from api.entity_instance_field
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_instance_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_field() TO bombadil WITH GRANT OPTION;

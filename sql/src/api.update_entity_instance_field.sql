
-- Type: FUNCTION ; Name: api.update_entity_instance_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_field%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
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
	else  
		return null;
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
GRANT EXECUTE ON FUNCTION api.update_entity_instance_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_field() TO authenticated;

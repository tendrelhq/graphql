BEGIN;

/*
DROP TRIGGER update_entity_instance_file_tg ON api.entity_instance_file;

DROP FUNCTION api.update_entity_instance_file();
*/


-- Type: FUNCTION ; Name: api.update_entity_instance_file(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_instance_file()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_file%rowtype;
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
		call entity.crud_entityfileinstance_update(
			update_entityfileinstanceentityuuid := new.id,
			update_entityfileinstanceownerentityuuid := new.owner,
			update_entityfileinstanceentityentityinstanceentityuuid := new.instance,
			update_entityfileinstanceentityfieldinstanceentityuuid := new.field_instance,
			update_entityfileinstancestoragelocation := new.file_link,
			update_entityfileinstancemimetypeuuid := new.file_mime_type,
			update_entityfileinstancedeleted := new._deleted,
			update_entityfileinstancedraft := new._draft,
			update_entityfileinstancemodifiedbyuuid := ins_useruuid,
			update_languagetypeuuid := ins_languagetypeentityuuid
		);
	else  
		return null;
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
GRANT EXECUTE ON FUNCTION api.update_entity_instance_file() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_instance_file() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER update_entity_instance_file_tg INSTEAD OF UPDATE ON api.entity_instance_file FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance_file();


END;

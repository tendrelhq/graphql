BEGIN;

/*
DROP TRIGGER update_entity_instance_tg ON api.entity_instance;

DROP FUNCTION api.update_entity_instance();
*/


-- Type: FUNCTION ; Name: api.update_entity_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance%rowtype;
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
		call entity.crud_entityinstance_update(
			update_entityinstanceentityuuid := new.id,
			update_entityinstanceownerentityuuid := new.owner,
			update_entityinstanceentitytemplateentityuuid := new.template,
			update_entityinstanceentitytemplateentityname := null::text,
			update_entityinstanceparententityuuid := new.parent,
			update_entityinstanceecornerstoneentityuuid := new.cornerstone,
			update_entityinstancecornerstoneorder := new._order,
			update_entityinstancename := new.name,
			update_entityinstancenameuuid := new.name_id,
			update_entityinstancescanid := new.scan_code,
			update_entityinstancetypeuuid := new.type,
			update_entityinstanceexternalid := new.external_id,
			update_entityinstanceexternalsystemuuid := new.external_system,
			update_entityinstancedeleted := new._deleted,
			update_entityinstancedraft := new._draft,
			update_entityinstancestartdate := new.activated_at,
			update_entityinstanceenddate := new.deactivated_at,
			update_entityinstancemodifiedbyuuid := null::text,
			update_languagetypeuuid := null::uuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_instance
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_instance() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_instance() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_instance() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER update_entity_instance_tg INSTEAD OF UPDATE ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.update_entity_instance();


END;

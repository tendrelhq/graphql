BEGIN;

/*
DROP TRIGGER create_entity_instance_tg ON api.entity_instance;

DROP FUNCTION api.create_entity_instance();
*/


-- Type: FUNCTION ; Name: api.create_entity_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance%rowtype;
    	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;


if (select new.owner in (select * from _api.util_get_onwership()))
	then
  call entity.crud_entityinstance_create(
      create_entityinstanceownerentityuuid := new.owner,
      create_entityinstanceentitytemplateentityuuid := new.template,
      create_entityinstanceentitytemplateentityname := null::text,   -- save for an all in rpc
      create_entityinstanceparententityuuid := new.parent,
      create_entityinstanceecornerstoneentityuuid := new.cornerstone,  
      create_entityinstancecornerstoneorder := new._order,
      create_entityinstancetaguuid := null::uuid,   -- save for an all in rpc
      create_entityinstancetag := null::text,   -- save for an all in rpc
      create_entityinstancename := new.name,
      create_entityinstancescanid := new.scan_code,
      create_entityinstancetypeuuid := new.type,
      create_entityinstanceexternalid := new.external_id,
      create_entityinstanceexternalsystemuuid := new.external_system,
      create_entityinstancedeleted := new._deleted,
      create_entityinstancedraft := new._draft,
      create_languagetypeuuid := ins_languagetypeentityuuid,  
      create_modifiedbyid := ins_userid,  
      create_entityinstanceentityuuid := ins_entity
  );
end if;

  select * into ins_row
  from api.entity_instance
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_instance() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_instance() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_instance() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_entity_instance_tg INSTEAD OF INSERT ON api.entity_instance FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance();


END;

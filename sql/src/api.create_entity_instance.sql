
-- Type: FUNCTION ; Name: api.create_entity_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance%rowtype;
begin
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

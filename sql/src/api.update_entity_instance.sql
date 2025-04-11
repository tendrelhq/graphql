
-- Type: FUNCTION ; Name: api.update_entity_instance(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.update_entity_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance%rowtype;
begin


if old.id = new.id 
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
GRANT EXECUTE ON FUNCTION api.update_entity_instance() TO bombadil WITH GRANT OPTION;

BEGIN;

/*
DROP TRIGGER update_entity_template_tg ON api.entity_template;

DROP FUNCTION api.update_entity_template();
*/


-- Type: FUNCTION ; Name: api.update_entity_template(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_template%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entitytemplate_update(
		    update_entitytemplateuuid := new.id, 
		    update_entitytemplateownerentityuuid := new.owner, 
		    update_entitytemplateparententityuuid := new.parent,	
		    update_entitytemplateexternalid := new.external_id,
		    update_entitytemplateexternalsystementityuuid := new.external_system,
		    update_entitytemplatescanid := new.scan_code,
		    update_entitytemplatenameuuid := new.name_id,
		    update_entitytemplatename := new.name,
		    update_entitytemplateorder := new._order,
		    update_entitytemplateisprimary := new._primary,
		    update_entitytemplatetypeentityuuid := new.type,
		    update_entitytemplatedeleted := new._deleted,
		    update_entitytemplatedraft := new._draft,
		    update_entitytemplatestartdate := new.activated_at,
		    update_entitytemplateenddate := new.deactivated_at,
		    update_entitytemplatemodifiedbyuuid := ins_useruuid,  
			update_languagetypeuuid :=  ins_languagetypeentityuuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_template
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_template() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_template() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER update_entity_template_tg INSTEAD OF UPDATE ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.update_entity_template();


END;

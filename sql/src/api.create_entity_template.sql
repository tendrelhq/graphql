BEGIN;

/*
DROP TRIGGER create_entity_template_tg ON api.entity_template;

DROP FUNCTION api.create_entity_template();
*/


-- Type: FUNCTION ; Name: api.create_entity_template(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_template%rowtype;
  	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;

begin

-- only tendrel can have primary templates

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;
	
if (select new.owner in (select * from _api.util_get_onwership()) )
	then
	  call entity.crud_entitytemplate_create(
	      create_entitytemplatecornerstoneorder := new._order,   
	      create_entitytemplatedeleted := false, 
	      create_entitytemplatedraft := new._draft,  
	      create_entitytemplateexternalid := new.external_id,  
	      create_entitytemplateexternalsystemuuid := new.external_system,  
	      create_entitytemplateisprimary := new._primary, 
	      create_entitytemplatename := new.name,  
	      create_entitytemplateownerentityuuid := new.owner, 
	      create_entitytemplateparententityuuid := new.parent, 
	      create_entitytemplatescanid := new.scan_code,  
	      create_entitytemplatetag := null::text,  -- save for an all in rpc
	      create_entitytemplatetaguuid := null::uuid, -- save for an all in rpc
	      create_languagetypeuuid := ins_languagetypeentityuuid,  -- Fix this later
	      create_modifiedbyid :=ins_userid,  -- Fix this later
	      create_entitytemplateentityuuid := ins_entity
	  );
end if;

  select * into ins_row
  from api.entity_template
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_entity_template_tg INSTEAD OF INSERT ON api.entity_template FOR EACH ROW EXECUTE FUNCTION api.create_entity_template();


END;

BEGIN;

/*
DROP TRIGGER create_entity_description_tg ON api.entity_description;

DROP FUNCTION api.create_entity_description();
*/


-- Type: FUNCTION ; Name: api.create_entity_description(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_description()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_description%rowtype;
    ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;

begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	call entity.crud_entitydescription_create(
		create_entitydescriptionownerentityuuid  := new.owner, 
		create_entitytemplateentityuuid  := new.template, 
		create_entityfieldentityuuid  := new.field, 
		create_entitydescriptionname  := new.description, 
		create_entitydescriptionsoplink  := new.sop_link, 
		create_entitydescriptionfile  := new.file_link, 
		create_entitydescriptionicon  := new.icon_link, 
		create_entitydescriptionmimetypeuuid  := new.file_mime_type, 
		create_languagetypeuuid  := ins_languagetypeentityuuid, 
		create_entitydescriptiondeleted  := false, 
		create_entitydescriptiondraft  := new._draft,  
		create_entitydescriptionentityuuid  := ins_entity, 
		create_modifiedbyid :=ins_userid  
  	);
end if;

  select * into ins_row
  from api.entity_description
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_description() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_entity_description_tg INSTEAD OF INSERT ON api.entity_description FOR EACH ROW EXECUTE FUNCTION api.create_entity_description();


END;

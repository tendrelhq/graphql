
-- Type: FUNCTION ; Name: api.update_entity_description(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_description()
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

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entitydescription_update(
			update_entitydescriptionuuid := new.id,
			update_entitydescriptionownerentityuuid := new.owner,
			update_entitydescriptionentitytemplateentityuuid := new.template,
			update_entitydescriptionentityfieldentityuuid := new.field,
			update_entitydescriptionname := new.description,
			update_entitydescriptionsoplink := new.sop_link,
			update_entitydescriptionfile := new.file_link,
			update_entitydescriptionicon := new.icon_link,
			update_entitydescriptionmimetypeuuid := new.file_mime_type,
			update_entitydescriptionexternalid := new.external_id,
			update_entitydescriptionexternalsystementityuuid := new.external_system,
			update_entitydescriptiondeleted := new._deleted,
			update_entitydescriptiondraft := new._draft,
			update_entitydescriptionstartdate := new.activated_at,
			update_entitydescriptionenddate := new.deactivated_at,	
			update_entitydescriptionmodifiedbyuuid := null::text,
			update_languagetypeuuid := null::uuid
			);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_description
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_description() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_description() TO PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_description() TO tendreladmin WITH GRANT OPTION;

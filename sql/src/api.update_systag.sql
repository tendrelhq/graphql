
-- Type: FUNCTION ; Name: api.update_systag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_systag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.systag%rowtype;
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
		call entity.crud_systag_update(
			update_systagentityuuid := new.id,
			update_systagownerentityuuid := new.owner,
			update_systagparententityuuid := new.parent,
			update_systagcornerstoneentityuuid := new.cornerstone,
			update_systagcornerstoneorder := new._order,
			update_systag := new.type,
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_systagexternalid := new.external_id,
			update_systagexternalsystemuuid := new.external_system,
			update_systagdeleted := new._deleted,
			update_systagdraft := new._draft,
			update_systagstartdate := new.activated_at,
			update_systagenddate := new.deactivated_at,
			update_systagmodifiedbyuuid := ins_useruuid);
	else  
		return null;
end if;

  select * into ins_row
  from api.systag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_systag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_systag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_systag() TO authenticated;

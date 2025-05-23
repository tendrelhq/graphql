
-- Type: FUNCTION ; Name: api.update_custag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_custag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.custag%rowtype;
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
		call entity.crud_custag_update(
			update_custagentityuuid := new.id,
			update_custagownerentityuuid := new.owner,
			update_custagparententityuuid := new.parent,
			update_custagcornerstoneentityuuid := new.cornerstone,
			update_custagcornerstoneorder := new._order,
			update_custag := new.type,
			update_custag_name := new.name,
			update_custag_displayname := new.displayname,	
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_custagexternalid := new.external_id,
			update_custagexternalsystemuuid := new.external_system,
			update_custagdeleted := new._deleted,
			update_custagdraft := new._draft,
			update_custagstartdate := new.activated_at,
			update_custagenddate := new.deactivated_at,
			update_custagmodifiedbyuuid := ins_useruuid);
	else  
		return null;
end if;

  select * into ins_row
  from api.custag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_custag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_custag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_custag() TO authenticated;

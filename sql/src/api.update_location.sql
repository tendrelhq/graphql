
-- Type: FUNCTION ; Name: api.update_location(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_location()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.location%rowtype;
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
		call entity.crud_location_update(
			update_locationentityuuid := new.id, 
			update_locationownerentityuuid := new.owner, 
			update_locationparententityuuid := new.parent, 
			update_locationcornerstoneentityuuid := new.cornerstone, 
			update_locationcornerstoneorder := new._order, 
			update_locationtaguuid := null::uuid, 
			update_locationtag := null::text, 
			update_locationname := new.name, 
			update_locationdisplayname := new.displayname, 
			update_locationscanid := new.scan_code, 
			update_locationtimezone := new.timezone, 
			update_languagetypeuuid := ins_languagetypeentityuuid, 
			update_locationexternalid := new.external_id, 
			update_locationexternalsystemuuid := new.external_system, 
			update_locationlatitude := (new.latitude)::text, 
			update_locationlongitude := new.longitude::text, 
			update_locationradius := new.radius::text, 
			update_locationstartdate := new.activated_at, 
			update_locationenddate := new.deactivated_at, 
			update_locationdeleted := new._deleted, 
			update_locationdraft := new._draft, 
			update_modifiedby := ins_useruuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.location
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_location() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_location() TO PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_location() TO tendreladmin WITH GRANT OPTION;

BEGIN;

/*
DROP TRIGGER create_location_tg ON api.location;

DROP FUNCTION api.create_location();
*/


-- Type: FUNCTION ; Name: api.create_location(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_location()
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

if (select new.owner in (select * from _api.util_get_onwership()) )
	then
	  call entity.crud_location_create(
	  		create_locationownerentityuuid := new.owner, 
			create_locationparententityuuid := new.parent, 
			create_locationcornerstoneentityuuid := new.cornerstone,  
			create_locationcornerstoneorder := new._order,  
			create_locationtaguuid := null::uuid,  
			create_locationtag := null::text,  
			create_locationname := new.name, 
			create_locationdisplayname := new.displayname, 
			create_locationscanid := new.scan_code, 
			create_locationtimezone := new.timezone, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_locationexternalid := new.external_id, 
			create_locationexternalsystemuuid := new.external_system, 
			create_locationlatitude := new.latitude::text, 
			create_locationlongitude := new.longitude::text, 
			create_locationradius := new.radius::text, 
			create_locationdeleted := new._deleted, 
			create_locationdraft := new._draft, 
			create_locationentityuuid := ins_entity, 
			create_modifiedbyid := ins_userid  
	  );
	else
		return null;  -- need an exception here
end if;
			


  select * into ins_row
  from api.location
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_location() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_location() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_location() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_location_tg INSTEAD OF INSERT ON api.location FOR EACH ROW EXECUTE FUNCTION api.create_location();


END;

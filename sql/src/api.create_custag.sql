
-- Type: FUNCTION ; Name: api.create_custag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_custag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_bigint bigint;
  ins_text text;
  ins_entity uuid;
  ins_row api.custag%rowtype;
 	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	ins_customerentityuuid uuid;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid);

  call entity.crud_custag_create(
  		create_custagownerentityuuid := ins_customerentityuuid, 
		create_custagparententityuuid := new.parent, 
		create_custagcornerstoneentityuuid := new.cornerstone, 
		create_custagcornerstoneorder := new._order, 
		create_custag := new.type, 
		create_languagetypeuuid := ins_languagetypeentityuuid, 
		create_custagexternalid := new.external_id, 
		create_custagexternalsystemuuid := new.external_system,
		create_custagdeleted := new._deleted, 
		create_custagdraft := new._draft, 
		create_custagid := ins_bigint, 
		create_custaguuid := ins_text, 
		create_custagentityuuid := ins_entity, 
		create_modifiedbyid := ins_userid  
  );

  select * into ins_row
  from api.custag
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_custag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_custag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_custag() TO authenticated;

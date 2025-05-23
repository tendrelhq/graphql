
-- Type: FUNCTION ; Name: api.create_systag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_systag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_bigint bigint;
  ins_text text;
  ins_entity uuid;
  ins_row api.systag%rowtype;
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

if (select new.owner in (select * from _api.util_get_onwership()))
	then
		call entity.crud_systag_create(
			create_systagownerentityuuid := new.owner, 
			create_systagparententityuuid := new.parent, 
			create_systagcornerstoneentityuuid := new.cornerstone, 
			create_systagcornerstoneorder := new._order, 
			create_systag := new.type, 
			create_languagetypeuuid := ins_languagetypeentityuuid, 
			create_systagexternalid := new.external_id, 
			create_systagexternalsystemuuid := new.external_system,
			create_systagdeleted := new._deleted, 
			create_systagdraft := new._draft, 
			create_systagid := ins_bigint, 
			create_systaguuid := ins_text, 
			create_systagentityuuid := ins_entity, 
			create_modifiedbyid :=ins_userid  
			  );
end if;

  select * into ins_row
  from api.systag
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_systag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_systag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_systag() TO authenticated;

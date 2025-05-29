BEGIN;

/*
DROP TRIGGER create_customer_tg ON api.customer;

DROP FUNCTION api.create_customer();
*/


-- Type: FUNCTION ; Name: api.create_customer(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_customer()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_entity uuid;
	ins_row api.customer%rowtype;
	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();


select customerentityuuid
into ins_customerentityuuid
from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
where customerid = (select workerinstancecustomerid from workerinstance where workerinstanceid = ins_userid)   ;



if new.parent isNull 
	then new.parent = ins_customerentityuuid;
end if;

if (select new.parent in (select * from _api.util_get_onwership())) or (new.parent isNull)
	then
		call entity.crud_customer_create(
			create_customername := new.name,
			create_customeruuid := ins_customeruuid, 
			create_customerentityuuid := ins_entity, 
			create_customerparentuuid := new.parent,  
			create_customerowner := null::uuid,  
			create_customerbillingid :=  new.external_id,  
			create_customerbillingsystemid := new.external_system, 
			create_customerdeleted := new._deleted, 
			create_customerdraft := new._draft, 
			create_languagetypeuuids := Array[ins_languagetypeentityuuid],  
			create_modifiedby := ins_userid  
	  );
	else
		return null;  -- need an exception here
end if;

  select * into ins_row
  from api.customer
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_customer() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_customer() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_customer() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_customer_tg INSTEAD OF INSERT ON api.customer FOR EACH ROW EXECUTE FUNCTION api.create_customer();


END;

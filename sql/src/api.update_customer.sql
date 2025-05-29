BEGIN;

/*
DROP TRIGGER update_customer_tg ON api.customer;

DROP FUNCTION api.update_customer();
*/


-- Type: FUNCTION ; Name: api.update_customer(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_customer()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
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

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_customer_update(
			update_customername := new.name,
			update_customerdisplayname := new.displayname,	
			update_customeruuid := null::text,
			update_customerentityuuid := new.id,
			update_customerparentuuid := new.parent,
			update_customerowner := new.owner,
			update_customerbillingid := new.external_id,
			update_customerbillingsystemid := new.external_system,
			update_customerdeleted := new._deleted,
			update_customerdraft := new._draft,
			update_customerstartdate  := new.activated_at,
			update_customerenddate := new.deactivated_at,
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_modifiedby := ins_useruuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.customer
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_customer() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_customer() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_customer() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER update_customer_tg INSTEAD OF UPDATE ON api.customer FOR EACH ROW EXECUTE FUNCTION api.update_customer();


END;

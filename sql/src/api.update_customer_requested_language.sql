
-- Type: FUNCTION ; Name: api.update_customer_requested_language(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_customer_requested_language()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_legacy_id bigint;
  ins_id text;
  ins_entity uuid;
  ins_row api.customer_requested_language%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();


if new.legacy_id isNull 
	then 
		ins_legacy_id = (select customerrequestedlanguageid from public.customerrequestedlanguage where customerrequestedlanguageuuid = new.id);
	else ins_legacy_id = new.legacy_id;
end if;

if (old.legacy_id = ins_legacy_id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_customerrequestedlanguage_update(
			update_customerrequestedlanguageid := ins_legacy_id,
			update_customerrequestedlanguageownerentityuuid := new.owner, 
			update_languagetype_id := new.languagetype_id,
			update_customerrequestedlanguagedeleted := null::boolean,
			update_customerrequestedlanguagedraft := null::boolean,
			update_customerrequestedlanguagestartdate := new.activated_at,
			update_customerrequestedlanguageenddate := new.deactivated_at,
			update_modifiedbyid := new.modified_by
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.customer_requested_language
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 

$function$;


REVOKE ALL ON FUNCTION api.update_customer_requested_language() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_customer_requested_language() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_customer_requested_language() TO authenticated;

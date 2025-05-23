
-- Type: FUNCTION ; Name: api.create_customer_requested_language(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_customer_requested_language()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_customeruuid text;
	ins_customerentityuuid uuid;
	ins_entity bigint;
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

if (select new.owner in (select * from _api.util_get_onwership())) or (new.languagetype_id notNull)
	then
		call entity.crud_customerrequestedlanguage_create(
			create_customerrequestedlanguageownerentityuuid := new.owner,
			create_languagetype_id  := new.languagetype_id,
			create_customerrequestedlanguagedeleted := null::boolean,
			create_customerrequestedlanguagedraft := null::boolean,
			create_customerrequestedlanguageid := ins_entity,
			create_modifiedbyid  := ins_userid 
	  	);
	else
		return null;  -- need an exception here
end if;

  select * into ins_row
  from api.customer_requested_language
  where id = (select customerrequestedlanguageuuid from public.customerrequestedlanguage where customerrequestedlanguageid = ins_entity);

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_customer_requested_language() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_customer_requested_language() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_customer_requested_language() TO authenticated;

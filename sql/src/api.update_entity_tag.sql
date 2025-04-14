
-- Type: FUNCTION ; Name: api.update_entity_tag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_tag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_tag%rowtype;
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
		call entity.crud_entitytag_update(
			update_entitytaguuid := new.id, 
			update_entitytagownerentityuuid := new.owner, 
			update_entitytagentityinstanceuuid := new.instance, 
			update_entitytagentitytemplateuuid := new.template, 
			update_entitytagcustaguuid := new.customer_tag, 
			update_languagetypeuuid := null::uuid,  -- Fix this later 
			update_entitytagdeleted := new._deleted, 
			update_entitytagdraft := new._draft, 
			update_entitytagstartdate := new.activated_at, 
			update_entitytagenddate := new.deactivated_at, 
			update_modifiedbyid :=  null::bigint  -- Fix this later 
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_tag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_tag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_tag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_tag() TO authenticated;

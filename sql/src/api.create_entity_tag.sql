BEGIN;

/*
DROP TRIGGER create_entity_tag_tg ON api.entity_tag;

DROP FUNCTION api.create_entity_tag();
*/


-- Type: FUNCTION ; Name: api.create_entity_tag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_tag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.entity_tag%rowtype;
	ins_customeruuid text;
	ins_customerentityuuid uuid;
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

if (select new.owner in (select * from _api.util_get_onwership()))
	then
	call entity.crud_entitytag_create(
		create_entitytagownerentityuuid := new.owner, 
		create_entitytagentityinstanceuuid := new.instance, 
		create_entitytagentitytemplateuuid := new.template , 
		create_entitytagcustaguuid := new.customer_tag, 
		create_languagetypeuuid := ins_languagetypeentityuuid,    
		create_entitytagdeleted := false,  
		create_entitytagdraft := false,  
		create_entitytaguuid := ins_entity, 
		create_modifiedbyid :=ins_userid 
	);
end if;

  select * into ins_row
  from api.entity_tag
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_tag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_tag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_tag() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_entity_tag_tg INSTEAD OF INSERT ON api.entity_tag FOR EACH ROW EXECUTE FUNCTION api.create_entity_tag();


END;

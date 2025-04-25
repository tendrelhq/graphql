
-- Type: FUNCTION ; Name: api.create_entity_tag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_tag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_tag%rowtype;

begin

	call entity.crud_entitytag_create(
		create_entitytagownerentityuuid := new.owner, 
		create_entitytagentityinstanceuuid := new.instance, 
		create_entitytagentitytemplateuuid := new.template , 
		create_entitytagcustaguuid := new.customer_tag, 
		create_languagetypeuuid := ins_languagetypeentityuuid,    
		create_entitytagdeleted := false,  
		create_entitytagdraft := new._draft,  
		create_entitytaguuid := ins_entity, 
		create_modifiedbyid :=ins_userid 
	);

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

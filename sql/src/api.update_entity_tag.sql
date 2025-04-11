
-- Type: FUNCTION ; Name: api.update_entity_tag(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.update_entity_tag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_tag%rowtype;
begin

if old.id = new.id 
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
GRANT EXECUTE ON FUNCTION api.update_entity_tag() TO bombadil WITH GRANT OPTION;


-- Type: FUNCTION ; Name: api.create_entity_description(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_description()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_description%rowtype;

begin

-- only tendrel can have primary templates

	call entity.crud_entitydescription_create(
		create_entitydescriptionownerentityuuid  := new.owner, 
		create_entitytemplateentityuuid  := new.template, 
		create_entityfieldentityuuid  := new.field, 
		create_entitydescriptionname  := new.description, 
		create_entitydescriptionsoplink  := new.sop_link, 
		create_entitydescriptionfile  := new.file_link, 
		create_entitydescriptionicon  := new.icon_link, 
		create_entitydescriptionmimetypeuuid  := new.file_mime_type, 
		create_languagetypeuuid  := ins_languagetypeentityuuid, 
		create_entitydescriptiondeleted  := false, 
		create_entitydescriptiondraft  := new._draft,  
		create_entitydescriptionentityuuid  := ins_entity, 
		create_modifiedbyid :=ins_userid  
  	);

  select * into ins_row
  from api.entity_description
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;

COMMENT ON FUNCTION api.create_entity_description() IS '
### post {baseUrl}/description

A bunch of comments explaining post
	';

REVOKE ALL ON FUNCTION api.create_entity_description() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO authenticated;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO god;
GRANT EXECUTE ON FUNCTION api.create_entity_description() TO tendreladmin WITH GRANT OPTION;

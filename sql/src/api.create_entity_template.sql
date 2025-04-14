
-- Type: FUNCTION ; Name: api.create_entity_template(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_template%rowtype;

begin

-- only tendrel can have primary templates

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

  call entity.crud_entitytemplate_create(
      create_entitytemplatecornerstoneorder := new._order,   
      create_entitytemplatedeleted := false, 
      create_entitytemplatedraft := new._draft,  
      create_entitytemplateexternalid := new.external_id,  
      create_entitytemplateexternalsystemuuid := new.external_system,  
      create_entitytemplateisprimary := new._primary, 
      create_entitytemplatename := new.name,  
      create_entitytemplateownerentityuuid := new.owner, 
      create_entitytemplateparententityuuid := new.parent, 
      create_entitytemplatescanid := new.scan_code,  
      create_entitytemplatetag := null::text,  -- save for an all in rpc
      create_entitytemplatetaguuid := null::uuid, -- save for an all in rpc
      create_languagetypeuuid := ins_languagetypeentityuuid,  -- Fix this later
      create_modifiedbyid :=ins_userid,  -- Fix this later
      create_entitytemplateentityuuid := ins_entity
  );

  select * into ins_row
  from api.entity_template
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;

COMMENT ON FUNCTION api.create_entity_template() IS '
### post {baseUrl}/template

A bunch of comments explaining post
	';

REVOKE ALL ON FUNCTION api.create_entity_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO authenticated;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO god;
GRANT EXECUTE ON FUNCTION api.create_entity_template() TO tendreladmin WITH GRANT OPTION;

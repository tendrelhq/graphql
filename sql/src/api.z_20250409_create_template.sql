
-- Type: FUNCTION ; Name: api.z_20250409_create_template(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.z_20250409_create_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.template%rowtype;
  ins_primary boolean;
begin

-- only tendrel can have primary templates

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then ins_primary = true;
		else ins_primary = false;
	end if;

	
  call entity.crud_entitytemplate_create(
      create_entitytemplatecornerstoneorder := new._order,   
      create_entitytemplatedeleted := false, 
      create_entitytemplatedraft := new._draft,  
      create_entitytemplateexternalid := new.external_id,  
      create_entitytemplateexternalsystemuuid := new.external_system,  
      create_entitytemplateisprimary := ins_primary, 
      create_entitytemplatename := new.name,  
      create_entitytemplateownerentityuuid := new.owner, 
      create_entitytemplateparententityuuid := new.parent, 
      create_entitytemplatescanid := new.scan_code,  
      create_entitytemplatetag := new.tag_name,  
      create_entitytemplatetaguuid := new.tag_id::uuid, 
      create_languagetypeuuid := new.language_type_id::uuid,  
      create_modifiedbyid := new.create_modifiedby_id,  
      create_entitytemplateentityuuid := ins_entity
  );

  select * into ins_row
  from api.template
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;

COMMENT ON FUNCTION api.z_20250409_create_template() IS '
### post {baseUrl}/template

A bunch of comments explaining post
	';

REVOKE ALL ON FUNCTION api.z_20250409_create_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_create_template() TO bombadil WITH GRANT OPTION;

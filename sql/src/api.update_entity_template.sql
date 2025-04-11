
-- Type: FUNCTION ; Name: api.update_entity_template(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.update_entity_template()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_template%rowtype;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;


if old.id = new.id 
	then 
		call entity.crud_entitytemplate_update(
		    update_entitytemplateuuid := new.id, 
		    update_entitytemplateownerentityuuid := new.owner, 
		    update_entitytemplateparententityuuid := new.parent,	
		    update_entitytemplateexternalid := new.external_id,
		    update_entitytemplateexternalsystementityuuid := new.external_system,
		    update_entitytemplatescanid := new.scan_code,
		    update_entitytemplatenameuuid := new.name_id,
		    update_entitytemplatename := new.name,
		    update_entitytemplateorder := new._order,
		    update_entitytemplateisprimary := new._primary,
		    update_entitytemplatetypeentityuuid := new.type,
		    update_entitytemplatedeleted := new._deleted,
		    update_entitytemplatedraft := new._draft,
		    update_entitytemplatestartdate := new.activated_at,
		    update_entitytemplateenddate := new.deactivated_at,
		    update_entitytemplatemodifiedbyuuid := null::text,  -- Fix this later 
			update_languagetypeuuid :=  null::uuid
		);
end if;

  select * into ins_row
  from api.entity_template
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_template() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_template() TO bombadil WITH GRANT OPTION;

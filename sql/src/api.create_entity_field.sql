
-- Type: FUNCTION ; Name: api.create_entity_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_field%rowtype;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

  call entity.crud_entityfield_create(
      create_entityfieldownerentityuuid := new.owner,
      create_entityfieldparententityuuid := new.parent,
      create_entityfieldtemplateentityuuid := new.template,
      create_entityfieldcornerstoneorder := new._order,
      create_entityfieldname := new.name,
      create_entityfieldtypeentityuuid := new.type_id,
      create_entityfieldentityparenttypeentityuuid := new.parent_type,
      create_entityfieldentitytypeentityuuid := new.entity_type,
      create_entityfielddefaultvalue := new.default_value,
      create_entityfieldformatentityuuid := new.format,
      create_entityfieldformatentityname := null::text,  -- save for an all in rpc
      create_entityfieldwidgetentityuuid := new.widget,
      create_entityfieldwidgetentityname := null::text,  -- save for an all in rpc
      create_entityfieldiscalculated := new._calculated::boolean,
      create_entityfieldiseditable := new._editable::boolean,
      create_entityfieldisvisible := new._visible::boolean,
      create_entityfieldisrequired := new._required::boolean,
      create_entityfieldisprimary := new._primary,
      create_entityfieldtranslate := new._translate::boolean,
      create_entityfieldexternalid := new.external_id::text,
      create_entityfieldexternalsystemuuid := new.external_system::uuid,
      create_languagetypeuuid := ins_languagetypeentityuuid,
      create_entityfielddeleted := new._deleted,
      create_entityfielddraft := new._draft,
      create_modifiedbyid := ins_userid,
      create_entityfieldentityuuid := ins_entity
  );

  select * into ins_row
  from api.entity_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_field() TO authenticated;

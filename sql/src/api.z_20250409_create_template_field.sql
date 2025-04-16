
-- Type: FUNCTION ; Name: api.z_20250409_create_template_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.z_20250409_create_template_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.template_field%rowtype;
begin
  call entity.crud_entityfield_create(
      create_entityfieldownerentityuuid := new.owner,
      create_entityfieldparententityuuid := new.parent,
      create_entityfieldtemplateentityuuid := new.template,
      create_entityfieldcornerstoneorder := new._order,
      create_entityfieldname := new.name,
      create_entityfieldtypeentityuuid := new.type_id,
      create_entityfieldentityparenttypeentityuuid := null::uuid,
      create_entityfieldentitytypeentityuuid := null::uuid,
      create_entityfielddefaultvalue := new.default_value,
      create_entityfieldformatentityuuid := null::uuid,
      create_entityfieldformatentityname := null::text,
      create_entityfieldwidgetentityuuid := null::uuid,
      create_entityfieldwidgetentityname := null::text,
      create_entityfieldiscalculated := null::boolean,
      create_entityfieldiseditable := null::boolean,
      create_entityfieldisvisible := null::boolean,
      create_entityfieldisrequired := null::boolean,
      create_entityfieldisprimary := new._primary,
      create_entityfieldtranslate := null::boolean,
      create_entityfieldexternalid := null::text,
      create_entityfieldexternalsystemuuid := null::uuid,
      create_languagetypeuuid := null::uuid,
      create_entityfielddeleted := new._deleted,
      create_entityfielddraft := new._draft,
      create_modifiedbyid := 895::bigint,
      create_entityfieldentityuuid := ins_entity
  );

  select * into ins_row
  from api.template_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_create_template_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_create_template_field() TO tendreladmin WITH GRANT OPTION;

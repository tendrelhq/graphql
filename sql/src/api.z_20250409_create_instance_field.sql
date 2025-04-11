
-- Type: FUNCTION ; Name: api.z_20250409_create_instance_field(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.z_20250409_create_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.instance_field%rowtype;
begin
  call entity.crud_entityfieldinstance_create(
      create_entityfieldinstanceownerentityuuid := new.owner,
      create_entityfieldinstanceentityinstanceentityuuid := new.instance,
      create_entityfieldinstanceentityfieldentityuuid := new.template,
      create_entityfieldinstancevalue := null::text,
      create_entityfieldinstanceentityfieldname := new.name,
      create_entityfieldformatentityuuid := null::uuid,
      create_entityfieldformatentityname := null::text,
      create_entityfieldwidgetentityuuid := null::uuid,
      create_entityfieldwidgetentityname := null::text,
      create_entityfieldinstanceexternalid := null::text,
      create_entityfieldinstanceexternalsystemuuid := null::uuid,
      create_entityfieldinstancedeleted := new._deleted,
      create_entityfieldinstancedraft := new._draft,
      create_languagetypeuuid := null::uuid,
      create_modifiedbyid := 895::bigint,
      create_entityfieldinstanceentityuuid := ins_entity
  );

  select * into ins_row
  from api.instance_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_create_instance_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_create_instance_field() TO bombadil WITH GRANT OPTION;

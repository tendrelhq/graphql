
-- Type: FUNCTION ; Name: api.create_entity_instance_field(); Owner: bombadil

CREATE OR REPLACE FUNCTION api.create_entity_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_field%rowtype;
begin
  call entity.crud_entityfieldinstance_create(
      create_entityfieldinstanceownerentityuuid := new.owner,
      create_entityfieldinstanceentityinstanceentityuuid := new.instance,
      create_entityfieldinstanceentityfieldentityuuid := new.field,
      create_entityfieldinstancevalue := new.value,
      create_entityfieldinstanceentityfieldname := null::text,  -- saved for SP in the future
      create_entityfieldformatentityuuid := null::uuid,  -- saved for SP in the future
      create_entityfieldformatentityname := null::text,  -- saved for SP in the future
      create_entityfieldwidgetentityuuid := null::uuid,  -- saved for SP in the future
      create_entityfieldwidgetentityname := null::text,  -- saved for SP in the future
      create_entityfieldinstanceexternalid := null::text,
      create_entityfieldinstanceexternalsystemuuid := null::uuid,
      create_entityfieldinstancedeleted := new._deleted,
      create_entityfieldinstancedraft := new._draft,
      create_languagetypeuuid := null::uuid,  -- need to wire this in later
      create_modifiedbyid := 895::bigint,  -- need to wire this in later
      create_entityfieldinstanceentityuuid := ins_entity
  );


  select * into ins_row
  from api.entity_instance_field
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end 
$function$;


REVOKE ALL ON FUNCTION api.create_entity_instance_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_field() TO bombadil WITH GRANT OPTION;

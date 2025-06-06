BEGIN;

/*
DROP TRIGGER create_entity_instance_field_tg ON api.entity_instance_field;

DROP FUNCTION api.create_entity_instance_field();
*/


-- Type: FUNCTION ; Name: api.create_entity_instance_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.create_entity_instance_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_instance_field%rowtype;
begin

if (select new.owner in (select * from _api.util_get_onwership()))
	then
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
      create_languagetypeuuid := ins_languagetypeentityuuid,  
      create_modifiedbyid := ins_userid,  
      create_entityfieldinstanceentityuuid := ins_entity
  );
 end if;

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
GRANT EXECUTE ON FUNCTION api.create_entity_instance_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.create_entity_instance_field() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER create_entity_instance_field_tg INSTEAD OF INSERT ON api.entity_instance_field FOR EACH ROW EXECUTE FUNCTION api.create_entity_instance_field();


END;

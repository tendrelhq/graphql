
-- Type: FUNCTION ; Name: api.z_20250409_create_instance(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.z_20250409_create_instance()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.instance%rowtype;
begin
  call entity.crud_entityinstance_create(
      create_entityinstanceownerentityuuid := new.owner,
      create_entityinstanceentitytemplateentityuuid := new.template,
      create_entityinstanceentitytemplateentityname := null::text,
      create_entityinstanceparententityuuid := null::uuid,
      create_entityinstanceecornerstoneentityuuid := null::uuid,
      create_entityinstancecornerstoneorder := new._order,
      create_entityinstancetaguuid := null::uuid,
      create_entityinstancetag := null::text,
      create_entityinstancename := new.name,
      create_entityinstancescanid := null::text,
      create_entityinstancetypeuuid := null::uuid,
      create_entityinstanceexternalid := null::text,
      create_entityinstanceexternalsystemuuid := null::uuid,
      create_entityinstancedeleted := new._deleted,
      create_entityinstancedraft := new._draft,
      create_languagetypeuuid := null::uuid,
      create_modifiedbyid := 895,
      create_entityinstanceentityuuid := ins_entity
  );

  select * into ins_row
  from api.instance
  where id = ins_entity;

  if not found then
    return null;
  end if;

  return ins_row;
end $function$;


REVOKE ALL ON FUNCTION api.z_20250409_create_instance() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.z_20250409_create_instance() TO tendreladmin WITH GRANT OPTION;

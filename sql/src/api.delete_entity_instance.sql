
-- Type: FUNCTION ; Name: api.delete_entity_instance(uuid,uuid); Owner: bombadil

CREATE OR REPLACE FUNCTION api.delete_entity_instance(owner uuid, id uuid)
 RETURNS SETOF api.entity_instance
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.
  call entity.crud_entityinstance_delete(
      create_entityinstanceownerentityuuid := owner,
      create_entityinstanceentityuuid := id,
      create_modifiedbyid := 895
  );

  return query
    select *
    from api.entity_instance t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_instance(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance(uuid,uuid) TO bombadil WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_entity_instance(uuid,uuid) TO authenticated;

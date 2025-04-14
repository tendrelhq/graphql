
-- Type: FUNCTION ; Name: api.delete_entity_tag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_entity_tag(owner uuid, id uuid)
 RETURNS SETOF api.entity_tag
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin
  -- TODO: I wonder what we should do here. Do we:
  -- (a) Grant access to the entity schema to authenticated?
  -- (b) Use SECURITY DEFINER functions
  -- The downside of (a) is broader permissions, while of (b) is we lose RLS.
  -- I lean towards (a) at the moment.

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

if (select owner in (select * from _api.util_get_onwership()) )
	then  
	  call entity.crud_entitytag_delete(
	      create_entitytagownerentityuuid := owner,
	      create_entitytagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
	else
		return;  -- need an exception here
end if;

  return query
    select *
    from api.entity_tag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_entity_tag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_tag(uuid,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_entity_tag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;

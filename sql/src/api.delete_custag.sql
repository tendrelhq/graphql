BEGIN;

/*
DROP FUNCTION api.delete_custag(uuid,uuid);
*/


-- Type: FUNCTION ; Name: api.delete_custag(uuid,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_custag(owner uuid, id uuid)
 RETURNS SETOF api.custag
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
	  call entity.crud_custag_delete(
	      create_custagownerentityuuid := owner,
	      create_custagentityuuid := id,
	      create_modifiedbyid := ins_userid
	  );
end if;

  return query
    select *
    from api.custag t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_custag(uuid,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_custag(uuid,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_custag(uuid,uuid) TO authenticated;

END;

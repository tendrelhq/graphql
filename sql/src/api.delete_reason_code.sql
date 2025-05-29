BEGIN;

/*
DROP FUNCTION api.delete_reason_code(uuid,uuid,text,text);
*/


-- Type: FUNCTION ; Name: api.delete_reason_code(uuid,uuid,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.delete_reason_code(owner uuid, id uuid, work_template_constraint text, work_template text)
 RETURNS SETOF api.reason_code
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_userid bigint;
begin

select get_workerinstanceid
into ins_userid
from _api.util_user_details();

-- NEED TO ADD MORE CONDITIONS.  
-- DO WE ALLOW THE CONSTRAINT TO BE DELETED OR JUST THE CUSTAG TO BE DEACTIVATED.
-- VERSION BELOW JUST DEACTIVATES THE CUSTAG, BUT THAT IS FOR ALL TEMPLATES.

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
    from api.reason_code t
    where t.owner = $1 and t.id = $2
  ;

  return;
end 
$function$;


REVOKE ALL ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.delete_reason_code(uuid,uuid,text,text) TO authenticated;

END;

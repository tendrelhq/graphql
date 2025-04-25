
-- Type: FUNCTION ; Name: _api.util_user_details(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION _api.util_user_details()
 RETURNS TABLE(get_workerinstanceid bigint, get_workerinstanceuuid text, get_languagetypeid bigint, get_languagetypeuuid text, get_languagetypeentityuuid uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
		tempworkerinstanceid bigint;
		tempworkerinstanceuuid text; 
		templanguagetypeid bigint; 
		templanguagetypeuuid text; 
		templanguagetypeentityuuid uuid;
begin

select workerinstanceid, workerinstanceuuid
into tempworkerinstanceid,tempworkerinstanceuuid
from  workerinstance
	inner join worker
		on workerid = workerinstanceworkerid
			and workeridentityid = ((current_setting('request.jwt.claims'::text, true)::json ->> 'sub'::text)::text)
order by workerinstancecustomerid asc limit 1;

select systagid,systaguuid, systagentityuuid
into templanguagetypeid,templanguagetypeuuid, templanguagetypeentityuuid
from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '580f6ee2-42ca-4a5b-9e18-9ea0c168845a', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
where systagdisplayname = current_setting('user.preferred_language');

return query select tempworkerinstanceid, tempworkerinstanceuuid, templanguagetypeid, templanguagetypeuuid, templanguagetypeentityuuid;

return;

end 
$function$;


REVOKE ALL ON FUNCTION _api.util_user_details() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _api.util_user_details() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION _api.util_user_details() TO authenticated;


-- Type: FUNCTION ; Name: _api.util_get_onwership(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION _api.util_get_onwership()
 RETURNS TABLE(get_ownership uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_useruuid text;
begin

select get_workerinstanceuuid
into ins_useruuid
from _api.util_user_details();

if (current_setting('request.jwt.claims'::text, true)::json ->> 'role'::text) = 'god'::text
	then
		return query select customerownerentityuuid from entity.crud_customer_read_min(null,null, null, true, null,null,null,null);
	else   -- here is where we can do recursive lookup for all the owner uuids.  For now it is just parent child 1-level
		return query select customerownerentityuuid 
								from entity.crud_customer_read_min(null,null, null, true, null,null,null,null) parent
									inner join entity.crud_customer_read_min(null,null, null, true, null,null,null,null) child
										on child.customerparententityuuid = parent.customerentityuuid
								where parent.customerid = (select workerinstancecustomerid from workerinstance where workerinstanceuuid = ins_useruuid);
end if;

return;

end 
$function$;


REVOKE ALL ON FUNCTION _api.util_get_onwership() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _api.util_get_onwership() TO tendreladmin WITH GRANT OPTION;

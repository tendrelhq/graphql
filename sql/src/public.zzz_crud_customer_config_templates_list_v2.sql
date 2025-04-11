
-- Type: FUNCTION ; Name: zzz_crud_customer_config_templates_list_v2(bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION public.zzz_crud_customer_config_templates_list_v2(language_id bigint)
 RETURNS TABLE(uuid text, type_uuid text, type text, value text, value_type text)
 LANGUAGE plpgsql
AS $function$

Declare
	templanguageid bigint;
BEGIN
	
/* MJK 20240510
	
	Added in a default language of engliesh if Null is accidentally passed in for type.  
	Flipped this to plpgsql so that we can have temp variables.  
	Explicitely returned the query.
	
	Future: Might want to switch this to use languagetypeuuid instead.   

*/

if language_id isNull
	then
		templanguageid = 20;
	else
		templanguageid = language_id;
end if;

RETURN QUERY SELECT customerconfiguuid     as uuid,
       customerconfigtypeuuid as type_uuid,
       vs.systagname          as type,
       customerconfigvalue    as value,
       value_type.systagtype  as value_type
FROM public.customerconfig cc
         INNER JOIN public.view_systag vs
                    ON cc.customerconfigtypeuuid = vs.systaguuid and vs.languagetranslationtypeid = templanguageid
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
WHERE customerconfigsiteuuid is null
  and customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0);

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_customer_config_templates_list_v2(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_templates_list_v2(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_templates_list_v2(bigint) TO bombadil WITH GRANT OPTION;

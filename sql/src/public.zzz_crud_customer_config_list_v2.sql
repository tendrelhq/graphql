
-- Type: FUNCTION ; Name: zzz_crud_customer_config_list_v2(text,bigint,bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION public.zzz_crud_customer_config_list_v2(customer_uuid_param text, site_id_param bigint, language_id bigint)
 RETURNS TABLE(uuid text, started_at timestamp without time zone, ended_at timestamp without time zone, updated_by_uuid text, type_uuid text, type text, value text, value_type text)
 LANGUAGE plpgsql
AS $function$
Declare
	templanguageid bigint;
BEGIN
/* MJK 20240510
	
	Added in a default language of engliesh if Null is accidentally passed in for type.  
	Flipped this to plpgsql so that we can have temp variables.  
	Explicitely returned the query.
	Addeed in site.  If Null get all otherwise get the configs for a site.  
	Check if the customer exists.  

	Future:  Twait to add - Category and category id.  
	Future: Add in site id for the call.
	Future: Might want to switch this to use languagetypeuuid instead.   
	Future: Might change this to default to the language for the customer name.
	Future: Might want to create a default langaugage customer config.
*/
	-- set language to english if nothing is set in.  
	
	if language_id isNull
		then
			templanguageid = 20;
		else
			templanguageid = language_id;
	end if;

    -- Check if customer exists
    PERFORM * FROM public.customer WHERE customeruuid = customer_uuid_param;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;


	if site_id_param notNull
		then
		    -- Check if site exists
		    PERFORM * FROM public.location WHERE locationid = site_id_param;
		    IF NOT FOUND THEN
		        RAISE EXCEPTION 'Site does not exist';
		    END IF;
		
		    -- Check if site is valid for customer 
		
			PERFORM * FROM public.location 
						inner join customer
							on locationcustomerid = locationcustomerid
						WHERE locationid = site_id_param;
			IF NOT FOUND THEN
				RAISE EXCEPTION 'Not a valid Customer and Site combination';
			END IF;
	End If;

	
RETURN QUERY SELECT customerconfiguuid       as uuid,
       customerconfigstartdate  as started_at,
       customerconfigenddate    as ended_at,
       customerconfigmodifiedby as updated_by_uuid,
       customerconfigtypeuuid   as type_uuid,
       vs.systagname            as type,
       customerconfigvalue      as value,
       value_type.systagtype    as value_type
FROM public.customerconfig cc
         INNER JOIN public.view_systag vs
                    ON cc.customerconfigtypeuuid = vs.systaguuid 
						and vs.languagetranslationtypeid = templanguageid
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
WHERE customerconfigcustomeruuid = customer_uuid_param;

END;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_customer_config_list_v2(text,bigint,bigint) TO bombadil WITH GRANT OPTION;

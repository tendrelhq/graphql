
-- Type: PROCEDURE ; Name: zzz_crud_customer_config_create_v2(text,text,text,text,text,text); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_config_create_v2(IN customer_uuid text, IN site_uuid text, IN config_uuid text, IN value_type_uuid text, IN config_value text, IN modified_by text, OUT config_id text)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerconfigvalue text;
BEGIN
	/*  MJK 20240510 
		Added in Exception - Customer Config already exists
		Added in Exception - Not a valid Category and Config combination
		Added in handling if the config_value comes in Null.  We wil use the default value
	*/

	
    -- Check if customer exists
    PERFORM * FROM public.customer WHERE customeruuid = customer_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    -- Check if customer config already exists
    PERFORM * FROM public.customerconfig 
		WHERE customerconfigcustomeruuid = customer_uuid
			and customerconfigsiteuuid = site_uuid
			and customerconfigtypeuuid = config_uuid
			and customerconfigvaluetypeuuid = value_type_uuid;
    IF FOUND THEN
        RAISE EXCEPTION 'Customer Config already exists';
    END IF;

	-- check if the category and config are a legit combo
    PERFORM * FROM public.customerconfig 
		WHERE customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0 and customersiteid isNull)
			and customerconfigsiteuuid = site_uuid
			and customerconfigtypeuuid = config_uuid
			and customerconfigvaluetypeuuid = value_type_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Not a valid Category and Config combination';
    END IF;	

	-- get the default value and decide if we want to use it.  We currentl use it if the value passed in is null
	-- Future:  We could make this stronger to check if the value passed in is even valid.  

	if customerconfigvalue isNull
		then 
			tempcustomerconfigvalue = (select customerconfigvalue 
										FROM public.customerconfig 
										WHERE customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0 and customersiteid isNull)
											and customerconfigsiteuuid = site_uuid
											and customerconfigtypeuuid = config_uuid
											and customerconfigvaluetypeuuid = value_type_uuid
											limit 1);
		else tempcustomerconfigvalue = customerconfigvalue;
	end if;

	 -- Insert new customer config and return the newly generated UUID
    INSERT INTO public.customerconfig (customerconfigcustomeruuid, 
										customerconfigsiteuuid,
										customerconfigtypeuuid,
										customerconfigvaluetypeuuid, 
										customerconfigvalue,
                                       customerconfigmodifiedby)
    VALUES (customer_uuid, 
			site_uuid, 
			config_uuid, 
			value_type_uuid, 
			tempcustomerconfigvalue, 
			modified_by)
    RETURNING customerconfiguuid INTO config_id;

END;
$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_config_create_v2(text,text,text,text,text,text) TO bombadil WITH GRANT OPTION;


-- Type: PROCEDURE ; Name: crud_customer_config_create(text,text,text,text,text); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_customer_config_create(IN customer_uuid text, IN site_uuid text, IN config_template_uuid text, IN config_value text, IN modified_by text, OUT config_id text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    config_template_type_uuid text;
    config_value_type_uuid    text;


BEGIN
    -- Check if customer exists
    PERFORM * FROM public.customer WHERE customeruuid = customer_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

    SELECT type_uuid,
           value_type_uuid
    INTO config_template_type_uuid, config_value_type_uuid
    FROM public.crud_customer_config_templates_list(20)
    WHERE uuid = config_template_uuid;

    IF (SELECT EXISTS(SELECT customerconfiguuid
                      FROM public.customerconfig c
                      WHERE customerconfigcustomeruuid = customer_uuid
                        AND customerconfigsiteuuid = site_uuid
                        AND customerconfigtypeuuid = config_template_type_uuid
                        AND customerconfigvaluetypeuuid = config_value_type_uuid)) THEN
        RAISE NOTICE 'This config already exists for this customer!';
    END IF;

        -- Insert new customer config and return the newly generated UUID
        INSERT INTO public.customerconfig (customerconfigcustomeruuid, customerconfigsiteuuid,
                                           customerconfigtypeuuid, customerconfigvaluetypeuuid, customerconfigvalue,
                                           customerconfigmodifiedby)
        VALUES (customer_uuid, site_uuid, config_template_type_uuid, config_value_type_uuid, config_value, modified_by)
        RETURNING customerconfiguuid INTO config_id;
    END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_create(text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_create(text,text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_create(text,text,text,text,text) TO bombadil WITH GRANT OPTION;

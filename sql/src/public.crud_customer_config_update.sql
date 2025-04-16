
-- Type: PROCEDURE ; Name: crud_customer_config_update(text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_config_update(IN customer_uuid text, IN config_uuid text, IN config_value text, IN modified_by text, OUT updated_config_id text)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Check if customer config exists
    PERFORM *
    FROM public.customerconfig
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer configuration does not exist';
    END IF;

    -- Update customer config
    UPDATE public.customerconfig
    SET customerconfigvalue        = config_value,
        customerconfigmodifiedby   = modified_by,
        customerconfigmodifieddate = clock_timestamp()
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid
    RETURNING customerconfiguuid INTO updated_config_id;
END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_update(text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_update(text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_update(text,text,text,text) TO tendreladmin WITH GRANT OPTION;

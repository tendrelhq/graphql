
-- Type: PROCEDURE ; Name: crud_customer_config_delete(text,text,text); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_customer_config_delete(IN customer_uuid text, IN config_uuid text, IN modified_by text, OUT deleted_config_id text)
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

    -- Delete customer config
    UPDATE public.customerconfig
    SET customerconfigenddate      = clock_timestamp(),
        customerconfigmodifiedby   = modified_by,
        customerconfigmodifieddate = clock_timestamp()
    WHERE customerconfigcustomeruuid = customer_uuid
      AND customerconfiguuid = config_uuid
    RETURNING customerconfiguuid INTO deleted_config_id;
END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_config_delete(text,text,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_delete(text,text,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_config_delete(text,text,text) TO bombadil WITH GRANT OPTION;

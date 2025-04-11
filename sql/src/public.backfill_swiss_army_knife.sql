
-- Type: PROCEDURE ; Name: backfill_swiss_army_knife(); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.backfill_swiss_army_knife()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	customer_uuid record;
	config_id text;
BEGIN

FOR customer_uuid in (
	select customeruuid from customer
)
loop
	raise notice 'customer: %', customer_uuid.customeruuid;
	call public.crud_customer_config_create(
		customer_uuid.customeruuid, 
		-- Leaving site null
		null,
		-- customer config template uuid for 'Applications :: Tendrel'
		'customerconfig_438370f8-6d76-454c-9337-de7ad08a7e32'::text,
		'true'::text, 
		-- modified by Fede
		'worker-instance_8cd9e1fb-7b6e-48f2-b5d8-8d9f54381160'::text,
		config_id
);
end loop;
END;
$procedure$;


REVOKE ALL ON PROCEDURE backfill_swiss_army_knife() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_swiss_army_knife() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_swiss_army_knife() TO bombadil WITH GRANT OPTION;

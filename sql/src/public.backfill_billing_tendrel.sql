
-- Type: PROCEDURE ; Name: backfill_billing_tendrel(); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.backfill_billing_tendrel()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	customer_uuid record;
	config_id text;
	tempmodifiedby text;
	tempcustomeruuid text;
	tempsiteuuid text;
BEGIN

tempmodifiedby = (select workerinstanceuuid from workerinstance where workerinstanceid = 337);
tempcustomeruuid = (select customeruuid from customer where customerid = 0);
tempsiteuuid = (select locationuuid from location where locationcustomerid = 0 and locationistop = true);
	
-- Add all customer not cust 0 or 
FOR customer_uuid in (
	select customeruuid from customer where customerid <> 0 
	)
loop
	raise notice 'customer: %', customer_uuid.customeruuid;
	call public.crud_customer_config_create(
		customer_uuid.customeruuid, 
		-- Leaving site null
		null::text,
		-- customer config template uuid for 'Billing :: Tendrel'
		'customerconfig_0ba355c2-e93d-449d-8e04-97395b30b7b7'::text,
		'true'::text, 
		-- modified by Mark
		tempmodifiedby,
		config_id
);
end loop;


-- Add cust 0
call public.crud_customer_config_create(
	tempcustomeruuid, 
	-- cust 0 site id
	tempsiteuuid,
	-- customer config template uuid for 'Billing :: Tendrel'
	'customerconfig_0ba355c2-e93d-449d-8e04-97395b30b7b7'::text,
	'true'::text, 
	-- modified by Mark
	tempmodifiedby,
	config_id);


END;
$procedure$;


REVOKE ALL ON PROCEDURE backfill_billing_tendrel() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_billing_tendrel() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE backfill_billing_tendrel() TO bombadil WITH GRANT OPTION;

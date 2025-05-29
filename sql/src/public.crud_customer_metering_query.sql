BEGIN;

/*
DROP PROCEDURE crud_customer_metering_query(integer,integer,text);
*/


-- Type: PROCEDURE ; Name: crud_customer_metering_query(integer,integer,text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_metering_query(IN billing_month integer, IN billing_year integer, IN modified_by_workerinstance_uuid text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	customer_record record;
BEGIN
	
insert into customerbillingrecord(
	customerbillingrecordcustomerid, 
	customerbillingrecordcreateddate,			 
	customerbillingrecordmodifieddate, 
	customerbillingrecordmodifiedby,
    customerbillingrecordstatusuuid, 
	customerbillingrecordvalue, 
	customerbillingrecordbillingmonth,
	customerbillingrecordbillingyear, 									 
	customerbillingrecordbillingsystemuuid, 
	customerbillingrecordbillingid,
	customerbillingrecordcustomertypeuuid,
	customerbillingrecordcustomertypename,
	customerbillingrecordcustomeruuid) 
select 
	customerid,
	now(),
	now(),
	modified_by_workerinstance_uuid,
    'eb919f8c-ac25-4bbc-bec9-61feb7d3d073'::text,
	count(*) as workercount, 
	billinghistorymonth,
	billinghistoryyear,
	billinghistorycustomerexternalsystemuuid,
	billinghistorycustomerexternalid,
	customertypeuuid,
	systagtype,
	billinghistorycustomeruuid
from ( 
	select 
		billinghistorystatustype,
		billinghistorymonth, 
		billinghistoryyear,
		billinghistoryworkerinstanceid,
		billinghistorycustomeruuid,
		billinghistorycustomerexternalid,
		billinghistorycustomerexternalsystemuuid,
		customerid,
		customertypeuuid,
		systagtype
	from datawarehouse.billinghistory
		inner join customer
			on customeruuid = billinghistorycustomeruuid
		inner join systag
			on customertypeuuid = systaguuid
	where
		billinghistorymonth=billing_month
		AND billinghistoryyear=billing_year
		AND billinghistorystatusuuid='64c1e074-ea89-4b5a-88a8-40522b57e400'
		AND billinghistorycustomerbillingrecorduuid is null
	group by
		billinghistorystatustype,
		billinghistorymonth, 
		billinghistoryyear,
		billinghistoryworkerinstanceid,
		billinghistorycustomeruuid,
		billinghistorycustomerexternalid,
		billinghistorycustomerexternalsystemuuid,
		customerid,
		customertypeuuid,
		systagtype
	) 	as uniqueworkerbillingrecords
where 
	billinghistorycustomerexternalsystemuuid IS NOT null 
	AND billinghistorycustomerexternalid IS NOT null
group by 
	billinghistorycustomeruuid,
	billinghistorycustomerexternalid,
	billinghistorycustomerexternalsystemuuid,
	billinghistorymonth,
	billinghistoryyear,
	customertypeuuid,
	systagtype,
	billinghistorycustomeruuid,
	customerid;
	
	
update datawarehouse.billinghistory
set 
	billinghistorycustomerbillingrecorduuid = customerbillingrecorduuid,
	billinghistorymodifieddate = now()
	--billinghistorymodifiedby = modified_by_workerinstance_uuid
from customerbillingrecord
where
	billinghistorymonth=billing_month
	and billinghistoryyear=billing_year
	and billinghistorystatusuuid='64c1e074-ea89-4b5a-88a8-40522b57e400' -- is charge
	and billinghistorycustomerbillingrecorduuid is null
	and billinghistorycustomeruuid = customerbillingrecordcustomeruuid
	and customerbillingrecordbillingmonth=billing_month
	and customerbillingrecordbillingyear=billing_year;

END;
$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_metering_query(integer,integer,text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_metering_query(integer,integer,text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_metering_query(integer,integer,text) TO tendreladmin WITH GRANT OPTION;

END;

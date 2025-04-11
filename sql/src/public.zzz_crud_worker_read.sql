
-- Type: FUNCTION ; Name: zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text); Owner: bombadil

CREATE OR REPLACE FUNCTION public.zzz_crud_worker_read(read_customeruuid text, read_customerexternalid text, read_customerexternalsystemuuid text, read_siteid bigint, read_workerinstanceid bigint, read_workerinstanceuuid text, read_workerexternalid text, read_workerexternalsystemid bigint, read_workerexternalsystemuuid text, read_workeridentityid text, read_workeridentitysystemid bigint, read_workeridentitysystemuuid text, read_read_languagetypeuuid text)
 RETURNS TABLE(workerinstanceid bigint, workerinstanceuuid text, workerinstancecustomerid bigint, workerinstancecustomeruuid text, workerinstancecustomername text, workerinstancesiteid bigint, workerinstancestartdate timestamp with time zone, workerinstanceenddate timestamp with time zone, workerinstancelanguageid bigint, workerinstancelanguageuuid text, workerinstancelanguagetype text, workerinstanceexternalid text, workerinstanceexternalsystemid bigint, workerinstanceexternalsystemuuid text, workerinstanceexternalsystemname text, workerinstancescanid text, workerinstanceuserroleid bigint, workerinstanceuserroleuuid text, workerinstanceuserrolename text, workerid bigint, workeruuid text, workerfirstname text, workerlastname text, workeremail text, workerfullname text, workerusername text, workerphonenumber text, workerexternalid text, workeridentityid text, workeridentitysystemid bigint, workeridentitysystemuuid text, workeridentitysystemname text)
 LANGUAGE plpgsql
AS $function$

Declare
	tempcustomerid bigint;
	templanguagetypeid bigint;

Begin
-- does not work for sites

	-- Check if customer exists
    PERFORM * FROM public.customer 
				WHERE (read_customeruuid = customeruuid 
					or (read_customerexternalid = customerexternalid
						and read_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid 
						from customer 
						where ('customer_42cb94ee-ec07-4d33-88ed-9d49659e68be' = customeruuid 
							or (null = customerexternalid
							and null = customerexternalsystemuuid))); 

	-- We probably should tie workerinstance to site
	-- Check if site exists  -- Check for Null first?  

if read_siteid notnull
	then
		PERFORM * FROM public.location loc
						inner join customer
							on customerid = loc.locationcustomerid		
					WHERE loc.locationid = read_siteid
						and loc.locationistop = tue;
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'Site does not exist for customer';
	    END IF;
end if;

	-- check if the workerinstnace is valid for customer
	-- check if the workerinstnace is valid for site (not doing this check yet)
	-- check if a valid workerinstance

    PERFORM * FROM public.workerinstance wi
				inner join customer
					on customerid = wi.workerinstancecustomerid
						and wi.workerinstancecustomerid = tempcustomerid
				inner join worker wor
					on wor.workerid = wi.workerinstanceworkerid
				WHERE wi.workerinstanceid = read_workerinstanceid 
						or wi.workerinstanceuuid = read_workerinstanceuuid
						or (wi.workerinstanceexternalid = read_workerexternalid 
							and (wi.workerinstanceexternalsystemid = read_workerexternalsystemid 
								--or wi.workerinstanceexternalsystemuuid = read_workerexternalsystemuuid
								))
						or (wor.workeridentityid = read_workeridentityid 
							and (wor.workeridentitysystemid =  read_workeridentitysystemid 
								or wor.workeridentitysystemuuid = read_workeridentitysystemuuid ));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Worker does not exist';
    END IF;

	templanguagetypeid = (select systagid 
						  from systag
						  where systaguuid = null);
	
	if templanguagetypeid isNull
		then templanguagetypeid = 20;
	end if;

RETURN QUERY SELECT 
	wi.workerinstanceid, 
	wi.workerinstanceuuid, 	
	customerid as workerinstancecustomerid,
	customeruuid as workerinstancecustomeruuid, 
	customername as workerinstancecustomername, 
	read_siteid,
	wi.workerinstancestartdate, 
	wi.workerinstanceenddate, 
	lan.systagid as workerinstancelanguageid, 
	lan.systaguuid as workerinstancelanguageuuid, 
	lan.systagtype as workerinstancelanguagetype,  
	wi.workerinstanceexternalid, 
	ext.systagid as workerinstanceexternalsystemid,
	ext.systaguuid as workerinstanceexternalsystemuuid,	
	ext.systagtype as workerinstanceexternalsystemname, 
	wi.workerinstancescanid, 
	role.systagid as workerinstanceuserroleid, 
	role.systaguuid as workerinstanceuserroleuuid,
	role.systagtype as workerinstanceuserrolename, 
	w.workerid,      
	w.workeruuid, 
	w.workerfirstname,
	w.workerlastname, 
	w.workeremail, 
	w.workerfullname, 
	w.workerusername, 
	w.workerphonenumber, 
	w.workerexternalid, 
	w.workeridentityid, 
	ide.systagid as workeridentitysystemid, 
	ide.systaguuid as workeridentitysystemuuid, 
	ide.systagtype as workeridentitysystemname  
FROM public.workerinstance wi
	inner join worker w
		on w.workerid = wi.workerinstanceworkerid
	inner join customer
		on customerid = wi.workerinstancecustomerid
			and wi.workerinstancecustomerid = tempcustomerid
	inner join systag lan
		on lan.systagid = templanguagetypeid
	inner join systag role
		on role.systagid =wi. workerinstanceuserroleid
	left join systag ext
		on ext.systagid = wi.workerinstanceexternalsystemid
	left join systag ide
		on ide.systagid = w.workeridentitysystemid
WHERE wi.workerinstanceid = read_workerinstanceid 
		or wi.workerinstanceuuid = read_workerinstanceuuid
		or (wi.workerinstanceexternalid = read_workerexternalid 
			and (wi.workerinstanceexternalsystemid = read_workerexternalsystemid 
				--or wi.workerinstanceexternalsystemuuid = read_workerexternalsystemuuid
				))
		or (w.workeridentityid = read_workeridentityid 
			and (w.workeridentitysystemid =  read_workeridentitysystemid 
				or w.workeridentitysystemuuid = read_workeridentitysystemuuid ));

End;

$function$;


REVOKE ALL ON FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION zzz_crud_worker_read(text,text,text,bigint,bigint,text,text,bigint,text,text,bigint,text,text) TO bombadil WITH GRANT OPTION;

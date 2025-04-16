
-- Type: PROCEDURE ; Name: crud_site_restart(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_site_restart(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

tempcustomerid = (select customerid
					from customer
					where (update_customeruuid = customeruuid 
						or (update_customerexternalid = customerexternalid
						and update_customerexternalsystemuuid = customerexternalsystemuuid)));

update location
set locationenddate = null,
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where locationid = update_siteid 
		and locationcustomerid = tempcustomerid;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_restart(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_restart(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_restart(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

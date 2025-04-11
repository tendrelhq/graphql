
-- Type: PROCEDURE ; Name: crud_site_delete(text,text,text,bigint,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_site_delete(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
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
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_siteid 
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_delete(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_delete(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_delete(text,text,text,bigint,bigint) TO bombadil WITH GRANT OPTION;

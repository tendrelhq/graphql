
-- Type: PROCEDURE ; Name: crud_location_delete(text,text,text,bigint,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_location_delete(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_locationid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
	Future:  Add in a site check
	Future:  Cascade changes

*/  
	PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;

	tempcustomerid = (select customerid
						from customer
						where (update_customeruuid = customeruuid 
							or (update_customerexternalid = customerexternalid
							and update_customerexternalsystemuuid = customerexternalsystemuuid)));

	PERFORM * FROM public.location WHERE locationid = update_siteid
										and locationcustomerid = tempcustomerid
										and locationistop = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Location does not exist';
    END IF;

	
update location
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_locationid 
	and locationistop = false
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_location_delete(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_delete(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_location_delete(text,text,text,bigint,bigint) TO bombadil WITH GRANT OPTION;

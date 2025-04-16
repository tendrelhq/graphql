
-- Type: PROCEDURE ; Name: zzz_crud_site_delete_v2(text,text,text,bigint,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_site_delete_v2(IN update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, INOUT update_siteid bigint, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	
Begin

/* MJK 20240510
	
	Added in a customer check.  

	Future:  wire in exterenasystemid
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
										and locationistop = true;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Site does not exist';
    END IF;

	
update location
set locationenddate = clock_timestamp() - interval '1 day',
	locationmodifiedby = update_modifiedbyid,
	locationmodifieddate = clock_timestamp()			
where (locationid = update_siteid 
	and locationistop = true
	and locationcustomerid = tempcustomerid);

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_site_delete_v2(text,text,text,bigint,bigint) TO tendreladmin WITH GRANT OPTION;

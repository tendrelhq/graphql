
-- Type: PROCEDURE ; Name: zzz_crud_customer_delete_v2(text,text,text,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.zzz_crud_customer_delete_v2(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

/* MJK 20240510
	
	Added in a customer check.  

*/  PERFORM * FROM public.customer WHERE (update_customeruuid = customeruuid 
											or (update_customerexternalid = customerexternalid
												and update_customerexternalsystemuuid = customerexternalsystemuuid));
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Customer does not exist';
    END IF;
	
-- set the customer as modified

update customer
set customerenddate = clock_timestamp() - interval '1 day',
	customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_customer_delete_v2(text,text,text,bigint) TO bombadil WITH GRANT OPTION;

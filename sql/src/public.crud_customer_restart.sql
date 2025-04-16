
-- Type: PROCEDURE ; Name: crud_customer_restart(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_restart(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

update customer
set customerenddate = null,
	customermodifiedby = update_modifiedbyid,
	customermodifieddate = clock_timestamp()			
where (update_customeruuid = customeruuid 
		or (update_customerexternalid = customerexternalid
		and update_customerexternalsystemuuid = customerexternalsystemuuid));

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_restart(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_restart(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_restart(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

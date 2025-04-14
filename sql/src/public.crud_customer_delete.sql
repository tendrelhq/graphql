
-- Type: PROCEDURE ; Name: crud_customer_delete(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_delete(INOUT update_customeruuid text, IN update_customerexternalid text, IN update_customerexternalsystemuuid text, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

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


REVOKE ALL ON PROCEDURE crud_customer_delete(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_delete(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_delete(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

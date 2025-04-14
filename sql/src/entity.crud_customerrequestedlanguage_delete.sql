
-- Type: PROCEDURE ; Name: entity.crud_customerrequestedlanguage_delete(uuid,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_customerrequestedlanguage_delete(IN create_customerownerentityuuid uuid, IN create_customerrequestedlanguageuuid text, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	
Begin

/*

-- tests needed

*/

-- check for owner 

if create_customerownerentityuuid  isNull
	then 
		return;   -- need an error code here
end if;

-- check for field

if create_customerentityuuid isNull
	then return;   -- need an error code here
end if;

-- update the field record to deleted

update public.customerrequestedlanguage
set customerrequestedlanguageenddate = now(),
	customerrequestedlanguagemodifieddate = now(),
	customerrequestedlanguagemodifiedby = create_modifiedbyid
where customerrequestedlanguagecustomerid = (select customerid 
											from entity.crud_customer_read_min(create_customerownerentityuuid,null, null, false,null,null,null, null))
	and customerrequestedlanguageuuid = create_customerrequestedlanguageid;
End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customerrequestedlanguage_delete(uuid,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_delete(uuid,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_delete(uuid,text,bigint) TO tendreladmin WITH GRANT OPTION;

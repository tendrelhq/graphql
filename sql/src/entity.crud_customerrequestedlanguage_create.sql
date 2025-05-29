BEGIN;

/*
DROP PROCEDURE entity.crud_customerrequestedlanguage_create(uuid,uuid,boolean,boolean,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_customerrequestedlanguage_create(uuid,uuid,boolean,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_customerrequestedlanguage_create(IN create_customerrequestedlanguageownerentityuuid uuid, IN create_languagetype_id uuid, IN create_customerrequestedlanguagedeleted boolean, IN create_customerrequestedlanguagedraft boolean, OUT create_customerrequestedlanguageid bigint, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagetypeid bigint;
	tempcustomerrequestedlanguageid bigint;
	tempcustomerid bigint;
	tempcustomerrequestedlanguagedeleted boolean;
	tempcustomerrequestedlanguagedraft boolean; 
Begin

/*

-- needs tests
	
*/

-- FUTURE:
	-- Check Instance and Template are of the same entity type.
	-- Use generic Entity Instance Read
	-- block duplicates or allow?  
	-- check for nulls in template

If create_customerrequestedlanguagedeleted isNull
	then tempcustomerrequestedlanguagedeleted = false;
	else tempcustomerrequestedlanguagedeleted = create_customerrequestedlanguagedeleted;
end if;

If create_customerrequestedlanguagedraft isNull
	then tempcustomerrequestedlanguagedraft = false;
	else tempcustomerrequestedlanguagedraft = create_customerrequestedlanguagedraft;
end if;

select customerid 
into tempcustomerid
from entity.crud_customer_read_min(create_customerrequestedlanguageownerentityuuid,null, null, false,null,null,null, null);

select systagid 
into templanguagetypeid
from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
where systagentityuuid = create_languagetype_id;

select customerrequestedlanguageid 
into tempcustomerrequestedlanguageid
from public.customerrequestedlanguage
where customerrequestedlanguagecustomerid = tempcustomerid
	and customerrequestedlanguagelanguageid = templanguagetypeid;
	

-- Check if the language already exists.  


if  tempcustomerrequestedlanguageid isNull 
	and templanguagetypeid notNull
	and tempcustomerid notNull
	then 
		INSERT INTO public.customerrequestedlanguage(
			customerrequestedlanguagecustomerid, 
			customerrequestedlanguagelanguageid, 
			customerrequestedlanguagestartdate, 
			customerrequestedlanguageenddate, 
			customerrequestedlanguagecreateddate, 
			customerrequestedlanguagemodifieddate, 
			customerrequestedlanguageexternalid, 
			customerrequestedlanguageexternalsystemid, 
			customerrequestedlanguagemodifiedby, 
			customerrequestedlanguagerefid, 
			customerrequestedlanguagesystemid)
		values(
			tempcustomerid,
			templanguagetypeid,
			now(),
			null,
			now(),	
			now(),
			null,
			null,
			create_modifiedbyid,
			null,
			null			
		)
		Returning customerrequestedlanguageid into create_customerrequestedlanguageid;
	else create_customerrequestedlanguageid = tempcustomerrequestedlanguageid;
End if;

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customerrequestedlanguage_create(uuid,uuid,boolean,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_create(uuid,uuid,boolean,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_create(uuid,uuid,boolean,boolean,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_create(uuid,uuid,boolean,boolean,bigint) TO graphql;

END;

BEGIN;

/*
DROP PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint);
*/


-- Type: PROCEDURE ; Name: crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_customer_create(IN create_customername text, IN create_sitename text, OUT create_customeruuid text, IN create_customerbillingid text, IN create_customerbillingsystemid text, INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid text, OUT create_adminuuid text, OUT create_siteuuid text, IN create_timezone text, IN create_languagetypeuuids text[], IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
    tempcustomerid                 bigint;
	tempcustomerentityuuid			uuid;
	tempsiteentityuuid				uuid;
	temptestlog text;
	templanguagetype_id uuid[];
	tempcustomerbillingsystemuuid uuid;
	tempadminidentitysystemuuid uuid;
	templadminid bigint;
Begin

/*

call public.crud_customer_create(
	create_customername := 'Test Keller v2',
	create_sitename := 'My Test Site',
	create_customeruuid := null::text,
	create_customerbillingid := 'fake-billing-id',
	create_customerbillingsystemid := null::text,
	create_adminfirstname := 'Mark',
	create_adminlastname := 'Keller',
	create_adminemailaddress := 'keller@tendrel.io',
	create_adminphonenumber := null::text,
	create_adminidentityid := 'user_2j7hB374BA7oaodEeJoHGFmz7wB',
	create_adminidentitysystemuuid := '0c1e3a50-ed4c-4469-95bd-e091104ae9d5',
	create_adminuuid := null::text,
	create_siteuuid := null::text,
	create_timezone := 'America/Los_Angeles',
	create_languagetypeuuids := Array['7ebd10ee-5018-4e11-9525-80ab5c6aebee'],
	create_modifiedby := 337)

*/

---------------------------------------------
--need to convert the "languagetypeuuids and create_customerbillingsystemid from text to uuid"

templanguagetype_id = Array(select systagentityuuid 
							from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
							where systaguuid = ANY (create_languagetypeuuids));

tempcustomerbillingsystemuuid = (select systagentityuuid 
								from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
								where systaguuid = create_customerbillingsystemid);	

tempadminidentitysystemuuid = (select systagentityuuid 
								from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
								where systaguuid = create_adminidentitysystemuuid);	

call entity.crud_customer_create_tendrel(
	create_customername := create_customername,
	create_customeruuid := create_customeruuid,
	create_customerentityuuid := tempcustomerentityuuid,
	create_siteuuid := create_siteuuid,
	create_siteentityuuid := tempsiteentityuuid,
	create_customerparentuuid := null::uuid,
	create_customerowner := null::uuid,
	create_customerbillingid := create_customerbillingid,
	create_customerbillingsystemid := tempcustomerbillingsystemuuid,
	create_customerdeleted := null::boolean,
	create_customerdraft := null::boolean,
	create_adminfirstname := create_adminfirstname,
	create_adminlastname := create_adminlastname,
	create_adminemailaddress := create_adminemailaddress,
	create_adminphonenumber := create_adminphonenumber,
	create_adminidentityid := create_adminidentityid,
	create_adminidentitysystemuuid := tempadminidentitysystemuuid,
	create_adminid := templadminid,
	create_adminuuid := create_adminuuid,
	create_languagetypeuuids := templanguagetype_id,
	create_timezone := create_timezone,
	create_modifiedby := create_modifiedby,
	testlog := temptestlog);

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) TO tendreladmin WITH GRANT OPTION;

END;

BEGIN;

/*
DROP PROCEDURE entity.crud_customer_create_tendrel(text,uuid,uuid,text,uuid,boolean,boolean,text,text,text,text,text,uuid,uuid[],text,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_customer_create_tendrel(text,uuid,uuid,text,uuid,boolean,boolean,text,text,text,text,text,uuid,uuid[],text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_customer_create_tendrel(IN create_customername text, OUT create_customeruuid text, OUT create_customerentityuuid uuid, OUT create_siteuuid text, OUT create_siteentityuuid uuid, IN create_customerparentuuid uuid, IN create_customerowner uuid, IN create_customerbillingid text, IN create_customerbillingsystemid uuid, IN create_customerdeleted boolean, IN create_customerdraft boolean, INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid uuid, OUT create_adminid bigint, OUT create_adminuuid text, IN create_languagetypeuuids uuid[], IN create_timezone text, IN create_modifiedby bigint, OUT testlog text)
 LANGUAGE plpgsql
AS $procedure$
Declare

/*

	entity.crud_customer_create_tendrel(
		create_customername => text, 
		create_customeruuid => text, 
		create_customerentityuuid => uuid, 
		create_siteuuid => text, 
		create_siteentityuuid => uuid, 
		create_customerparentuuid => uuid, 
		create_customerowner => uuid, 
		create_customerbillingid => text, 
		create_customerbillingsystemid => text, 
		create_customerdeleted => boolean, 
		create_customerdraft => boolean, 
		create_adminfirstname => text, 
		create_adminlastname => text, 
		create_adminemailaddress => text, 
		create_adminphonenumber => text, 
		create_adminidentityid => text, 
		create_adminidentitysystemuuid => text, 
		create_adminid => text, 
		create_adminuuid => text, 
		create_languagetypeuuids => uuid[], 
		create_timezone => text, 
		create_modifiedby => bigint, 
		testlog => text)




-- generic version

call entity.crud_customer_create_tendrel(
	'Test'||now()::text, -- IN create_customername text,
	null, -- OUT create_customeruuid text,
	null, -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
	null, -- OUT create_siteuuid text,
	null, -- OUT create_siteentityuuid uuid	
	null, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
	null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
	('Bill'||now())::text, -- IN create_customerbillingid text,
	('c486a0d3-7c44-4129-9629-53920de84215'::text)::uuid, --	IN create_customerbillingsystemid uuid,
	null,
	null,
	'admin', --	create_adminfirstname
	'ln'||now()::text,	-- create_adminlastname  
	'admin@ln'||now()::text,	-- create_adminemailaddress 
	null,	-- create_adminphonenumber 
	'identity'||now()::text, --	create_adminidentityid 
	null, -- create_adminidentitysystemuuid text,
	null, -- create_adminid bigint,
	null, -- create_adminuuid text,
	ARRAY['bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'::uuid], -- IN create_languagetypeuuids uuid[],
	null,
	337::bigint, -- IN create_modifiedby bigint,
	null
	);
	
 */

Begin

-- default timezonee to UTC if there is no timezone
if create_timezone isNull
	then create_timezone = 'UTC' ;
end if;

-- create the customer/owner.  Pass through the data sent in.
-- FUTURE:  How will he handle Free tier?  Maybe a new customer type passed in during create?  

call entity.crud_customer_create(
		create_customername := create_customername,
		create_customeruuid := create_customeruuid,
		create_customerentityuuid:= create_customerentityuuid,
		create_customerparentuuid := create_customerparentuuid,
		create_customerowner := create_customerowner,
		create_customerbillingid := create_customerbillingid,
		create_customerbillingsystemid := create_customerbillingsystemid,
		create_customerdeleted := create_customerdeleted,
		create_customerdraft := create_customerdraft,
		create_languagetypeuuids := create_languagetypeuuids,
		create_modifiedby := create_modifiedby
	);

call entity.crud_admin_create(
		create_adminfirstname := create_adminfirstname,
		create_adminlastname := create_adminlastname,
		create_adminemailaddress := create_adminemailaddress,
		create_adminphonenumber := create_adminphonenumber,
		create_adminidentityid := create_adminidentityid,
		create_adminidentitysystemuuid := create_adminidentitysystemuuid,
		create_adminid := create_adminid,
		create_adminuuid := create_adminuuid,
		create_customerentityuuid := create_customerentityuuid,
		create_languagetypeuuids := create_languagetypeuuids,
		create_modifiedby := create_modifiedby
	);

-- create the initial site/location.  

call entity.crud_location_create(
		create_locationownerentityuuid := create_customerentityuuid, 
		create_locationparententityuuid := null, 
		create_locationcornerstoneentityuuid := null, 
		create_locationcornerstoneorder := null, 
		create_locationtaguuid := null, 
		create_locationtag := 'site', 
		create_locationname := 'My Site', 
		create_locationdisplayname := 'My Site', 
		create_locationscanid := null, 
		create_locationtimezone := create_timezone, 
		create_languagetypeuuid := create_languagetypeuuids[1], 
		create_locationexternalid := null, 
		create_locationexternalsystemuuid := null, 
		create_locationlatitude := null, 
		create_locationlongitude := null, 
		create_locationradius := null, 
		create_locationdeleted := null, 
		create_locationdraft := null, 
		create_locationentityuuid := create_siteentityuuid, 
		create_modifiedbyid := create_modifiedby
	);

-- enable timeclock
-- call entity.enable_timesheet(
-- 				create_customer_uuid := create_customerentityuuid,
-- 				create_original_customer_uuid := null,
-- 				create_site_uuid :=create_siteentityuuid,
-- 				create_original_site_uuid := null,
-- 				create_language_type_uuid := create_languagetypeuuids[1],
-- 				create_original_language_type_uuid := null,
-- 				create_timezone := create_timezone,
-- 				create_modifiedby := create_modifiedby);

-- enable pinpoint
-- call entity.enable_pinpoint(
-- 				create_customer_uuid := create_customerentityuuid,
-- 				create_original_customer_uuid := null,
-- 				create_site_uuid :=create_siteentityuuid,
-- 				create_original_site_uuid := null,
-- 				create_language_type_uuid := create_languagetypeuuids[1],
-- 				create_original_language_type_uuid := null,
-- 				create_timezone := create_timezone,
-- 				create_modifiedby := create_modifiedby);

-- enable checklist
-- call entity.enable_checklist(
-- 				create_customer_uuid := create_customerentityuuid,
-- 				create_original_customer_uuid := null,
-- 				create_site_uuid :=create_siteentityuuid,
-- 				create_original_site_uuid := null,
-- 				create_language_type_uuid := create_languagetypeuuids[1],
-- 				create_original_language_type_uuid := null,
-- 				create_timezone := create_timezone,
-- 				create_modifiedby := create_modifiedby);

-- enable runtime
call entity.enable_runtime(
				create_customer_uuid := create_customerentityuuid,
				create_original_customer_uuid := null,
				create_site_uuid :=create_siteentityuuid,
				create_original_site_uuid := null,
				create_language_type_uuid := create_languagetypeuuids[1],
				create_original_language_type_uuid := null,
				modified_by := create_modifiedby,
				timezone := create_timezone,
				testlog := testlog
			);

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customer_create_tendrel(text,uuid,uuid,text,uuid,boolean,boolean,text,text,text,text,text,uuid,uuid[],text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_create_tendrel(text,uuid,uuid,text,uuid,boolean,boolean,text,text,text,text,text,uuid,uuid[],text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_create_tendrel(text,uuid,uuid,text,uuid,boolean,boolean,text,text,text,text,text,uuid,uuid[],text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_customer_create_tendrel(text,uuid,uuid,text,uuid,boolean,boolean,text,text,text,text,text,uuid,uuid[],text,bigint) TO graphql;

END;

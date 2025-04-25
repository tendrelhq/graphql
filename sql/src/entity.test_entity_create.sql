
-- Type: PROCEDURE ; Name: entity.test_entity_create(boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.test_entity_create(IN create_newcustomer boolean, IN create_modifiedby bigint, OUT create_failedtest boolean, OUT create_failedtestcount integer, OUT create_successtestcount integer, OUT create_passedtext text, OUT create_failedtext text)
 LANGUAGE plpgsql
AS $procedure$
Declare
    fact_start timestamp with time zone;
    fact_end timestamp with time zone;	
	temptext text;
	testmastercustomeruuid text;
	testmastercustomerentityuuid uuid;
	testsubcustomeruuid text;
	testsubcustomerentityuuid uuid;
	testsub2customeruuid text;
	testsub2customerentityuuid uuid;
	testsub4customeruuid text;
	testsub4customerentityuuid uuid;
	testsiteuuid uuid;
	testlocationuuid uuid;
	testlocation2uuid uuid;
	englishuuid uuid;
	spanishuuid uuid;
	billinguuid uuid;
	testcount integer;
	testsystagid bigint;
	testsystaguuid text;
	testsystagentityuuid uuid;	
	testcustagid bigint;
	testcustaguuid text;
	testcustagentityuuid uuid;	
	testsystagparentuuid uuid;
	tendreluuid uuid;
	testparentsystagid bigint;
	testparentsystaguuid text;
	testparentsystagentityuuid uuid;	
	testcustagparentuuid uuid;
	tendreltestuuid uuid;
	testtendrelcustagparentuuid uuid;
	testparentcustagid bigint;
	testparentcustaguuid text;
	testparentcustagentityuuid uuid;	
	testentitytemplateuuid uuid;
	testlocationcategoryuuid uuid;
	testentityfielduuid uuid;
	testentityfiel2duuid uuid;	
	testentityfieldtypeuuid uuid;
	testentitywidgettypeuuid uuid;
	testentitydescriptionuuid uuid;
	testentityinstanceuuid uuid;
	testentityfieldinstanceuuid uuid;
	testentityfileinstanceuuid uuid;
	
Begin
--  call entity.test_create( true, 337, null,null,null,null,null)
--  call entity.test_create( false, 337, null,null,null,null,null)

 -- Start the timer on this function
    fact_start = clock_timestamp();
	create_failedtest = false;
	temptext = '';
	create_failedtext = '';
	create_passedtext = '';
	create_failedtestcount = 0;
	create_successtestcount = 0;	
	englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	spanishuuid = '6893da1e-96fa-4412-a340-5795219476cd';
	billinguuid = 'c486a0d3-7c44-4129-9629-53920de84215';
	tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
	testsystagparentuuid = '30f65cf5-97a0-4e3d-a518-056521bf4f3d';  -- old systemid we don't use
	testcustagparentuuid = 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba';
	tendreltestuuid = '70f200bd-1c92-481d-9f5c-e6cf6cd92cd0';
	testtendrelcustagparentuuid = 'a4cec370-72ed-4717-b1c7-1fcd01c866b2';
	testlocationcategoryuuid = 'bb05d944-f7ba-4e40-b1d7-f2e3c0608c4c';
	testentityfieldtypeuuid = '2de2bbde-6319-4886-a58d-bf9d369fc677';
	testentitywidgettypeuuid = '0bf3e80c-ff85-4f5a-9586-56519dca4d2e';
	
	

------------------------
-- create customer test
------------------------
if create_newcustomer = true  
	then  
		-- Create Master Account - Pass logic
		call entity.crud_customer_create(
			'Test Account (Master)'||clock_timestamp()::text, -- IN create_customername text,
			testmastercustomeruuid, -- OUT create_customeruuid text,
			testmastercustomerentityuuid, -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
			null, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
			null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
			('Bill'||clock_timestamp())::text, -- IN create_customerbillingid text,
			billinguuid, --	IN create_customerbillingsystemid uuid,
			null,
			null,
			ARRAY[englishuuid], -- IN create_languagetypeuuids uuid[],
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testmastercustomerentityuuid isNull 
			then create_failedtext = create_failedtext||'Create Master Account - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Master Account - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;
		
		-- Create English Sub Account - Pass logic
		if 	testmastercustomerentityuuid notNull 
			then 
				call entity.crud_customer_create(
					'Test English Account (Sub)'||clock_timestamp()::text, -- IN create_customername text,
					testsubcustomeruuid , -- OUT create_customeruuid text,
					testsubcustomerentityuuid  , -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
					testmastercustomerentityuuid, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
					null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
					('Bill'||clock_timestamp())::text, -- IN create_customerbillingid text,
					billinguuid, --	IN create_customerbillingsystemid uuid,
					null,
					null,
					ARRAY[englishuuid], -- IN create_languagetypeuuids uuid[],
					create_modifiedby );
				fact_end = 	clock_timestamp();
		end if;

		-- update the test score for pass and fail	
		if 	testsubcustomerentityuuid isNull 
			then create_failedtext = create_failedtext||'Create English Sub Account - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create English Sub Account - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

		-- Create Spanish Sub Account - Pass logic
		if 	testsubcustomerentityuuid notNull 
			then 
				call entity.crud_customer_create(
					'Test Spanish Account (Sub)'||clock_timestamp()::text, -- IN create_customername text,
					testsub2customeruuid  , -- OUT create_customeruuid text,
					testsub2customerentityuuid   , -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
					testmastercustomerentityuuid, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
					null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
					('Bill'||clock_timestamp())::text, -- IN create_customerbillingid text,
					billinguuid, --	IN create_customerbillingsystemid uuid,
					null,
					null,
					ARRAY[spanishuuid], -- IN create_languagetypeuuids uuid[],
					create_modifiedby );
				fact_end = 	clock_timestamp();
		end if;

		-- update the test score for pass and fail	
		if 	testsub2customerentityuuid isNull 
			then create_failedtext = create_failedtext||'Create Spanish Sub Account - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Spanish Sub Account - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

		-- Create Account - Fail logic
		if 	testmastercustomerentityuuid notNull 
			then 
				call entity.crud_customer_create(
					null, -- IN create_customername text,
					testsub4customeruuid  , -- OUT create_customeruuid text,
					testsub4customerentityuuid   , -- OUT create_customerentityuuid uuid, -- added this.  Need to handle it.	
					testmastercustomerentityuuid, -- IN create_customerparentuuid uuid,  -- added this.  Need to handle it.
					null, -- IN create_customerowner uuid,  -- added this.  Need to handle it.
					('Bill'||clock_timestamp())::text, -- IN create_customerbillingid text,
					billinguuid, --	IN create_customerbillingsystemid uuid,
					null,
					null,
					ARRAY[englishuuid], -- IN create_languagetypeuuids uuid[],
					create_modifiedby );
				fact_end = 	clock_timestamp();
		end if;

		-- update the test score for pass and fail	
		if 	testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Create Account No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Account No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;		

	-- customer delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer');
		
		if 	testsub2customerentityuuid notNull 
			then 
				call entity.crud_customer_delete(
					null, -- IN create_customerownerentityuuid uuid,
					testsub2customerentityuuid , -- IN create_customerentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer') and testsub2customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Customer Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no customer entity isNull
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer');
		
		if 	testsub2customerentityuuid notNull 
			then 
				call entity.crud_customer_delete(
					testsub2customerentityuuid, -- IN create_customerownerentityuuid uuid,
					null, -- IN create_customerentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer') and testsub2customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Customer Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and customer combo do not exist
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer');
		
		if 	testsub2customerentityuuid notNull 
			then 
				call entity.crud_customer_delete(
					testsubcustomerentityuuid, -- IN create_customerownerentityuuid uuid,
					testsub2customerentityuuid, -- IN create_customerentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer')  and testsub2customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Customer Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and customer combo 
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer');
		
		if 	testsub2customerentityuuid notNull 
			then 
				call entity.crud_customer_delete(
					testsub2customerentityuuid, -- IN create_customerownerentityuuid uuid,
					testsub2customerentityuuid, -- IN create_customerentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer') and testsub2customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Customer Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the customer
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = testsub2customerentityuuid;

end if;

------------------------
-- create location tests
------------------------

if testsub4customerentityuuid isnull and create_newcustomer = false
	then testsub4customerentityuuid = 'f02b1c6c-394a-4634-b8c3-fb5abc16b8d7';
	else testsub4customerentityuuid = testsub2customerentityuuid;
end if;

		-- New site new location type no parent no cornerstone
		call entity.crud_location_create(
			testsub4customerentityuuid, --create_locationownerentityuuid
			null,	--create_locationparententityuuid
			null,   --create_locationcornerstoneentityuuid
			null, --create_locationcornerstoneorder 
			null, -- create_locationtaguuid,
			'locationtag'||clock_timestamp(),  -- create_locationtag
			'sitename'||clock_timestamp(),  -- create_locationname
			'sitedisplayname'||clock_timestamp(), -- locationdisplayname 
			'sitescanid'||clock_timestamp(), -- locationscanid	
			'America/Los_Angeles',  -- locationtimezone
			englishuuid, -- languagetypeuuid  
			null,  -- locationexternalid
			null, -- locationexternalsystemuuid
			null, -- locationlatitude 
			null, -- locationlongitude
			null, -- locationradius
			null,
			null,
			testsiteuuid, -- OUT create_locationentityuuid
			create_modifiedby);
		fact_end = 	clock_timestamp();
		
		-- update the test score for pass and fail		
		if 	testsiteuuid isNull 
			then create_failedtext = create_failedtext||'Create Site - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Site - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;
		
-- New location existing parent new location tag
		call entity.crud_location_create(
			testsub4customerentityuuid, --create_locationownerentityuuid
			testsiteuuid,	--create_locationparententityuuid
			null,   --create_locationcornerstoneentityuuid
			null, --create_locationcornerstoneorder 
			null, -- create_locationtaguuid,
			'locationsubtag'||clock_timestamp(),  -- create_locationtag
			'locationname'||clock_timestamp(),  -- create_locationname
			'locationdisplayname'||clock_timestamp(), -- locationdisplayname 
			'locationscanid'||clock_timestamp(), -- locationscanid	
			'America/Los_Angeles',  -- locationtimezone
			englishuuid, -- languagetypeuuid  
			null,  -- locationexternalid
			null, -- locationexternalsystemuuid
			null, -- locationlatitude 
			null, -- locationlongitude
			null, -- locationradius
			null,
			null,
			testlocationuuid, -- OUT create_locationentityuuid
			create_modifiedby::bigint);	
		fact_end = 	clock_timestamp();
		
		-- update the test score for pass and fail		
		if 	testlocationuuid isNull 
			then create_failedtext = create_failedtext||'Create Location - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Location - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- Create Location - Fail logic
		call entity.crud_location_create(
			testsub4customerentityuuid, --create_locationownerentityuuid
			testsiteuuid,	--create_locationparententityuuid
			null,   --create_locationcornerstoneentityuuid
			null, --create_locationcornerstoneorder 
			null, -- create_locationtaguuid,
			'locationsubtag'||clock_timestamp(),  -- create_locationtag
			null,  -- create_locationname
			'locationdisplayname'||clock_timestamp(), -- locationdisplayname 
			'locationscanid'||clock_timestamp(), -- locationscanid	
			'America/Los_Angeles',  -- locationtimezone
			englishuuid, -- languagetypeuuid  
			null,  -- locationexternalid
			null, -- locationexternalsystemuuid
			null, -- locationlatitude 
			null, -- locationlongitude
			null, -- locationradius
			null,
			null,
			testlocation2uuid, -- OUT create_locationentityuuid
			create_modifiedby::bigint);	
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testlocation2uuid notNull 
			then create_failedtext = create_failedtext||'Create Location No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Location No Name Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- location delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location');
		
		if 	testlocationuuid notNull 
			then 
				call entity.crud_location_delete(
					null, -- IN create_locationownerentityuuid uuid,
					testlocationuuid, -- IN create_locationentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location') and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Location Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Location Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no location entity isNull
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location');
		
		if 	testlocationuuid notNull 
			then 
				call entity.crud_location_delete(
					testsub4customerentityuuid, -- IN create_locationownerentityuuid uuid,
					null, -- IN create_locationentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location') and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Location Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Location Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and customer combo do not exist
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location');
		
		if 	testlocationuuid notNull 
			then 
				call entity.crud_location_delete(
					tendreluuid, -- IN create_locationownerentityuuid uuid,
					testlocationuuid, -- IN create_locationentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location')  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Location Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Location Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and customer combo 
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location');
						
		if 	testlocationuuid notNull 
			then 
				call entity.crud_location_delete(
					testsub4customerentityuuid, -- IN create_locationownerentityuuid uuid,
					testlocationuuid, -- IN create_locationentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Location') and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Location Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Location Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the location
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = testlocationuuid;

---------------
-- Test Systags
---------------

		-- If systag isNull then it should do nothing
		call entity.crud_systag_create(
			tendreluuid, --create_systagownerentityuuid
			testsystagparentuuid, --create_systagparententityuuid
			null,   --create_systagcornerstoneentityuuid
			null, --create_systagcornerstoneorder 
			null,  -- create_systag
			englishuuid, -- create_languagetypeuuid  
			null,  -- 	create_systagexternalid text,
			null, -- create_systagexternalsystemuuid
			null, 
			null, 
			testsystagid , -- OUT create_systagid
			testsystaguuid , -- OUT create_systaguuid text,
			testsystagentityuuid , -- OUT create_systagentityuuid uuid
			create_modifiedby);
		fact_end = 	clock_timestamp();
		
		-- update the test score for pass and fail		
		if 	testsystagentityuuid notNull 
			then create_failedtext = create_failedtext||'Create Systag No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Systag No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- If systag is a duplicate then return an error
		call entity.crud_systag_create(
			tendreluuid, --create_systagownerentityuuid
			testsystagparentuuid, --create_systagparententityuuid
			null,   --create_systagcornerstoneentityuuid
			null, --create_systagcornerstoneorder 
			'Microsoft',  -- create_systag
			englishuuid, -- create_languagetypeuuid  
			null,  -- 	create_systagexternalid text,
			null, -- create_systagexternalsystemuuid
			null, 
			null, 
			testsystagid , -- OUT create_systagid
			testsystaguuid , -- OUT create_systaguuid text,
			testsystagentityuuid , -- OUT create_systagentityuuid uuid
			create_modifiedby);
		fact_end = 	clock_timestamp();
		
		if 	testsystagentityuuid notNull 
			then create_failedtext = create_failedtext||'Create Systag Duplicate - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Systag Duplicate - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- Create a Parent Tag	
		call entity.crud_systag_create(
			tendreluuid, --create_systagownerentityuuid
			null,	--create_systagparententityuuid
			null,   --create_systagcornerstoneentityuuid
			null, --create_systagcornerstoneorder 
			'parentsystag'||clock_timestamp(),  -- create_systag
			englishuuid, -- create_languagetypeuuid  
			null,  -- 	create_systagexternalid text,
			null, -- create_systagexternalsystemuuid
			null,
			null,
			testparentsystagid , -- OUT create_systagid
			testparentsystaguuid , -- OUT create_systaguuid text,
			testparentsystagentityuuid , -- OUT create_systagentityuuid uuid
			create_modifiedby);

		if 	testparentsystagentityuuid isNull 
			then create_failedtext = create_failedtext||'Create Parent Tag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Parent Tag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- Create a Sub Tag	

		call entity.crud_systag_create(
			tendreluuid, --create_systagownerentityuuid
			testparentsystagentityuuid,	--create_systagparententityuuid  -- use the rertun from the previous test.  
			null,   --create_systagcornerstoneentityuuid
			null, --create_systagcornerstoneorder 
			'subsystag'||clock_timestamp(),  -- create_systag
			englishuuid, -- create_languagetypeuuid  
			null,  -- 	create_systagexternalid text,
			null, -- create_systagexternalsystemuuid
			null,
			null,
			testsystagid, -- OUT create_systagid
			testsystaguuid, -- OUT create_systaguuid text,
			testsystagentityuuid, -- OUT create_systagentityuuid uuid
			create_modifiedby);

		if 	testsystagentityuuid isNull 
			then create_failedtext = create_failedtext||'Create Parent Tag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Parent Tag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;
		
	-- System Tag delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag');
		
		if 	testsystagentityuuid notNull 
			then 
				call entity.crud_systag_delete(
					null, -- IN create_systagownerentityuuid uuid,
					testsystagentityuuid, -- IN create_systagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag') and tendreluuid notNull 
			then create_failedtext = create_failedtext||'System Tag Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'System Tag Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no System Tag entity isNull
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag');
		
		if 	testsystagentityuuid notNull 
			then 
				call entity.crud_systag_delete(
					tendreluuid, -- IN create_systagownerentityuuid uuid,
					null, -- IN create_systagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag') and tendreluuid notNull 
			then create_failedtext = create_failedtext||'System Tag Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'System Tag Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and System Tag combo do not exist
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag');
		
		if 	testsystagentityuuid notNull 
			then 
				call entity.crud_systag_delete(
					testsub4customerentityuuid, -- IN create_systagownerentityuuid uuid,
					testsystagentityuuid, -- IN create_systagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag')  and tendreluuid notNull 
			then create_failedtext = create_failedtext||'System Tag Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'System Tag Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and System Tag combo 
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag');
						
		if 	testsystagentityuuid notNull 
			then 
				call entity.crud_systag_delete(
					tendreluuid, -- IN create_systagownerentityuuid uuid,
					testsystagentityuuid, -- IN create_systagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'System Tag') and tendreluuid notNull 
			then create_failedtext = create_failedtext||'System Tag Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'System Tag Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the System Tag
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = testsystagentityuuid;	

if testsub4customerentityuuid isnull and create_newcustomer = false
	then testsub4customerentityuuid = 'f02b1c6c-394a-4634-b8c3-fb5abc16b8d7';
end if;

---------------
-- Test Custag
---------------

		-- If Custag isNull then it should do nothing
			call entity.crud_custag_create(
				testsub4customerentityuuid, --create_custagownerentityuuid
				testcustagparentuuid, --create_custagparententityuuid
				null,   --create_custagcornerstoneentityuuid
				null, --create_custagcornerstoneorder 
				null,  -- create_custag
				englishuuid, -- create_languagetypeuuid  
				null,  -- 	create_custagexternalid text,
				null, -- create_custagexternalsystemuuid
				null, 
				null, 
				testcustagid , -- OUT create_systagid
				testcustaguuid , -- OUT create_systaguuid text,
				testcustagentityuuid , -- OUT create_systagentityuuid uuid
				create_modifiedby);
			fact_end = 	clock_timestamp();
				
		-- update the test score for pass and fail		
		if 	testcustagentityuuid notNull 
			then create_failedtext = create_failedtext||'Create Custag No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Custag No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- If custag is a duplicate then return an error
			call entity.crud_custag_create(
				tendreltestuuid, --create_custagownerentityuuid
				testtendrelcustagparentuuid, --create_custagparententityuuid
				null,   --create_custagcornerstoneentityuuid
				null, --create_custagcornerstoneorder 
				'Ship',  -- create_custag
				englishuuid, -- create_languagetypeuuid  
				null,  -- 	create_custagexternalid text,
				null, -- create_custagexternalsystemuuid
				null, 
				null, 
				testcustagid , -- OUT create_systagid
				testcustaguuid , -- OUT create_systaguuid text,
				testcustagentityuuid , -- OUT create_systagentityuuid uuid
				create_modifiedby);
		
		if 	testcustagentityuuid notNull 
			then create_failedtext = create_failedtext||'Create Custag Duplicate - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Custag Duplicate - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- custag to a systag 	

			call entity.crud_custag_create(
				tendreltestuuid, --create_custagownerentityuuid
				testtendrelcustagparentuuid, --create_custagparententityuuid
				null,   --create_custagcornerstoneentityuuid
				null, --create_custagcornerstoneorder 
				'custag'||clock_timestamp(),  -- create_custag
				englishuuid, -- create_languagetypeuuid  
				null,  -- 	create_custagexternalid text,
				null, -- create_custagexternalsystemuuid
				null, 
				null, 
				testcustagid , -- OUT create_systagid
				testcustaguuid , -- OUT create_systaguuid text,
				testcustagentityuuid , -- OUT create_systagentityuuid uuid
				create_modifiedby);

		if 	testcustagentityuuid isNull 
			then create_failedtext = create_failedtext||'Create a custag to a systag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create a custag to a systag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- custag that is the start of a tree 

		call entity.crud_custag_create(
				tendreltestuuid, --create_custagownerentityuuid
				null,	--create_custagparententityuuid
				null,   --create_custagcornerstoneentityuuid
				null, --create_custagcornerstoneorder 
				'parentcustag'||clock_timestamp(),  -- create_custag
				englishuuid, -- create_languagetypeuuid  
				null,  -- 	create_custagexternalid text,
				null, -- create_custagexternalsystemuuid
				null, 
				null, 
				testparentcustagid, -- OUT create_systagid
				testparentcustaguuid, -- OUT create_systaguuid text,
				testparentcustagentityuuid, -- OUT create_systagentityuuid uuid
				create_modifiedby);

		if 	testparentcustagentityuuid isNull 
			then create_failedtext = create_failedtext||'Create a parent custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create a parent custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

		testcustagid = null;
		testcustaguuid = null;
		testcustagentityuuid = null;
		
		call entity.crud_custag_create(
				tendreltestuuid, --create_custagownerentityuuid
				testparentcustagentityuuid,	--create_custagparententityuuid  -- use the rertun from the previous test.  
				null,   --create_custagcornerstoneentityuuid
				null, --create_custagcornerstoneorder 
				'subcustag'||clock_timestamp(),  -- create_custag
				englishuuid, -- create_languagetypeuuid  
				null,  -- 	create_custagexternalid text,
				null, -- create_custagexternalsystemuuid
				null, 
				null, 
				testcustagid , -- OUT create_systagid
				testcustaguuid , -- OUT create_systaguuid text,
				testcustagentityuuid , -- OUT create_systagentityuuid uuid
				create_modifiedby);

		if 	testcustagentityuuid isNull 
			then create_failedtext = create_failedtext||'Create a custag to a custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create a custag to a custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;		

	-- Customer Tag delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag');
		
		if 	testcustagentityuuid notNull 
			then 
				call entity.crud_custag_delete(
					null, -- IN create_custagownerentityuuid uuid,
					testcustagentityuuid, -- IN create_custagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag') and tendreltestuuid notNull 
			then create_failedtext = create_failedtext||'Customer Tag Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Tag Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no Customer Tag entity isNull
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag');
		
		if 	testcustagentityuuid notNull 
			then 
				call entity.crud_custag_delete(
					tendreltestuuid, -- IN create_custagownerentityuuid uuid,
					null, -- IN create_custagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag') and tendreltestuuid notNull 
			then create_failedtext = create_failedtext||'Customer Tag Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Tag Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Customer Tag combo do not exist
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag');
		
		if 	testcustagentityuuid notNull 
			then 
				call entity.crud_custag_delete(
					tendreluuid, -- IN create_custagownerentityuuid uuid,
					testcustagentityuuid, -- IN create_custagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag')  and tendreltestuuid notNull 
			then create_failedtext = create_failedtext||'Customer Tag Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Tag Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Customer Tag combo 
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag');
						
		if 	testcustagentityuuid notNull 
			then 
				call entity.crud_custag_delete(
					tendreltestuuid, -- IN create_custagownerentityuuid uuid,
					testcustagentityuuid, -- IN create_custagentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceentitytemplatename = 'Customer Tag') and tendreltestuuid notNull 
			then create_failedtext = create_failedtext||'Customer Tag Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Customer Tag Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the Customer Tag
		update entity.entityinstance
		set entityinstancedeleted = false
		where entityinstanceuuid = testcustagentityuuid;	

if testsub4customerentityuuid isnull and create_newcustomer = false
	then testsub4customerentityuuid = 'f02b1c6c-394a-4634-b8c3-fb5abc16b8d7';
end if;

------------------------------------------------------------------------------------------------

-----------------------
-- Test Entity Template
-----------------------

		-- no enity name
		call entity.crud_entitytemplate_create(
			null,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			null, -- Used to be only locations had a location category. 
			null,  -- If a tag is sent in that does not exist then we create one at the template level.
			null,  -- Name of the template 
			false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			null, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
			create_modifiedby); -- IN create_modifiedbyid bigint
		fact_end = 	clock_timestamp();
		
		-- update the test score for pass and fail		
		if 	testentitytemplateuuid notNull 
			then create_failedtext = create_failedtext||'Create Entity Template No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

-- no owner no parent no templatetaguuid no tag no languagetype - lazy init
		call entity.crud_entitytemplate_create(
			null,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			null, -- Used to be only locations had a location category.
			null,  -- If a tag is sent in that does not exist then we create one at the template level.
			'entitytemplate'||clock_timestamp()::text,  -- Name of the template 
			true, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			'scanid'||clock_timestamp()::text, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
			create_modifiedby); -- IN create_modifiedbyid bigint
		fact_end = 	clock_timestamp();
					
		-- update the test score for pass and fail		
		if 	testentitytemplateuuid isNull 
			then create_failedtext = create_failedtext||'Create Entity Template lazy init - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template No Name - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;		

-- invalid owner  -- not a customer (error)

		testentitytemplateuuid = null;

	call entity.crud_entitytemplate_create(
		englishuuid,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
		null,  -- merged site and parent.  Set to self if no parent sent in.
		null,  -- default is 1.
		null, -- Used to be only locations had a location category.
		null,  -- If a tag is sent in that does not exist then we create one at the template level.
		'entitytemplate'||clock_timestamp()::text,  -- Name of the template 
		false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
		'scanid'||clock_timestamp()::text, -- create_entitytemplatescanid text,  
		null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
		null, -- create_entitytemplateexternalid text,
		null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
		null,-- create_entitytemplatedeleted boolean,
		null,-- create_entitytemplatedraft boolean,
		testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
		create_modifiedby); 
		
		-- update the test score for pass and fail		
		if 	testentitytemplateuuid notNull 
			then create_failedtext = create_failedtext||'Create Entity Template invalid owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template invalid owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- valid owner
		
		call entity.crud_entitytemplate_create(
			null,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			null, -- Used to be only locations had a location category.
			null,  -- If a tag is sent in that does not exist then we create one at the template level.
			'entitytemplate'||clock_timestamp()::text,  -- Name of the template 
			true, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			'scanid'||clock_timestamp()::text, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
			create_modifiedby); -- IN create_modifiedbyid bigint
		fact_end = 	clock_timestamp();
					
		-- update the test score for pass and fail		
		if 	testentitytemplateuuid isNull 
			then create_failedtext = create_failedtext||'Create Entity Template valid owner - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template valid owner - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;		

	-- invalid owner  -- not a customer (error)

		testentitytemplateuuid = null;

		call entity.crud_entitytemplate_create(
			englishuuid,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			null, -- Used to be only locations had a location category.
			null,  -- If a tag is sent in that does not exist then we create one at the template level.
			'entitytemplate'||clock_timestamp()::text,  -- Name of the template 
			false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			'scanid'||clock_timestamp()::text, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();
		
		-- update the test score for pass and fail		
		if 	testentitytemplateuuid notNull 
			then create_failedtext = create_failedtext||'Create Entity Template invalid owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template invalid owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

-- invalid taguuid (becomes null) with valid tag name
		testentitytemplateuuid = null;
		
		call entity.crud_entitytemplate_create(
			testsub4customerentityuuid,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			'00014b06-73b8-464b-8881-0ef9dfb7b712', -- Used to be only locations had a location category.
			'TestTag'||clock_timestamp()::text,  -- If a tag is sent in that does not exist then we create one at the template level.
			'entitytemplate'||clock_timestamp()::text,  -- Name of the template 
			false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			'scanid'||clock_timestamp()::text, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
			create_modifiedby); 
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentitytemplateuuid isNull 
			then create_failedtext = create_failedtext||'Create Entity Template invalid taguuid (becomes null) with valid tag name - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template invalid taguuid (becomes null) with valid tag name - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	
		
-- valid taguuid

		testentitytemplateuuid = null;

		call entity.crud_entitytemplate_create(
			testsub4customerentityuuid,  -- This used to be customer.  Should be sent in from the auth token. Default is cust 0.   
			null,  -- merged site and parent.  Set to self if no parent sent in.
			null,  -- default is 1.
			testlocationcategoryuuid, -- Used to be only locations had a location category.
			null,  -- If a tag is sent in that does not exist then we create one at the template level.
			'entitytemplate'||clock_timestamp()::text,  -- Name of the template 
			false, -- Mainly for entities that tendrel wants to govern.  customers cannot create this.  
			'scanid'||clock_timestamp()::text, -- create_entitytemplatescanid text,  
			null, -- create_languagetypeuuid uuid,  -- language the name/display name is in
			null, -- create_entitytemplateexternalid text,
			null,-- create_entitytemplateexternalsystemuuid uuid,  -- system tag for external system
			null,-- create_entitytemplatedeleted boolean,
			null,-- create_entitytemplatedraft boolean,
			testentitytemplateuuid, -- create_entitytemplateentityuuid uuid,
			create_modifiedby); 
		fact_end = 	clock_timestamp();

		if 	testentitytemplateuuid isNull 
			then create_failedtext = create_failedtext||'Create Entity Template valid taguuid - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Entity Template valid taguuid - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- Entity Template delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid);
		
		if 	testentitytemplateuuid notNull 
			then 
				call entity.crud_entitytemplate_delete(
					null, -- IN create_entitytemplateownerentityuuid uuid,
					testentitytemplateuuid, -- IN create_entitytemplateentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Template Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Template Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no Customer Tag entity isNull
		testcount = (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid);
		
		if 	testentitytemplateuuid notNull 
			then 
				call entity.crud_entitytemplate_delete(
					testsub4customerentityuuid, -- IN create_entitytemplateownerentityuuid uuid,
					null, -- IN create_entitytemplateentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Template Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Template Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Entity Template combo do not exist
		testcount = (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid);

		if 	testentitytemplateuuid notNull 
			then 
				call entity.crud_entitytemplate_delete(
					tendreluuid, -- IN create_entitytemplateownerentityuuid uuid,
					testentitytemplateuuid, -- IN create_entitytemplateentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid)  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Template Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Template Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Entity Template combo 
		testcount = (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid);
						
		if 	testentitytemplateuuid notNull 
			then 
				call entity.crud_entitytemplate_delete(
					testsub4customerentityuuid, -- IN create_entitytemplateownerentityuuid uuid,
					testentitytemplateuuid, -- IN create_entitytemplateentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entitytemplate 
					where entitytemplatedeleted = true
						and entitytemplateuuid = testentitytemplateuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Template Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Template Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the Entity Template
		update entity.entitytemplate
		set entitytemplatedeleted = false
		where entitytemplateuuid = testentitytemplateuuid;	

--------------------
-- test entity field
--------------------
		-- no field name
		call entity.crud_entityfield_create(
			null, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			null, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			null, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field No Name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- no template
		call entity.crud_entityfield_create(
			null, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			null, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);	
		fact_end = 	clock_timestamp();
		
		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field no template - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  no template - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- invalid customer valid template
		call entity.crud_entityfield_create(
			englishuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();
		
		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field invalid customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  invalid customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- valid customer valid template invalid combo
		call entity.crud_entityfield_create(
			tendreluuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field  - template invalid combo - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  - template invalid combo - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- invalid field type
		call entity.crud_entityfield_create(
			testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			'b07bf96e-0a35-4b01-bcc0-863dc7b3db0c', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field  - invalid field type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  - invalid field type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- invalid entity type
		call entity.crud_entityfield_create(
			testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			testentityfieldtypeuuid, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			'7bbaa455-1965-4171-95f1-ee9f22a98f10', -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field  - invalid entity type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  - invalid entity type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- invalid format type

		call entity.crud_entityfield_create(
			testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			testentityfieldtypeuuid, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field  - invalid format type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  - invalid format type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- invalid widget type

		call entity.crud_entityfield_create(
			testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			testentityfieldtypeuuid, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			'4f13599f-8766-4589-b80f-77ff00819380', -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfielduuid notNull 
			then create_failedtext = create_failedtext||'Create Field  - invalid widget type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field  - invalid widget type - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- valid insert-- existing widget. 

		call entity.crud_entityfield_create(
			testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			5, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			testentityfieldtypeuuid, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			'Test', -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			testentitywidgettypeuuid, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfielduuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfielduuid isNull 
			then create_failedtext = create_failedtext||'Create Field valid insert-- existing widget - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field valid insert-- existing widget - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

--  valid insert-- new widget-format		

		call entity.crud_entityfield_create(
			testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			testentitytemplateuuid, -- IN create_entityfieldtemplateentityuuid uuid,
			5, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||clock_timestamp()::text, -- IN create_entityfieldname text,
			testentityfieldtypeuuid, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			'testvalue'||clock_timestamp()::text, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			'format'||clock_timestamp()::text, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			'widget'||clock_timestamp()::text,  -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			testentityfiel2duuid, -- OUT create_entityfieldentityuuid uuid,
			create_modifiedby);
		fact_end = 	clock_timestamp();

		if 	testentityfiel2duuid isNull 
			then create_failedtext = create_failedtext||'Create Field valid insert-- new widget-format - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create Field valid insert-- existing widget - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- Entity Field delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid);
		
		if 	testentityfielduuid notNull 
			then 
				call entity.crud_entityfield_delete(
					null, -- IN create_entityfieldownerentityuuid uuid,
					testentityfielduuid, -- IN create_entityfieldentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no Customer Tag entity isNull
		testcount = (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid);
		
		if 	testentityfielduuid notNull 
			then 
				call entity.crud_entityfield_delete(
					testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,
					null, -- IN create_entityfieldentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Entity Field combo do not exist
		testcount = (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid);
		
		if 	testentityfielduuid notNull 
			then 
				call entity.crud_entityfield_delete(
					tendreluuid, -- IN create_entityfieldownerentityuuid uuid,
					testentityfielduuid, -- IN create_entityfieldentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid)  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Entity Field combo 
		testcount = (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid);
						
		if 	testentityfielduuid notNull 
			then 
				call entity.crud_entityfield_delete(
					testsub4customerentityuuid, -- IN create_entityfieldownerentityuuid uuid,
					testentityfielduuid, -- IN create_entityfieldentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityfield 
					where entityfielddeleted = true
						and entityfielduuid = testentityfielduuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the Entity Field
		update entity.entityfield
		set entityfielddeleted  = false
		where entityfielduuid = testentityfielduuid;	

--------------------------------------------------------------------------------------

---------------------
-- entity description
---------------------

	-- bogus owner fail

		call entity.crud_entitydescription_create(
			englishuuid, --IN create_entitydescriptionownerentityuuid uuid,
			testentitytemplateuuid, --	IN create_entitytemplateentityuuid uuid,
			testentityfielduuid, --	IN create_entityfieldentityuuid uuid,
			'Test Description '||clock_timestamp()::text, --	IN create_entitydescriptionname text,
			null, --	IN create_entitydescriptionsoplink text,
			null, --	IN create_entitydescriptionfile text,
			null, --	IN create_entitydescriptionicon text,
			null, --	IN create_entitydescriptionmimetypeuuid uuid,
			null, --	IN create_languagetypeuuid uuid,
			null, --	IN create_entitydescriptiondeleted boolean,
			null, --	IN create_entitydescriptiondraft boolean,
			testentitydescriptionuuid, -- OUT create_entitydescriptionentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();
		
		-- update the test score for pass and fail		
		if 	testentitydescriptionuuid notNull 
			then create_failedtext = create_failedtext||'Create entity description bad owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create entity description bad owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- no field or template then error 
		call entity.crud_entitydescription_create(
			testsub4customerentityuuid, --IN create_entitydescriptionownerentityuuid uuid,
			null, --	IN create_entitytemplateentityuuid uuid,
			null, --	IN create_entityfieldentityuuid uuid,
			'Test Description '||clock_timestamp()::text, --	IN create_entitydescriptionname text,
			null, --	IN create_entitydescriptionsoplink text,
			null, --	IN create_entitydescriptionfile text,
			null, --	IN create_entitydescriptionicon text,
			null, --	IN create_entitydescriptionmimetypeuuid uuid,
			null, --	IN create_languagetypeuuid uuid,
			null, --	IN create_entitydescriptiondeleted boolean,
			null, --	IN create_entitydescriptiondraft boolean,
			testentitydescriptionuuid, -- OUT create_entitydescriptionentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		if 	testentitydescriptionuuid notNull 
			then create_failedtext = create_failedtext||'Create entity description no field or template - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create entity description no field or template - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- no descriptionname, soplink, file, or icon the error

		call entity.crud_entitydescription_create(
			testsub4customerentityuuid, --IN create_entitydescriptionownerentityuuid uuid,
			testentitytemplateuuid, --	IN create_entitytemplateentityuuid uuid,
			testentityfielduuid, --	IN create_entityfieldentityuuid uuid,
			null, --	IN create_entitydescriptionname text,
			null, --	IN create_entitydescriptionsoplink text,
			null, --	IN create_entitydescriptionfile text,
			null, --	IN create_entitydescriptionicon text,
			null, --	IN create_entitydescriptionmimetypeuuid uuid,
			null, --	IN create_languagetypeuuid uuid,
			null, --	IN create_entitydescriptiondeleted boolean,
			null, --	IN create_entitydescriptiondraft boolean,
			testentitydescriptionuuid, -- OUT create_entitydescriptionentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		if 	testentitydescriptionuuid notNull 
			then create_failedtext = create_failedtext||'Create entity description no descriptionname, soplink, file, or icon - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create entity description no descriptionname, soplink, file, or icon - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- add description to template

		call entity.crud_entitydescription_create(
			testsub4customerentityuuid, --IN create_entitydescriptionownerentityuuid uuid,
			testentitytemplateuuid, --	IN create_entitytemplateentityuuid uuid,
			null, --	IN create_entityfieldentityuuid uuid,
			'Test Description '||clock_timestamp()::text, --	IN create_entitydescriptionname text,
			null, --	IN create_entitydescriptionsoplink text,
			null, --	IN create_entitydescriptionfile text,
			null, --	IN create_entitydescriptionicon text,
			null, --	IN create_entitydescriptionmimetypeuuid uuid,
			null, --	IN create_languagetypeuuid uuid,
			null, --	IN create_entitydescriptiondeleted boolean,
			null, --	IN create_entitydescriptiondraft boolean,
			testentitydescriptionuuid, -- OUT create_entitydescriptionentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		if 	testentitydescriptionuuid isNull 
			then create_failedtext = create_failedtext||'Create entity description to template - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create entity description to template - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

		testentitydescriptionuuid = null;

	-- add description to field 
		call entity.crud_entitydescription_create(
			testsub4customerentityuuid, --IN create_entitydescriptionownerentityuuid uuid,
			null, --	IN create_entitytemplateentityuuid uuid,
			testentityfielduuid, --	IN create_entityfieldentityuuid uuid,
			'Test Description '||clock_timestamp()::text, --	IN create_entitydescriptionname text,
			null, --	IN create_entitydescriptionsoplink text,
			null, --	IN create_entitydescriptionfile text,
			null, --	IN create_entitydescriptionicon text,
			null, --	IN create_entitydescriptionmimetypeuuid uuid,
			null, --	IN create_languagetypeuuid uuid,
			null, --	IN create_entitydescriptiondeleted boolean,
			null, --	IN create_entitydescriptiondraft boolean,
			testentitydescriptionuuid, -- OUT create_entitydescriptionentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		if 	testentitydescriptionuuid isNull 
			then create_failedtext = create_failedtext||'Create entity description to field - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create entity description to field - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- Entity Description delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid);
		
		if 	testentitydescriptionuuid notNull 
			then 
				call entity.crud_entitydescription_delete(
					null, -- IN create_entitydescriptionownerentityuuid uuid,
					testentitydescriptionuuid, -- IN create_entitydescriptionentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Description Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Description Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no Customer Tag entity isNull
		testcount = (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid);
		
		if 	testentitydescriptionuuid notNull 
			then 
				call entity.crud_entitydescription_delete(
					testsub4customerentityuuid, -- IN create_entitydescriptionownerentityuuid uuid,
					null, -- IN create_entitydescriptionentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Description Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Description Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Entity Description combo do not exist
		testcount = (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid);
		
		if 	testentitydescriptionuuid notNull 
			then 
				call entity.crud_entitydescription_delete(
					tendreluuid, -- IN create_entitydescriptionownerentityuuid uuid,
					testentitydescriptionuuid, -- IN create_entitydescriptionentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid)  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Description Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Description Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Entity Description combo 
		testcount = (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid);
						
		if 	testentitydescriptionuuid notNull 
			then 
				call entity.crud_entitydescription_delete(
					testsub4customerentityuuid, -- IN create_entitydescriptionownerentityuuid uuid,
					testentitydescriptionuuid, -- IN create_entitydescriptionentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entitydescription 
					where entitydescriptiondeleted = true
						and entitydescriptionuuid = testentitydescriptionuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Description Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Description Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the Entity Description
		update entity.entitydescription
		set entitydescriptiondeleted  = false
		where entitydescriptionuuid = testentitydescriptionuuid;	

------------------
-- entity instance
------------------

	-- no entityinstanceownerentityuuid

		call entity.crud_entityinstance_create(
			null, -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			null, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create instance no owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance no owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- error - invalid entityinstanceownerentityuuid not a customer
		call entity.crud_entityinstance_create(	
			englishuuid, -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			null, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create instance bad owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance bad owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;		

	-- error - valid entityinstanceownerentityuuid no instance name or empty string
		call entity.crud_entityinstance_create(	
			testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'', -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create instance  no instance name or empty string - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  no instance name or empty string - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;			

	-- error - valid entityinstanceownerentityuuid valid instance name no templateuuid no template name

		call entity.crud_entityinstance_create(	
			testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||clock_timestamp()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create instance  no templateuuid no template name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  no templateuuid no template name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- template/owner mismatch
		
		call entity.crud_entityinstance_create(	
			tendreluuid, -- IN create_entityinstanceownerentityuuid uuid,
			testentitytemplateuuid, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||clock_timestamp()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create instance template/owner mismatch name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  template/owner mismatch name - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- Template Lazy Init

		call entity.crud_entityinstance_create(	
			testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
			null, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			'newtemplate'||clock_timestamp()::text, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||clock_timestamp()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create instance Template Lazy Init - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  Template Lazy Init - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- known tempalte with a custag

		call entity.crud_entityinstance_create(	
			testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
			testentitytemplateuuid, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			'c2d5ecdd-a657-4448-aef2-54467045134a', -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||clock_timestamp()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create instance known tempalte with a custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  known tempalte with a custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;		

-- known tempalte with invalid custag
		call entity.crud_entityinstance_create(	
			testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
			testentitytemplateuuid, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			englishuuid, -- IN create_entityinstancetaguuid uuid,
			null, -- IN create_entityinstancetag text,
			'instance'||clock_timestamp()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create instance known tempalte with invalid custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  known tempalte with invalid custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

-- known tempalte lazy init custag
		call entity.crud_entityinstance_create(	
			testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
			testentitytemplateuuid, -- IN create_entityinstanceentitytemplateentityuuid uuid,	
			null, -- IN create_entityinstanceentitytemplateentityname text,	
			null, -- IN create_entityinstanceparententityuuid uuid,    
			null, -- IN create_entityinstanceecornerstoneentityuuid uuid,  
			null, -- IN create_entityinstancecornerstoneorder integer,
			null, -- IN create_entityinstancetaguuid uuid,
			'newtag'||clock_timestamp()::text, -- IN create_entityinstancetag text,
			'instance'||clock_timestamp()::text, -- IN create_entityinstancename text,
			null, -- IN create_entityinstancescanid text,
			null, -- IN create_entityinstancetypeuuid uuid,
			null, -- IN create_entityinstanceexternalid text,
			null, -- IN create_entityinstanceexternalsystemuuid uuid,
			null, -- IN create_entityinstancedeleted boolean,
			null, -- IN create_entityinstancedraft boolean,
			testentityinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create instance known tempalte lazy init custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create instance  known tempalte lazy init custag - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- Entity Description delete tests
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid);
		
		if 	testentityinstanceuuid notNull 
			then 
				call entity.crud_entityinstance_delete(
					null, -- IN create_entityinstanceownerentityuuid uuid,
					testentityinstanceuuid, -- IN create_entityinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity instance Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity instance Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no intnace isNull
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid);
		
		if 	testentityinstanceuuid notNull 
			then 
				call entity.crud_entityinstance_delete(
					testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
					null, -- IN create_entityinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity instance Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity instance Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Entity instance combo do not exist
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid);
		
		if 	testentityinstanceuuid notNull 
			then 
				call entity.crud_entityinstance_delete(
					tendreluuid, -- IN create_entityinstanceownerentityuuid uuid,
					testentityinstanceuuid, -- IN create_entityinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid)  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity instance Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity instance Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Entity instance combo 
		testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid);
						
		if 	testentityinstanceuuid notNull 
			then 
				call entity.crud_entityinstance_delete(
					testsub4customerentityuuid, -- IN create_entityinstanceownerentityuuid uuid,
					testentityinstanceuuid, -- IN create_entityinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityinstance 
					where entityinstancedeleted = true
						and entityinstanceuuid = testentityinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity instance Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity instance Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the Entity instance
		update entity.entityinstance
		set entityinstancedeleted  = false
		where entityinstanceuuid = testentityinstanceuuid;	

------------------
-- entity field instance
------------------

	-- error if owner isNull or entityinstanceentityuuid isNull or fieldentityuuid isNull
		call entity.crud_entityfieldinstance_create(
			null,-- IN create_entityfieldinstanceownerentityuuid uuid,
			null,-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
			null,-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
			'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
			null,-- IN create_entityfieldinstanceentityfieldname text,
			null,-- IN create_entityfieldformatentityuuid uuid,
			null,-- IN create_entityfieldformatentityname text,
			null,-- IN create_entityfieldwidgetentityuuid uuid,
			null,-- IN create_entityfieldwidgetentityname text,
			null,-- IN create_entityfieldinstanceexternalid text,
			null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
			null,-- IN create_entityfieldinstancedeleted boolean,
			null,-- IN create_entityfieldinstancedraft boolean,
			testentityfieldinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfieldinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create field instance no owner or entityinstanceentityuuid or fieldentityuuid - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create field instance no owner or entityinstanceentityuuid or fieldentityuuid  - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	--  invalid customer
		call entity.crud_entityfieldinstance_create(
			englishuuid,-- IN create_entityfieldinstanceownerentityuuid uuid,
			testentityinstanceuuid,-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
			testentityfielduuid,-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
			'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
			null,-- IN create_entityfieldinstanceentityfieldname text,
			null,-- IN create_entityfieldformatentityuuid uuid,
			null,-- IN create_entityfieldformatentityname text,
			null,-- IN create_entityfieldwidgetentityuuid uuid,
			null,-- IN create_entityfieldwidgetentityname text,
			null,-- IN create_entityfieldinstanceexternalid text,
			null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
			null,-- IN create_entityfieldinstancedeleted boolean,
			null,-- IN create_entityfieldinstancedraft boolean,
			testentityfieldinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfieldinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create field instance invalid customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create field instance invalid customer  - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- invalid owner instance combo
		call entity.crud_entityfieldinstance_create(
			tendreluuid,-- IN create_entityfieldinstanceownerentityuuid uuid,
			testentityinstanceuuid,-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
			testentityfielduuid,-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
			'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
			null,-- IN create_entityfieldinstanceentityfieldname text,
			null,-- IN create_entityfieldformatentityuuid uuid,
			null,-- IN create_entityfieldformatentityname text,
			null,-- IN create_entityfieldwidgetentityuuid uuid,
			null,-- IN create_entityfieldwidgetentityname text,
			null,-- IN create_entityfieldinstanceexternalid text,
			null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
			null,-- IN create_entityfieldinstancedeleted boolean,
			null,-- IN create_entityfieldinstancedraft boolean,
			testentityfieldinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfieldinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create field instance invalid owner instance combo - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create field instance invalid owner instance combo  - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- valid field instance
		call entity.crud_entityfieldinstance_create(
			testsub4customerentityuuid,-- IN create_entityfieldinstanceownerentityuuid uuid,
			testentityinstanceuuid,-- IN create_entityfieldinstanceentityinstanceentityuuid uuid,
			testentityfielduuid,-- IN create_entityfieldinstanceentityfieldentityuuid uuid,
			'test value'||now()::text,-- IN create_entityfieldinstancevalue text,
			null,-- IN create_entityfieldinstanceentityfieldname text,
			null,-- IN create_entityfieldformatentityuuid uuid,
			null,-- IN create_entityfieldformatentityname text,
			null,-- IN create_entityfieldwidgetentityuuid uuid,
			null,-- IN create_entityfieldwidgetentityname text,
			null,-- IN create_entityfieldinstanceexternalid text,
			null,-- IN create_entityfieldinstanceexternalsystemuuid uuid,
			null,-- IN create_entityfieldinstancedeleted boolean,
			null,-- IN create_entityfieldinstancedraft boolean,
			testentityfieldinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			null, -- IN create_languagetypeuuid
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfieldinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create field instance - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create field instance - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- delete scripts 
	
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid);
		
		if 	testentityfieldinstanceuuid notNull 
			then 
		call entity.crud_entityfieldinstance_delete(
			null, -- IN create_entityfieldinstanceownerentityuuid uuid,
			testentityfieldinstanceuuid, -- IN create_entityfieldinstanceentityuuid uuid,	
			create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field instance Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field instance Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no intnace isNull
		testcount = (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid);
		
		if 	testentityfieldinstanceuuid notNull 
			then 
				call entity.crud_entityfieldinstance_delete(
					testsub4customerentityuuid, -- IN create_entityfieldinstanceownerentityuuid uuid,
					null, -- IN create_entityfieldinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field instance Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field instance Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Entity instance combo do not exist
		testcount = (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid);
		
		if 	testentityfieldinstanceuuid notNull 
			then 
				call entity.crud_entityfieldinstance_delete(
					tendreluuid, -- IN create_entityfieldinstanceownerentityuuid uuid,
					testentityfieldinstanceuuid, -- IN create_entityfieldinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid)  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field instance Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field instance Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Entity instance combo 
		testcount = (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid);
						
		if 	testentityfieldinstanceuuid notNull 
			then 
				call entity.crud_entityfieldinstance_delete(
					testsub4customerentityuuid, -- IN create_entityfieldinstanceownerentityuuid uuid,
					testentityfieldinstanceuuid, -- IN create_entityfieldinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityfieldinstance 
					where entityfieldinstancedeleted = true
						and entityfieldinstanceuuid = testentityfieldinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity Field instance Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity Field instance Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the Field Entity instance
		update entity.entityfieldinstance
		set entityfieldinstancedeleted  = false
		where entityfieldinstanceuuid = testentityfieldinstanceuuid;	

-----------------------
-- entity file instance
-----------------------

	-- bogus owner isNull

		call entity.crud_entityfileinstance_create(
			englishuuid, -- IN create_entityfileinstanceownerentityuuid uuid,
			testentityinstanceuuid, -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			testentityfieldinstanceuuid, -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			testentityfileinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfileinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create file instance bad owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create file instance bad owner  - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- no instance or  field instance then error 
		call entity.crud_entityfileinstance_create(
			testsub4customerentityuuid, -- IN create_entityfileinstanceownerentityuuid uuid,
			null, -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			null, -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			testentityfileinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfileinstanceuuid notNull 
			then create_failedtext = create_failedtext||'Create file instance no instance or  field instance - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create file instance no instance or  field instance  - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- add File to instance
		call entity.crud_entityfileinstance_create(
			testsub4customerentityuuid, -- IN create_entityfileinstanceownerentityuuid uuid,
			testentityinstanceuuid, -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			null, -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			testentityfileinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfileinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create file instance to instance - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create file instance to instance - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- add File to field instance
		call entity.crud_entityfileinstance_create(
			testsub4customerentityuuid, -- IN create_entityfileinstanceownerentityuuid uuid,
			testentityinstanceuuid, -- IN create_entityfileinstanceentityentityinstanceentityuuid uuid,
			testentityfieldinstanceuuid, -- IN create_entityfileinstanceentityfieldinstanceentityuuid uuid,
			'storagelocation '||now()::text, -- IN create_entityfileinstancestoragelocation text,
			'c262c14c-7f33-4a51-b11a-b65892b59d0e', -- IN create_entityfileinstancemimetypeuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null, -- IN create_entityfileinstancedeleted boolean,
			null, -- IN create_entityfileinstancedraft boolean,
			testentityfileinstanceuuid, -- OUT create_entityinstanceentityuuid uuid,
			create_modifiedby );
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail		
		if 	testentityfileinstanceuuid isNull 
			then create_failedtext = create_failedtext||'Create file instance to field instance - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Create file instance to field instance - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;

	-- delete scripts 
	
	-- no owner isNull    
		testcount = (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid);
		
		if 	testentityfileinstanceuuid notNull 
			then 
		call entity.crud_entityfileinstance_delete(
			null, -- IN create_entityfileinstanceownerentityuuid uuid,
			testentityfileinstanceuuid, -- IN create_entityfileinstanceentityuuid uuid,	
			create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity file instance Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity file instance Delete No Owner - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- no intnace isNull
		testcount = (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid);
		
		if 	testentityfileinstanceuuid notNull 
			then 
				call entity.crud_entityfileinstance_delete(
					testsub4customerentityuuid, -- IN create_entityfileinstanceownerentityuuid uuid,
					null, -- IN create_entityfileinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity file instance Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity file instance Delete No Customer - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- owner and Entity instance combo do not exist
		testcount = (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid);
		
		if 	testentityfileinstanceuuid notNull 
			then 
				call entity.crud_entityfileinstance_delete(
					tendreluuid, -- IN create_entityfileinstanceownerentityuuid uuid,
					testentityfileinstanceuuid, -- IN create_entityfileinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount <> (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid)  and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity file instance Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity file instance Delete owner and customer combo do not exist - Fail logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

		-- valid owner and Entity instance combo 
		testcount = (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid);
						
		if 	testentityfileinstanceuuid notNull 
			then 
				call entity.crud_entityfileinstance_delete(
					testsub4customerentityuuid, -- IN create_entityfileinstanceownerentityuuid uuid,
					testentityfileinstanceuuid, -- IN create_entityfileinstanceentityuuid uuid,	
					create_modifiedby);
		end if;
		fact_end = 	clock_timestamp();

		-- update the test score for pass and fail	
		if 	testcount = (select count(*) 
					from entity.entityfileinstance 
					where entityfileinstancedeleted = true
						and entityfileinstanceuuid = testentityfileinstanceuuid) and testsub4customerentityuuid notNull 
			then create_failedtext = create_failedtext||'Entity file instance Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_failedtest = true;
					create_failedtestcount = create_failedtestcount + 1;
			else create_passedtext = create_passedtext||'Entity file instance Delete valid owner and customer combo - Pass logic Time: '||(clock_timestamp()-fact_end)::text||E'\n';
					create_successtestcount = create_successtestcount + 1;
		end if;	

	-- reset the file Entity instance
		update entity.entityfileinstance
		set entityfileinstancedeleted  = false
		where entityfileinstanceuuid = testentityfileinstanceuuid;	

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.test_entity_create(boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.test_entity_create(boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.test_entity_create(boolean,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.test_entity_create(boolean,bigint) TO graphql;


-- Type: FUNCTION ; Name: entity.func_test_import(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_import(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
call entity.import_entity('all time');

select * from entity.func_test_import(
	0::bigint, 
	0::bigint, 
	false, 
	'', 
	''
	)
*/

 -- Start the timer on this function
	temptext = '';

fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n\n';
test_failedtext = test_failedtext||E'\n\n';
test_passedtext = test_passedtext||E'testing import success\n-------\n'||E'  all customers imported\n  -------\n';
test_failedtext = test_failedtext||E'testing import success\n-------\n'||E'  all customers imported\n  -------\n';

if (select count(*) from customer tcust
		left join (select * from entity.crud_customer_read_full(null,null, null, true,null,null, null, null)) ecust
			on tcust.customerid = ecust.customerid 
		where ecust.customerid isnull) < 1
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from customer tcust left join (select * from entity.crud_customer_read_full(null,null, null, true, null,null, null,null)) ecust on tcust.customerid = ecust.customerid where ecust.customerid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from customer tcust left join (select * from entity.crud_customer_read_full(null,null, null, true,null,null, null, null)) ecust on tcust.customerid = ecust.customerid where ecust.customerid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- locations imported
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  all locations imported\n  -------\n';
test_failedtext = test_failedtext||E'  all locations imported\n  -------\n';

if (select count(*)  
		from location tloc
			left join (select * from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) eloc
						on tloc.locationid = eloc.locationid 
		where eloc.locationid isnull) = 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from location tloc left join (select * from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.locationid = eloc.locationid where eloc.locationid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from location tloc left join (select * from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.locationid = eloc.locationid where eloc.locationid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text; 
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- systag imported
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  all systag imported\n  -------\n';
test_failedtext = test_failedtext||E'  all systag imported\n  -------\n';

if (select count(*)  
		from systag tloc
			left join (select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) eloc
						on tloc.systagid = eloc.systagid 
		where eloc.systagid isnull) = 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from systag tloc left join (select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.systagid = eloc.systagid where eloc.systagid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from systag tloc left join (select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.systagid = eloc.systagid where eloc.systagid isnull ) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- custag imported
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  all custag imported\n  -------\n';
test_failedtext = test_failedtext||E'  all custag imported\n  -------\n';

if (select count(*)  
		from custag tloc
			left join (select * from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) eloc
						on tloc.custagid = eloc.custagid 
		where eloc.custagid isnull) = 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from custag tloc left join (select * from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.custagid = eloc.custagid where eloc.custagid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from custag tloc left join (select * from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.custagid = eloc.custagid where eloc.custagid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- enttag imported from location
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  all enttags imported from location\n  -------\n';
test_failedtext = test_failedtext||E'  all enttags imported from location\n  -------\n';

if (select count(*)  
	from location tloc
		join (select * from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) eloc
			on tloc.locationid = eloc.locationid 
		left join (select * from entity.crud_entitytag_read_full(null, null,null,null, null, true,  true,true,true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) tag
			on tag.entitytagentityinstanceentityuuid = eloc.locationentityuuid
	where tag.entitytaguuid isnull) = 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from location tloc join (select * from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.locationid = eloc.locationid left join (select * from entity.crud_entitytag_read_full(null, null,null,null, null, true, true,true,true, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) tag on tag.entitytagentityinstanceentityuuid = eloc.locationentityuuid where tag.entitytaguuid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from location tloc join (select * from entity.crud_location_read_full(null, null,null,null, null, true, null, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) eloc on tloc.locationid = eloc.locationid left join (select * from entity.crud_entitytag_read_full(null, null,null,null, null, true,true,true,true, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) tag on tag.entitytagentityinstanceentityuuid = eloc.locationentityuuid where tag.entitytaguuid isnull) = 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- duplicates imported
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  duplicates imported\n  -------\n';
test_failedtext = test_failedtext||E'  duplicates imported\n  -------\n';

if (select count(*) 
	from entity.entityinstance
	group by entityinstanceoriginalid,entityinstancetype
	having count(*) > 1) isNull
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.entityinstance group by entityinstanceoriginalid,entityinstancetype having count(*) > 1) eloc on tloc.custagid = eloc.custagid where eloc.custagid isnull) isNull  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.entityinstance group by entityinstanceoriginalid,entityinstancetype having count(*) > 1) eloc on tloc.custagid = eloc.custagid where eloc.custagid isnull) isNull  Time: '||(clock_timestamp()-fact_end)::text;  
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_import(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_import(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_import(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;

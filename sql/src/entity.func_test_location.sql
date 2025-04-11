
-- Type: FUNCTION ; Name: entity.func_test_location(bigint,bigint,boolean,text,text); Owner: bombadil

CREATE OR REPLACE FUNCTION entity.func_test_location(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_location(
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

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'testing location\n-------\n'||E'  testing all customers all locations all tags\n  -------\n';
test_failedtext = test_failedtext||E'testing location\n-------\n'||E'  testing all customers all locations all tags\n  -------\n';
if (select count(*) from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customer all locations all tags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer all locations all tags\n  -------\n';
if (select count(*) from entity.crud_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_location_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customer all locations specific tags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer all locations specific tags\n  -------\n';
if (select count(*) from entity.crud_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,true,'1aefd363-45aa-4986-80e9-e8e212059a85',null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,''1aefd363-45aa-4986-80e9-e8e212059a85'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,''1aefd363-45aa-4986-80e9-e8e212059a85'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_location_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,true,'1aefd363-45aa-4986-80e9-e8e212059a85',null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,''1aefd363-45aa-4986-80e9-e8e212059a85'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,true,null,null,null,''1aefd363-45aa-4986-80e9-e8e212059a85'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific parent\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific parent\n  -------\n';
if (select count(*) from entity.crud_location_read_min('92eba0ba-b271-40d0-8d64-6de19b3df6f7',null,'36a3c4ef-07ce-4295-9132-8c323099dcc4',null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_min(''92eba0ba-b271-40d0-8d64-6de19b3df6f7'',null,''36a3c4ef-07ce-4295-9132-8c323099dcc4'',null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_min(''92eba0ba-b271-40d0-8d64-6de19b3df6f7'',null,''36a3c4ef-07ce-4295-9132-8c323099dcc4'',null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_location_read_full('92eba0ba-b271-40d0-8d64-6de19b3df6f7',null,'36a3c4ef-07ce-4295-9132-8c323099dcc4',null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_full(''92eba0ba-b271-40d0-8d64-6de19b3df6f7'',null,''36a3c4ef-07ce-4295-9132-8c323099dcc4'',null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_full(''92eba0ba-b271-40d0-8d64-6de19b3df6f7'',null,''36a3c4ef-07ce-4295-9132-8c323099dcc4'',null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''. 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific cornerstone\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific cornerstone\n  -------\n';
if (select count(*) from entity.crud_location_read_min('58f4032b-d614-4f7d-97e7-e20240205229',null,null,'dceec0cf-f626-4775-807a-3bacc70de8eb',false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_min(''58f4032b-d614-4f7d-97e7-e20240205229'',null,null,''dceec0cf-f626-4775-807a-3bacc70de8eb'',false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_min(''58f4032b-d614-4f7d-97e7-e20240205229'',null,null,''dceec0cf-f626-4775-807a-3bacc70de8eb'',false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_location_read_full('58f4032b-d614-4f7d-97e7-e20240205229',null,null,'dceec0cf-f626-4775-807a-3bacc70de8eb',false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_full(''58f4032b-d614-4f7d-97e7-e20240205229'',null,null,''dceec0cf-f626-4775-807a-3bacc70de8eb'',false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_full(''58f4032b-d614-4f7d-97e7-e20240205229'',null,null,''dceec0cf-f626-4775-807a-3bacc70de8eb'',false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific locations specific tags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific locations specific tags\n  -------\n';
if (select count(*) from entity.crud_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','af4dc39d-7d4a-46a4-9ad0-980c23bff933',null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',null,null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',null,null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_location_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','af4dc39d-7d4a-46a4-9ad0-980c23bff933',null,null,false,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',null,null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',null,null,false,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_location(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_location(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_location(bigint,bigint,boolean,text,text) TO bombadil WITH GRANT OPTION;

BEGIN;

/*
DROP FUNCTION entity.func_test_custag(bigint,bigint,boolean,text,text);
*/


-- Type: FUNCTION ; Name: entity.func_test_custag(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_custag(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_custag(
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
test_passedtext = test_passedtext||E'testing custags\n-------\n'||E'  testing all customers all custags\n  -------\n';
test_failedtext = test_failedtext||E'testing custags\n-------\n'||E'  testing all customers all custags\n  -------\n';
if (select count(*) from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;

fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;

fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customers all custags \n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customers all custags \n  -------\n';
if (select count(*) from entity.crud_custag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customers all custags \n  -------\n';
test_failedtext = test_failedtext||E'  testing all custags for a parent \n  -------\n';
if (select count(*) from entity.crud_custag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing fail scenario for parent \n  -------\n';
test_failedtext = test_failedtext||E'  testing fail scenario for parent \n  -------\n';
if (select count(*) from entity.crud_custag_read_min(null,null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then test_passedtext = test_passedtext||E'     Pass:  select count(*) from entity.crud_custag_read_min(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_min(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_custag_read_full(null,null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_full(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_full(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific custags \n  -------\n';
test_failedtext = test_failedtext||E'  testing specific custags \n  -------\n';

if (select count(*) from entity.crud_custag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing fail for custags \n  -------\n';
test_failedtext = test_failedtext||E'  testing fail for custags \n  -------\n';
if (select count(*) from entity.crud_custag_read_min(null, null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_min(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_min(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_custag_read_full(null, null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_custag_read_full(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_custag_read_full(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_custag(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_custag(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_custag(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_custag(bigint,bigint,boolean,text,text) TO graphql;

END;

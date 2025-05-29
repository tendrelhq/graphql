BEGIN;

/*
DROP FUNCTION entity.func_test_systag(bigint,bigint,boolean,text,text);
*/


-- Type: FUNCTION ; Name: entity.func_test_systag(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_systag(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_systag(
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
test_passedtext = test_passedtext||E'testing systags\n-------\n'||E'  testing all customers all systags\n  -------\n';
test_failedtext = test_failedtext||E'testing systags\n-------\n'||E'  testing all customers all systags\n  -------\n';
if (select count(*) from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'  testing specific customer all systags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer all systags\n  -------\n';
if (select count(*) from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'  testing all systags for a parent\n  -------\n';
test_failedtext = test_failedtext||E'  testing all systags for a parent\n  -------\n';
if (select count(*) from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'  testing systag fail scenario for parent\n  -------\n';
test_failedtext = test_failedtext||E'  testing systag fail scenario for parent\n  -------\n';
if (select count(*) from entity.crud_systag_read_min(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_min(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_min(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_systag_read_full(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_full(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_full(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'  testing specific systags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific systags\n  -------\n';
if (select count(*) from entity.crud_systag_read_min(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_min(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''=1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_min(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''=1)  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_systag_read_full(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_systag_read_full(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'' = 1)  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_systag_read_full(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'' = 1)  Time: '|| (clock_timestamp()-fact_end)::text;
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


REVOKE ALL ON FUNCTION entity.func_test_systag(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_systag(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_systag(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_systag(bigint,bigint,boolean,text,text) TO graphql;

END;


-- Type: FUNCTION ; Name: entity.func_test_template(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_template(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	fact_start timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_template(
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
test_passedtext = test_passedtext||E'testing entity templates\n-------\n'||E'  testing all customers all templates\n  -------\n';
test_failedtext = test_failedtext||E'testing entity templates\n-------\n'||E'  testing all customers all templates\n  -------\n';

if (select count(*) from entity.crud_entitytemplate_read_min(null, null, null,null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_min(null, null, null,null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_min(null, null, null,null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_read_full(null, null, null,null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_full(null, null, null,null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_full(null, null, null,null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customer all templates\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer all templates\n  -------\n';
if (select count(*) from entity.crud_entitytemplate_read_min(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_read_full(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null, null, null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customer specific entity template\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer specific entity template\n  -------\n';
if (select count(*) from entity.crud_entitytemplate_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null,null, null,null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null,null, null,null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null,null, null,null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null,null, null,null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null,null, null,null)= 1  Time:'|| (clock_timestamp()-fact_end)::text;
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null,null, null,null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  negative test - empty or wrong cutomer returns no templates\n  -------\n';
test_failedtext = test_failedtext||E'  negative test - empty or wrong cutomer returns no templates\n  -------\n';
if (select count(*) from entity.crud_entitytemplate_read_min(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',	null,null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_min(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',	null,null, null,null)= 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_min(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',	null)= 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_read_full(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',	null,null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_read_full(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null,null, null,null)= 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_read_full(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null,null, null,null)= 0  Time: '|| (clock_timestamp()-fact_end)::text;
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


REVOKE ALL ON FUNCTION entity.func_test_template(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_template(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_template(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_template(bigint,bigint,boolean,text,text) TO graphql;

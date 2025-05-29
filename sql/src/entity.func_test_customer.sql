BEGIN;

/*
DROP FUNCTION entity.func_test_customer(bigint,bigint,boolean,text,text);
*/


-- Type: FUNCTION ; Name: entity.func_test_customer(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_customer(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_customer(
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
test_passedtext = test_passedtext||E'testing customer\n-------\n'||E'  testing specific customer\n  -------\n';
test_failedtext = test_failedtext||E'testing customer\n-------\n'||E'  testing specific customer\n  -------\n';

if (select count(*) from entity.crud_customer_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,false, null, null, null, null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,false,null, null, null,  null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,false, null, null, null, null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_customer_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, false, null, null, null, null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,false,null, null, null,  null)=1  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,false, null, null, null, null)=1  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing all customers\n  -------\n';
test_failedtext = test_failedtext||E'  testing all customers\n  -------\n';
if (select count(*) from entity.crud_customer_read_min(null,null,null,true, null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_min(null,null,null,true,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_min(null,null,null,true, null, null, null, null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_customer_read_full(null,null, null, true,null, null, null,  null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_full(null,null, null, true,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_full(null,null, null, true,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing all customers with some in japanese\n  -------\n';
test_failedtext = test_failedtext||E'  testing all customers with some in japanese\n  -------\n';
if (select count(*) from entity.crud_customer_read_full(null,null, null, true,null, null, null,  '190d8c53-b076-460d-8c10-8ca35396429a')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_full(null,null, null, true,null, null, null,  ''190d8c53-b076-460d-8c10-8ca35396429a'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_full(null,null, null, true,null, null, null,  ''190d8c53-b076-460d-8c10-8ca35396429a'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing children of a parent customer\n  -------\n';
test_failedtext = test_failedtext||E'  testing children of a parent customer\n  -------\n';
if (select count(*) from entity.crud_customer_read_min(null,null,'f90d618d-5de7-4126-8c65-0afb700c6c61',false,null, null, null,  null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_min(null,null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_min(null,null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_customer_read_full(null,null,'f90d618d-5de7-4126-8c65-0afb700c6c61',false,null, null, null,  null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_full(null,null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_full(null,null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',false, null, null, null, null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing children of an authority customer\n  -------\n';
test_failedtext = test_failedtext||E'  testing children of an authority customer\n  -------\n';
if (select count(*) from entity.crud_customer_read_min(null,'f90d618d-5de7-4126-8c65-0afb700c6c61',null,false, null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_min(null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_min(null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_customer_read_full(null,'f90d618d-5de7-4126-8c65-0afb700c6c61',null,false,null, null, null,  null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_customer_read_full(null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_customer_read_full(null,''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,false,null, null, null,  null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp(); 

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_customer(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_customer(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_customer(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_customer(bigint,bigint,boolean,text,text) TO graphql;

END;

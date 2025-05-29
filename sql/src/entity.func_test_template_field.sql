BEGIN;

/*
DROP FUNCTION entity.func_test_template_field(bigint,bigint,boolean,text,text);
*/


-- Type: FUNCTION ; Name: entity.func_test_template_field(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_template_field(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_template_field(
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
test_passedtext = test_passedtext||E'testing entity fields\n-------\n'||E'  testing all customers all template all fields\n  -------\n';
test_failedtext = test_failedtext||E'testing entity fields\n-------\n'||E'  testing all customers all template all fields\n  -------\n';

if (select count(*) from entity.crud_entityfield_read_min(null, null, null,null, null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_min(null, null, null,null, null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*)from entity.crud_entityfield_read_min(null, null, null,null, null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_full(null, null, null,null, null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_full(null, null, null,null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*)from entity.crud_entityfield_read_full(null, null, null,null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_field_read_full(null, null, null,null, null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_field_read_full(null, null, null,null, null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*)from entity.crud_entitytemplate_field_read_full(null, null, null,null, null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customer all systags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer all systags\n  -------\n';
if (select count(*) from entity.crud_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null, null, null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null, null, null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null, null, null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null, null, null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null,null, null, null, null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customers specific template all fields\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customers specific template all fields\n  -------\n';
if (select count(*) from entity.crud_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)> 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customers specific template specific fields\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customers specific template specific fields\n  -------\n';
if (select count(*) from entity.crud_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 1  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 1  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 1  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 1  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 1  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  negative tests - empty or wrong cutomer returns nothing\n  -------\n';
test_failedtext = test_failedtext||E'  negative tests - empty or wrong cutomer returns nothing\n  -------\n';
if (select count(*) from entity.crud_entityfield_read_min(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_min(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_min(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_min(null,null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_min(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_min(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_full(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityfield_read_full(null,null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityfield_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityfield_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_field_read_full(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null, null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_field_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_field_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null, null, null,null)= 0  Time:'|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entitytemplate_field_read_full(null,null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)) = 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytemplate_field_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytemplate_field_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null, null, null,null)= 0  Time: '|| (clock_timestamp()-fact_end)::text;
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


REVOKE ALL ON FUNCTION entity.func_test_template_field(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_template_field(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_template_field(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_template_field(bigint,bigint,boolean,text,text) TO graphql;

END;

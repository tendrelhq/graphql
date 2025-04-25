
-- Type: FUNCTION ; Name: entity.func_test_instance(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_instance(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	fact_start timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_instance(
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
test_passedtext = test_passedtext||E'testing entity instances\n-------\n'||E'  testing all customers all entities all tags\n  -------\n';
test_failedtext = test_failedtext||E'testing entity instances\n-------\n'||E'  testing all customers all entities all tags\n  -------\n';

if (select count(*) from entity.crud_entityinstance_read_min(null,null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityinstance_read_min(null,null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityinstance_read_min(null,null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;

fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full(null,null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityinstance_read_full(null,null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time:'|| (clock_timestamp()-fact_end)::text;	
			test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityinstance_read_full(null,null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific customer all entities all tags
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific customer all entities all tags\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific customer all entities all tags\n  -------\n';
if (select count(*) from entity.crud_entityinstance_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityinstance_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityinstance_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entityinstance_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entityinstance_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific instance
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific instance\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific instance\n  -------\n';
if (select count(*) from entity.crud_entityinstance_read_min('d7995576-8354-4aea-b052-1ce61052bd2e','0ce5be8d-2bec-4219-be97-07dc154b2e3b','24855715-9228-4f41-bfe6-493f4c374a6e','2ab5461d-ad96-4560-a36d-d0fa53bce0f0','0b9f3142-e7ed-4f78-8504-ccd2eb505075','67af22cb-3183-4e6e-8542-7968f744965a',false,'f3fe9cae-c21e-4dba-9a10-008cfa6dca39',null, null,null, null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',''0ce5be8d-2bec-4219-be97-07dc154b2e3b'',''24855715-9228-4f41-bfe6-493f4c374a6e'',''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'',''0b9f3142-e7ed-4f78-8504-ccd2eb505075'',''67af22cb-3183-4e6e-8542-7968f744965a'',false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'',null, null,null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',''0ce5be8d-2bec-4219-be97-07dc154b2e3b'',''24855715-9228-4f41-bfe6-493f4c374a6e'',''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'',''0b9f3142-e7ed-4f78-8504-ccd2eb505075'',''67af22cb-3183-4e6e-8542-7968f744965a'',false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'',null, null,null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full('d7995576-8354-4aea-b052-1ce61052bd2e','0ce5be8d-2bec-4219-be97-07dc154b2e3b','24855715-9228-4f41-bfe6-493f4c374a6e','2ab5461d-ad96-4560-a36d-d0fa53bce0f0','0b9f3142-e7ed-4f78-8504-ccd2eb505075','67af22cb-3183-4e6e-8542-7968f744965a',false,'f3fe9cae-c21e-4dba-9a10-008cfa6dca39',null, null,null, null)) = 1
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',''0ce5be8d-2bec-4219-be97-07dc154b2e3b'',''24855715-9228-4f41-bfe6-493f4c374a6e'',''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'',''0b9f3142-e7ed-4f78-8504-ccd2eb505075'',''67af22cb-3183-4e6e-8542-7968f744965a'',false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'',null, null,null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',''0ce5be8d-2bec-4219-be97-07dc154b2e3b'',''24855715-9228-4f41-bfe6-493f4c374a6e'',''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'',''0b9f3142-e7ed-4f78-8504-ccd2eb505075'',''67af22cb-3183-4e6e-8542-7968f744965a'',false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'',null, null,null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific parent
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific parent\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific parent\n  -------\n';
if (select count(*) from entity.crud_entityinstance_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null, '24855715-9228-4f41-bfe6-493f4c374a6e',null,null,null,false,null,null,null,null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null, ''24855715-9228-4f41-bfe6-493f4c374a6e'',null,null,null,false,null,null,null,null,null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null, ''24855715-9228-4f41-bfe6-493f4c374a6e'',null,null,null,false,null,null,null,null,null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null, '24855715-9228-4f41-bfe6-493f4c374a6e',null,null,null,false,null,null,null,null,null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null, ''24855715-9228-4f41-bfe6-493f4c374a6e'',null,null,null,false,null,null,null,null,null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null, ''24855715-9228-4f41-bfe6-493f4c374a6e'',null,null,null,false,null,null,null,null,null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific cornerstone
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific cornerstone\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific cornerstone\n  -------\n';
if (select count(*) from entity.crud_entityinstance_read_min('d7995576-8354-4aea-b052-1ce61052bd2e', null, null, '2ab5461d-ad96-4560-a36d-d0fa53bce0f0', null, null, false, null, null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, ''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'', null, null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, ''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'', null, null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full('d7995576-8354-4aea-b052-1ce61052bd2e', null, null, '2ab5461d-ad96-4560-a36d-d0fa53bce0f0', null, null, false, null, null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, ''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'', null, null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, ''2ab5461d-ad96-4560-a36d-d0fa53bce0f0'', null, null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific template
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific template\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific template\n  -------\n';
if (select count(*) from entity.crud_entityinstance_read_min(	'd7995576-8354-4aea-b052-1ce61052bd2e', null, null, null, '0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null, null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_min(	''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_min(	''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full(	'd7995576-8354-4aea-b052-1ce61052bd2e', null, null, null, '0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null, null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_full(	''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_full(	''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null, null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific tag
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  testing specific tag\n  -------\n';
test_failedtext = test_failedtext||E'  testing specific tag\n  -------\n';
if (select count(*) from entity.crud_entityinstance_read_min('d7995576-8354-4aea-b052-1ce61052bd2e', null, null, null, null, null, false,'f3fe9cae-c21e-4dba-9a10-008cfa6dca39', null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, null, null, false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'', null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;	
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, null, null, false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'', null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
if (select count(*) from entity.crud_entityinstance_read_full('d7995576-8354-4aea-b052-1ce61052bd2e', null, null, null, null, null, false,'f3fe9cae-c21e-4dba-9a10-008cfa6dca39', null, null, null, null)) > 0
	Then test_passedtext = test_passedtext||'     Pass:  (select count(*) from entity.crud_entityinstance_read_full''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, null, null, false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'', null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  (select count(*) from entity.crud_entityinstance_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'', null, null, null, null, null, false,''f3fe9cae-c21e-4dba-9a10-008cfa6dca39'', null, null, null, null))> 0  Time: '|| (clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_instance(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_instance(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_instance(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_instance(bigint,bigint,boolean,text,text) TO graphql;

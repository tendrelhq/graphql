CREATE OR REPLACE FUNCTION entity.func_test_entitytag(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	temptext text;
Begin

/*
select * from entity.func_test_entitytag(
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
test_passedtext = test_passedtext||E'testing entity tags\n-------\n'||E'  all customers all entitytags\n  -------\n';
test_failedtext = test_failedtext||E'testing entity tags\n-------\n'||E'  all customers all entitytags\n  -------\n';

if (select count(*) from entity.crud_entitytag_read_min(null,null,null,null, null, true, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) entity.crud_entitytag_read_min(null,null,null,null, null, true, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_min(null,null,null,null, null, true, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_entitytag_read_full(null,null,null,null, null, true, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) entity.crud_entitytag_read_full(null,null,null,null, null, true, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_full(null,null,null,null, null, true, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- specific tag
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  specific tag\n  -------\n';
test_failedtext = test_failedtext||E'  specific tag\n  -------\n';

-- specific tag

if (select count(*) from entity.crud_entitytag_read_min('ccda3933-c740-40ec-9a2b-a9f1a7d4db28','8cd49ef4-2b70-410b-85aa-4b67f617066a',null,null, null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) entity.crud_entitytag_read_min(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',''8cd49ef4-2b70-410b-85aa-4b67f617066a'',null,null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') = 1  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_min(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',''8cd49ef4-2b70-410b-85aa-4b67f617066a'',null,null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')= 1  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_entitytag_read_full('ccda3933-c740-40ec-9a2b-a9f1a7d4db28','8cd49ef4-2b70-410b-85aa-4b67f617066a',null,null, null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) entity.crud_entitytag_read_full(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',''8cd49ef4-2b70-410b-85aa-4b67f617066a'',null,null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') = 1  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_full(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',''8cd49ef4-2b70-410b-85aa-4b67f617066a'',null,null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') = 1  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- all tags for a specific instance
test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';
test_passedtext = test_passedtext||E'  all tags for a specific instance\n  -------\n';
test_failedtext = test_failedtext||E'  all tags for a specific instance\n  -------\n';

if (select count(*) from entity.crud_entitytag_read_min('ccda3933-c740-40ec-9a2b-a9f1a7d4db28',null,'d57f7b9c-fe72-463a-9cc9-1cb03ad4a812',null, null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) entity.crud_entitytag_read_min(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',null,''d57f7b9c-fe72-463a-9cc9-1cb03ad4a812'',null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_min(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',null,''d57f7b9c-fe72-463a-9cc9-1cb03ad4a812'',null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_entitytag_read_full('ccda3933-c740-40ec-9a2b-a9f1a7d4db28',null,'d57f7b9c-fe72-463a-9cc9-1cb03ad4a812',null, null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) entity.crud_entitytag_read_full(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',null,''d57f7b9c-fe72-463a-9cc9-1cb03ad4a812'',null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_full(''ccda3933-c740-40ec-9a2b-a9f1a7d4db28'',null,''d57f7b9c-fe72-463a-9cc9-1cb03ad4a812'',null, null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- all instances for a template
test_passedtext = test_passedtext||E'\n  all instances for a template\n  -------\n';
test_failedtext = test_failedtext||E'\n  all instances for a template\n  -------\n';

if (select count(*) from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0   Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0   Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0 Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- all tags for a template no instances
test_passedtext = test_passedtext||E'\n  all tags for a template no instances\n  -------\n';
test_failedtext = test_failedtext||E'\n  all tags for a template no instances\n  -------\n';

if (select count(*) from (select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as foo) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from (select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,null,null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) > 0 as foo)   Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from (select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,null,null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) > 0 as foo)   Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from (select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null,'0b9f3142-e7ed-4f78-8504-ccd2eb505075', null, false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) as foo) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from (select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,null,null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) > 0 as foo)   Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from (select distinct entitytagcustagentityuuid from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null,null,null,null,''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', null, false, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) > 0 as foo)   Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- all instances for a tag
test_passedtext = test_passedtext||E'\n  all instances for a tag\n  -------\n';
test_failedtext = test_failedtext||E'\n  all instances for a tag\n  -------\n';

if (select count(*) from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, null, 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, null, ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, null, ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0   Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, null, 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, null, ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0   Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, null, ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0 Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

-- all instances for a template and a tag
test_passedtext = test_passedtext||E'\n  all instances for a template and a tag\n  -------\n';
test_failedtext = test_failedtext||E'\n  all instances for a template and a tag\n  -------\n';

if (select count(*) from entity.crud_entitytag_read_min('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, '0b9f3142-e7ed-4f78-8504-ccd2eb505075', 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0  Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_min(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0   Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

test_passedtext = test_passedtext||E'\n';
test_failedtext = test_failedtext||E'\n';

if (select count(*) from entity.crud_entitytag_read_full('d7995576-8354-4aea-b052-1ce61052bd2e',null,null, '0b9f3142-e7ed-4f78-8504-ccd2eb505075', 'e7e8223d-3480-42b5-9fc6-9dee59667fa3', false, null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then test_passedtext = test_passedtext||'     Pass:  select count(*) from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0   Time: '||(clock_timestamp()-fact_end)::text;
		test_successtestcount = test_successtestcount + 1;
	Else test_failedtext = test_failedtext||'     Fail:  select count(*) from entity.crud_entitytag_read_full(''d7995576-8354-4aea-b052-1ce61052bd2e'',null,null, ''0b9f3142-e7ed-4f78-8504-ccd2eb505075'', ''e7e8223d-3480-42b5-9fc6-9dee59667fa3'', false, null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'') > 0 Time: '||(clock_timestamp()-fact_end)::text;
		test_failedtest = true;
		test_failedtestcount = test_failedtestcount + 1;
End If;
fact_end = clock_timestamp();

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$

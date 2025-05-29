BEGIN;

/*
DROP FUNCTION entity.func_test_entityfileinstance(bigint,bigint,boolean,text,text);
*/


-- Type: FUNCTION ; Name: entity.func_test_entityfileinstance(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_entityfileinstance(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    next_start timestamp with time zone;
	failedtest boolean;
	failedtestcount bigint;
	successtestcount bigint;	
	failedtext text;
	passedtext text;

Begin

/*
select * from entity.func_test_entityfileinstance(
	0::bigint, 
	0::bigint, 
	false, 
	'', 
	''
	)
*/

 -- Start the timer on this function
    next_start = clock_timestamp();
	failedtest = test_failedtest;
	failedtestcount = test_failedtestcount;
	successtestcount = test_successtestcount;	
	failedtext = test_failedtext;
	passedtext = test_passedtext;

	
-- Create Section for entity description tests
----------------------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'section','entity file instance tests',next_start,true ) as foo;

-- all file instances
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all file instances',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_min(null, null, null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_min(null, null, null,null, null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_full(null, null, null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_full(null, null, null,null, null, null,null,null)) > 0)  ) as foo ;

-- all file instances for an owner
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all file instances for an owner',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,null, null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,null, null, null,null,null)) > 0)  ) as foo ;

-- all file instances for a fileinstanceuuid
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all file instances for a fileinstanceuuid',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', ''b19d4a6d-151b-4924-88c8-da66b64f0658'', null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'b19d4a6d-151b-4924-88c8-da66b64f0658', null,null, null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', ''b19d4a6d-151b-4924-88c8-da66b64f0658'', null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'b19d4a6d-151b-4924-88c8-da66b64f0658', null,null, null, null,null,null)) > 0)  ) as foo ;

-- all file instances for an instanceuuid
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all file instances for an owner',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, ''87fc6238-1c3d-4f34-8a38-609855ab94ab'',null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '87fc6238-1c3d-4f34-8a38-609855ab94ab',null, null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, ''87fc6238-1c3d-4f34-8a38-609855ab94ab'',null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '87fc6238-1c3d-4f34-8a38-609855ab94ab',null, null, null,null,null)) > 0)  ) as foo ;

-- all file instances for a fieldinstanceuuid
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all file instances for a fieldinstanceuuid',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null,''6d29bc9a-f37f-43e4-81c0-b34a940ae1f9'', null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'6d29bc9a-f37f-43e4-81c0-b34a940ae1f9', null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entityfileinstance_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null,''6d29bc9a-f37f-43e4-81c0-b34a940ae1f9'', null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entityfileinstance_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'6d29bc9a-f37f-43e4-81c0-b34a940ae1f9', null, null,null,null)) > 0)  ) as foo ;



return query
	select failedtestcount, successtestcount, failedtest, passedtext, failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_entityfileinstance(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_entityfileinstance(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_entityfileinstance(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_entityfileinstance(bigint,bigint,boolean,text,text) TO graphql;

END;

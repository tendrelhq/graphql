BEGIN;

/*
DROP FUNCTION entity.func_test_entitydescription(bigint,bigint,boolean,text,text);
*/


-- Type: FUNCTION ; Name: entity.func_test_entitydescription(bigint,bigint,boolean,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_entitydescription(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
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
select * from entity.func_test_entitydescription(
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
		'section','entity description tests',next_start,true ) as foo;


-- all descriptions all customers
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all descriptions all customers',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_min(null, null, null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_min(null, null, null,null, null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_full(null, null, null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_full(null, null, null,null, null, null,null,null)) > 0)  ) as foo ;

-- all descriptions for an owner
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all descriptions for an owner',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null, null,null, null, null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null,  null,null,null, null, null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null, null,null, null, null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null,  null,null,null, null, null,null)) > 0)  ) as foo;

-- description for an entitydescriptionuuid
-------------------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','description for an entitydescriptionuuid',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', ''f42f8873-37a0-450e-97c8-c223955b2f02'', null,null, null,null, null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'f42f8873-37a0-450e-97c8-c223955b2f02', null,null, null, null,null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', ''f42f8873-37a0-450e-97c8-c223955b2f02'', null,null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'f42f8873-37a0-450e-97c8-c223955b2f02', null,null, null,null, null,null)) > 0)  ) as foo;

-- all descriptions for a template
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all descriptions for a template',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, ''2de8bf04-15bd-4df9-b5bc-4eb7fbb8e37e'', null, null,null, null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '2de8bf04-15bd-4df9-b5bc-4eb7fbb8e37e',null, null, null,null,null)) > 0)  ) as foo;

-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, ''2de8bf04-15bd-4df9-b5bc-4eb7fbb8e37e'',null, null, null,null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '2de8bf04-15bd-4df9-b5bc-4eb7fbb8e37e',null, null, null,null,null)) > 0)  ) as foo;

-- all descriptions for a field
----------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'test','all descriptions for a field',next_start,true  ) as foo;
-- min test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_min(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null,''3b477e48-82d7-43fa-a8a4-757d4d5ad457'', null,null, null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_min('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'3b477e48-82d7-43fa-a8a4-757d4d5ad457',null, null, null,null)) > 0)  ) as foo;
-- full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into failedtestcount, successtestcount, failedtest, passedtext, failedtext, next_start
FROM entity.util_test_createlog(failedtestcount,successtestcount,failedtest,passedtext,failedtext,
		'sql','((select count(*) from entity.crud_entitydescription_read_full(''e69fbc64-df87-4c0b-9cbf-bc87774947c7'', null, null,''3b477e48-82d7-43fa-a8a4-757d4d5ad457'', null,null, null,null)) > 0)',
		next_start, ((select count(*) from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'3b477e48-82d7-43fa-a8a4-757d4d5ad457', null,null, null,null)) > 0)  ) as foo;


return query
	select failedtestcount, successtestcount, failedtest, passedtext, failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_entitydescription(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_entitydescription(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_entitydescription(bigint,bigint,boolean,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_entitydescription(bigint,bigint,boolean,text,text) TO graphql;

END;

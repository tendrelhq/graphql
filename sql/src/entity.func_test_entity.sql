BEGIN;

/*
DROP FUNCTION entity.func_test_entity();
*/


-- Type: FUNCTION ; Name: entity.func_test_entity(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.func_test_entity()
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_start timestamp with time zone;
    fact_end timestamp with time zone;
	temptext text;
Begin

 -- Start the timer on this function
    fact_start = clock_timestamp();
	failedtest = false;
	failedtestcount = 0;
	successtestcount = 0;	
	temptext = '';
	failedtext = '';
	passedtext = '';

-- call entity.import_entity('all time');
-- select * from entity.func_test_entity();

-- data integrity
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_dataintegrity(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test import
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_import(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test entity templates
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_template(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test template field
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_template_field(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test instance field
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_instance(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test field instance field
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_instance_field(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test systag
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_systag(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test customer
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_customer(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test location
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_location(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test custags
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_custag(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test entity tag
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_entitytag(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test entitydescription
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_entitydescription(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

-- test fileinstance
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext  
		INTO failedtestcount, successtestcount, failedtest, passedtext, failedtext 
		FROM entity.func_test_entityfileinstance(failedtestcount, successtestcount, failedtest, passedtext, failedtext) as foo;

return query
	select failedtestcount, successtestcount, failedtest, passedtext, failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_entity() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_entity() TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_entity() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.func_test_entity() TO graphql;

END;


-- Type: FUNCTION ; Name: entity.util_test_createlog(bigint,bigint,boolean,text,text,text,text,timestamp with time zone,boolean); Owner: bombadil

CREATE OR REPLACE FUNCTION entity.util_test_createlog(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text, test_type text, test_text text, test_start timestamp with time zone, test_passed boolean)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text, next_start timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
Declare
	failedtest boolean;
	failedtestcount bigint;
	successtestcount bigint;	
	failedtext text;
	passedtext text;
	
Begin

	failedtest = test_failedtest;
	failedtestcount = test_failedtestcount;
	successtestcount = test_successtestcount;	
	failedtext = test_failedtext;
	passedtext = test_passedtext;

if test_type = 'header' or  test_type = 'section' 
	then passedtext = passedtext||E'\n'||test_text||E'\n-------\n';
		failedtext = failedtext||E'\n'||test_text||E'\n-------\n';
end if;

if test_type = 'test'  
	then passedtext = passedtext||'  '||test_text||E'\n  -------\n';
		failedtext = failedtext||'  '||test_text||E'\n  -------\n';
end if;

if test_type = 'sql' and  test_passed = true
	then 
		passedtext = passedtext||'     Pass: '||test_text||' Time: '|| (clock_timestamp()-test_start)::text||E'\n';
		successtestcount = successtestcount + 1;
end if;

if test_type = 'sql' and  test_passed = false
	then 
		failedtext = failedtext||'     Fail: '||test_text||' Time: '|| (clock_timestamp()-test_start)::text||E'\n';
		failedtest = true;
		failedtestcount = failedtestcount + 1;		
end if;

return query
	select 	failedtestcount, successtestcount,failedtest ,passedtext, failedtext, clock_timestamp();

End;

$function$;


REVOKE ALL ON FUNCTION entity.util_test_createlog(bigint,bigint,boolean,text,text,text,text,timestamp with time zone,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.util_test_createlog(bigint,bigint,boolean,text,text,text,text,timestamp with time zone,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.util_test_createlog(bigint,bigint,boolean,text,text,text,text,timestamp with time zone,boolean) TO bombadil WITH GRANT OPTION;

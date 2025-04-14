
-- Type: FUNCTION ; Name: func_timesheet_override_bigint(bigint,date); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_timesheet_override_bigint(temcustomerid bigint, tempdate date)
 RETURNS TABLE(workresultinstancevalue bigint, workresultinstanceworkinstanceid bigint)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	tempworkresultid bigint[];
BEGIN

-- this probably could be converted to the dw generic script.  But, for now we will just hard code this.
-- tempdate = '2025-01-10'

return query
select owri.workresultinstancevalue::bigint, owri.workresultinstanceworkinstanceid
		from workinstance wi
			inner join workresultinstance owri
				on owri.workresultinstanceworkinstanceid =  wi.workinstanceid
					and wi.workinstancestartdatetz::date > tempdate - ('14 days')::interval
					-- and wi.workinstancestartdatetz::date <= tempdate
					and wi.workinstancecustomerid = temcustomerid
			inner join datawarehouse.dim_workresult_v2 owr
				on owr.dim_workresultid = owri.workresultinstanceworkresultid
					and owr.dim_workresultname = 'Start Override'
					and owr.dim_workresultisprimary = false
					and owri.workresultinstanceworkinstanceid =  wi.workinstanceid;

/*
create temp table tempwri
as
select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue
from workinstance wi
	inner join workresultinstance wri
		on wi.id = any (func_workinstanceuuidarray)
			and wri.workresultinstanceworkinstanceid = wi.workinstanceid
			and wri.workresultinstanceworkresultid = any (tempworkresultid)
group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue;

return query
	select pl.workresultinstancecustomerid, pl.workresultinstanceworkinstanceid, pl.workresultinstancevalue::bigint
			from tempwri pl;

drop table tempwri;*/

End;

$function$;


REVOKE ALL ON FUNCTION func_timesheet_override_bigint(bigint,date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_timesheet_override_bigint(bigint,date) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_timesheet_override_bigint(bigint,date) TO tendreladmin WITH GRANT OPTION;

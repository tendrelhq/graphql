BEGIN;

/*
DROP PROCEDURE entity.import_workresultinstanceentityvalue(text);
*/


-- Type: PROCEDURE ; Name: entity.import_workresultinstanceentityvalue(text); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.import_workresultinstanceentityvalue(IN intervaltype text)
 LANGUAGE plpgsql
AS $procedure$
Declare
   location_start timestamp with time zone;
	maxdate timestamp with time zone;
--	updatedate timestamp with time zone;
	startdate timestamp with time zone;

Begin

-- Start the timer on this function
	location_start = clock_timestamp();

	maxdate = (select (max(workinstancemodifieddate)) from workinstance);

	startdate = 
		case 
			when intervaltype = '5 minute' and maxdate notNull 
				Then (select (max(workinstancemodifieddate) - interval '130 minute') as startdate from workinstance)
			when intervaltype = '1 hour' and maxdate notNull 
				Then (select (max(workinstancemodifieddate) - interval '8 hour') as startdate from workinstance)
			Else '01/01/1900'
		end;	



update public.workresultinstance wri1
set workresultinstanceentityvalue = entityinstanceuuid
from (select * 
		from public.workresultinstance wri2
			inner join public.workresult	
				on wri2.workresultinstanceworkresultid = workresultid
					and workresultentitytypeid = 852
					and (wri2.workresultinstancevalue notNull 
							and coalesce (wri2.workresultinstancevalue,'') <> '')
					and wri2.workresultinstanceentityvalue isNull
					and wri2.workresultinstancemodifieddate > startdate
			inner join entity.entityinstance
				on wri2.workresultinstancevalue::bigint = entityinstanceoriginalid
					and entityinstanceentitytemplatename = 'Location') as foo
where foo.workresultinstanceid = wri1.workresultinstanceid;

/*
if  (select dwlogginglevel4 from datawarehouse.dw_logginglevels) = false
	Then Return;
end if;

call datawarehouse.insert_tendy_tracker(0, 2521, 12496, 811, 844, 20786, 18068, 20787,20785, customer_start);
*/

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.import_workresultinstanceentityvalue(text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_workresultinstanceentityvalue(text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_workresultinstanceentityvalue(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.import_workresultinstanceentityvalue(text) TO graphql;

END;


-- Type: PROCEDURE ; Name: alarm_orphanedondemand(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.alarm_orphanedondemand(OUT tempcount bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   orphanedtask_start timestamp with time zone;  
   notestext text;
Begin
	orphanedtask_start = clock_timestamp();
	
-- Get the templates that should have workinstances

create temp table temptemplate as 
(
	SELECT wt.*
	FROM worktemplate AS wt	
		inner join workfrequency wf
			ON wt.worktemplateworkfrequencyid = wf.workfrequencyid
				and workfrequencytypeid <> 748
	where wt.worktemplateallowondemand = TRUE
		AND (wt.worktemplateenddate IS NULL
					OR wt.worktemplateenddate > NOW())	
);

-- Join this list to the location table and remove exceptions

create temp table tempwi as 
select wt.*, loc.*
from temptemplate wt
	INNER JOIN location AS loc
		ON wt.worktemplatelocationtypeid = loc.locationcategoryid
			AND wt.worktemplatesiteid = loc.locationsiteid
			AND (loc.locationenddate IS NULL
				OR loc.locationenddate > NOW())
	left join workinstanceexception AS wie
		on wt.worktemplatecustomerid = wie.workinstanceexceptioncustomerid
			AND wt.worktemplateid = wie.workinstanceexceptionworktemplateid
			AND wt.worktemplatesiteid = wie.workinstanceexceptionsiteid
			AND loc.locationid = wie.workinstanceexceptionlocationid
where wie.workinstanceexceptionid isNull;

tempcount = (select count(*) 
			from tempwi
				left join view_workinstance_full wi
					on workinstanceworktemplateid = worktemplateid
							AND workinstancestatusid in (706,707)
							AND wi.workinstancetypeid = 811
			where workinstanceid isNull);

--if  (select dwlogginglevel2 from datawarehouse.dw_logginglevels) = true
--	Then 
	call datawarehouse.insert_tendy_tracker(0, 1426, 12496, 811, 844, 14295, 18068, 14296,14294, orphanedtask_start);
--end if;


RAISE NOTICE 'count: %', tempcount;

if  tempcount = 0
	THEN drop table temptemplate;
		 drop table tempwi;
		 Return;
end if;

notestext = (
			select 'count: '||tempcount::text||', (worktemplateid,locationid), '||string_agg (teststring,', ') as orphans
			from (select worktemplatecustomerid, 
					'('||worktemplateid::text||','|| locationid::text||')' as teststring
				from tempwi
					left join view_workinstance_full wi
						on workinstanceworktemplateid = worktemplateid
								AND workinstancestatusid in (706,707)
								AND wi.workinstancetypeid = 811
				where workinstanceid isNull) as test
			group by worktemplatecustomerid
			);
			 
drop table temptemplate;
drop table tempwi;

-- cheating and prefilling the notes on the remediation.
-- may want to uniquely name the workinstnace as well
-- may also want to check to see if there is already a remediation open

call datawarehouse.insert_tendy_remediation(0, 1427, 12496, 694, 18068, 14299, notestext,14300 ,orphanedtask_start);


End;

$procedure$;


REVOKE ALL ON PROCEDURE alarm_orphanedondemand() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm_orphanedondemand() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm_orphanedondemand() TO tendreladmin WITH GRANT OPTION;

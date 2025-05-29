BEGIN;

/*
DROP PROCEDURE entity.create_pulse_instances();
*/


-- Type: PROCEDURE ; Name: entity.create_pulse_instances(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.create_pulse_instances()
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagemasterid bigint;
	parenttypeid bigint;
	locationtypeid bigint;

Begin

-- eventually this loads pulse records.  For now it removes 'Pulse' activities.

delete from entity.runtime_upload_prepped
where uploadactivityname = 'Pulse';

/*
INSERT INTO public.workinstance(
	workinstancecustomerid,
	workinstanceworktemplateid,
	workinstancesiteid,
	workinstancetypeid,
	workinstancestatusid,
	workinstancetargetstartdate,
	workinstancestartdate, 
	workinstancecompleteddate, 	
	workinstanceexternalid, 	
	workinstancetimezone,
	workinstancemodifiedby,
	workinstancerefuuid,
	workinstanceoriginatorworkinstanceid)
select 
	customerid,
	templateid,
	siteid,
	811,
	case
		when uploadenddate isNull
		then 707
		else 710
	End,
	uploadstartdate,
	uploadstartdate,
	uploadenddate,
	uploadrecordid, 
	timezone,
	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	uploadowneruuid||'-'||uploadrecordid||'-'||uploadlocationuuid||'-'||uploadstartdate,  -- refid = owner+row+location+activity+timestamp?
	(select workinstanceid from workinstance where id = batchinstanceuuid)
from entity.runtime_upload_prepped
where uploadactivityname = 'Run';

-- load the location result instance

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid, 
	workresultinstancecustomerid, 
	workresultinstancevalue, 
	workresultinstancecreateddate, 
	workresultinstancemodifieddate,
	workresultinstancestartdate, 
	workresultinstancecompleteddate, 
	workresultinstanceworkresultid, 
	workresultinstanceexternalid, 
	workresultinstancevaluelanguagetypeid, 
	workresultinstancemodifiedby,
	workresultinstancestatusid,
	workresultinstancetimezone)
(select 
 	workinstanceid,
 	workinstancecustomerid,  
	prep.locationid,  
 	workinstancecreateddate,
 	workinstancemodifieddate,
 	workinstancestartdate,
 	workinstancecompleteddate,
 	workresultid,
 	workinstanceexternalid,
 	languageid,
 	workinstancemodifiedby, 
	967,   -- this is result closed
	workinstancetimezone
from entity.runtime_upload_prepped prep
	join workinstance wi
		on prep.customerid = workinstancecustomerid
			and workinstancerefuuid = (prep.uploadowneruuid||'-'||prep.uploadrecordid||'-'||prep.uploadlocationuuid||'-'||prep.uploadstartdate)
			and workinstancestatusid in (707,710)
	inner join  workresult
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultentitytypeid = 852
 			and workresultisprimary = true			
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

					
-- load the worker result instance

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid, 
	workresultinstancecustomerid, 
	workresultinstancevalue, 
	workresultinstancecreateddate, 
	workresultinstancemodifieddate,
	workresultinstancestartdate, 
	workresultinstancecompleteddate, 
	workresultinstanceworkresultid, 
	workresultinstanceexternalid, 
	workresultinstancevaluelanguagetypeid, 
	workresultinstancemodifiedby,
	workresultinstancestatusid,
	workresultinstancetimezone)
(select 
 	workinstanceid,
 	workinstancecustomerid,  
	workinstancemodifiedby,  
 	workinstancecreateddate,
 	workinstancemodifieddate,
 	workinstancestartdate,
 	workinstancecompleteddate,
 	workresultid,
 	workinstanceexternalid,
 	languageid,
 	workinstancemodifiedby, 
	967,   -- this is result closed
	workinstancetimezone
from entity.runtime_upload_prepped prep
	join workinstance wi
		on prep.customerid = workinstancecustomerid
			and workinstancerefuuid = (prep.uploadowneruuid||'-'||prep.uploadrecordid||'-'||prep.uploadlocationuuid||'-'||prep.uploadstartdate)
			and workinstancestatusid in (707,710)
	inner join  workresult
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultentitytypeid = 850
 			and workresultisprimary = true			
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

-- load TAT

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid, 
	workresultinstancecustomerid, 
	workresultinstancevalue, 
	workresultinstancecreateddate, 
	workresultinstancemodifieddate,
	workresultinstancestartdate, 
	workresultinstancecompleteddate, 
	workresultinstanceworkresultid, 
	workresultinstanceexternalid, 
	workresultinstancevaluelanguagetypeid, 
	workresultinstancemodifiedby,
	workresultinstancestatusid,
	workresultinstancetimezone)
(select 
 	workinstanceid,
 	workinstancecustomerid,
	case when workinstancestatusid = 710
		then EXTRACT(EPOCH FROM (workinstancecompleteddate - workinstancestartdate))
		else null
	end,
 	workinstancecreateddate,
 	workinstancemodifieddate,
 	workinstancestartdate,
 	workinstancecompleteddate,
 	workresultid,
 	workinstanceexternalid,
 	languageid,
	workinstancemodifiedby,
	967,   -- this is result closed
	workinstancetimezone
from entity.runtime_upload_prepped prep
	join workinstance wi
		on prep.customerid = workinstancecustomerid
			and workinstancerefuuid = (prep.uploadowneruuid||'-'||prep.uploadrecordid||'-'||prep.uploadlocationuuid||'-'||prep.uploadstartdate)
			and workinstancestatusid in (707,710)
	inner join  workresult
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresulttypeid = 737	
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

-- reject count -- need to match with name so use the view and english

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid, 
	workresultinstancecustomerid, 
	workresultinstancevalue, 
	workresultinstancecreateddate, 
	workresultinstancemodifieddate,
	workresultinstancestartdate, 
	workresultinstancecompleteddate, 
	workresultinstanceworkresultid, 
	workresultinstanceexternalid, 
	workresultinstancevaluelanguagetypeid, 
	workresultinstancemodifiedby,
	workresultinstancestatusid,
	workresultinstancetimezone)
(select 
 	workinstanceid,
 	workinstancecustomerid,
	uploadunitrejectcount,
 	workinstancecreateddate,
 	workinstancemodifieddate,
 	workinstancestartdate,
 	workinstancecompleteddate,
 	workresultid,
 	workinstanceexternalid,
 	languageid,
	workinstancemodifiedby,
	967,   -- this is result closed
	workinstancetimezone
from entity.runtime_upload_prepped prep
	join workinstance wi
		on prep.customerid = workinstancecustomerid
			and workinstancerefuuid = (prep.uploadowneruuid||'-'||prep.uploadrecordid||'-'||prep.uploadlocationuuid||'-'||prep.uploadstartdate)
			and workinstancestatusid in (707,710)
	inner join  view_workresult
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultname = 'Reject Count'
			 and languagetranslationtypeid = 20
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

-- output

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid, 
	workresultinstancecustomerid, 
	workresultinstancevalue, 
	workresultinstancecreateddate, 
	workresultinstancemodifieddate,
	workresultinstancestartdate, 
	workresultinstancecompleteddate, 
	workresultinstanceworkresultid, 
	workresultinstanceexternalid, 
	workresultinstancevaluelanguagetypeid, 
	workresultinstancemodifiedby,
	workresultinstancestatusid,
	workresultinstancetimezone)
(select 
 	workinstanceid,
 	workinstancecustomerid,
	uploadunitrunoutput,
 	workinstancecreateddate,
 	workinstancemodifieddate,
 	workinstancestartdate,
 	workinstancecompleteddate,
 	workresultid,
 	workinstanceexternalid,
 	languageid,
	workinstancemodifiedby,
	967,   -- this is result closed
	workinstancetimezone
from entity.runtime_upload_prepped prep
	join workinstance wi
		on prep.customerid = workinstancecustomerid
			and workinstancerefuuid = (prep.uploadowneruuid||'-'||prep.uploadrecordid||'-'||prep.uploadlocationuuid||'-'||prep.uploadstartdate)
			and workinstancestatusid in (707,710)
	inner join  view_workresult
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultname = 'Run Output'
			 and languagetranslationtypeid = 20
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

-- the rest are empty

INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid, 
	workresultinstancecustomerid, 
	workresultinstancevalue, 
	workresultinstancecreateddate, 
	workresultinstancemodifieddate,
	workresultinstancestartdate, 
	workresultinstancecompleteddate, 
	workresultinstanceworkresultid, 
	workresultinstanceexternalid, 
	workresultinstancevaluelanguagetypeid, 
	workresultinstancemodifiedby,
	workresultinstancestatusid,
	workresultinstancetimezone)
(select 
 	workinstanceid,
 	workinstancecustomerid,
	null,
 	workinstancecreateddate,
 	workinstancemodifieddate,
 	workinstancestartdate,
 	workinstancecompleteddate,
 	workresultid,
 	workinstanceexternalid,
 	languageid,
	workinstancemodifiedby,
	967,   -- this is result closed
	workinstancetimezone
from entity.runtime_upload_prepped prep
	join workinstance wi
		on prep.customerid = workinstancecustomerid
			and workinstancerefuuid = (prep.uploadowneruuid||'-'||prep.uploadrecordid||'-'||prep.uploadlocationuuid||'-'||prep.uploadstartdate)
			and workinstancestatusid in (707,710)
	inner join  workresult
 		on workresultworktemplateid = workinstanceworktemplateid
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

update public.workinstance
set workinstanceoriginatorworkinstanceid = workinstanceid,
	workinstancemodifieddate = clock_timestamp()
where workinstanceoriginatorworkinstanceid isNull;
*/

RAISE NOTICE 'pulse instances discarded';

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.create_pulse_instances() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_pulse_instances() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_pulse_instances() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.create_pulse_instances() TO graphql;

END;

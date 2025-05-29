BEGIN;

/*
DROP PROCEDURE entity.create_idle_instances(uuid);
*/


-- Type: PROCEDURE ; Name: entity.create_idle_instances(uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.create_idle_instances(IN etl_batch uuid)
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagemasterid bigint;
	parenttypeid bigint;
	locationtypeid bigint;

Begin
-- create new batches for the owner  

-- need to check if we need to update a record (by id??)

-- update the workinstanace
update public.workinstance wi
set workinstancecompleteddate = uploadenddate,
	workinstancemodifieddate = now(),
	workinstancestatusid = case when uploadenddate notNull
								then 710
								else prepwi.workinstancestatusid
							end,
	workinstancemodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid)
from entity.runtime_upload_prepped  prep
	inner join public.workinstance prepwi
		on customerid = prepwi.workinstancecustomerid
			and uploadrecordid = prepwi.workinstanceexternalid
			and import_batch = etl_batch
	inner join worktemplate wt
		on prepwi.workinstanceworktemplateid = worktemplateid
	inner join public.worktemplatetype wtt
		on worktemplatetypeworktemplateuuid = wt.id
			and worktemplatetypesystagid in (988)
where wi.workinstancecustomerid = prep.customerid
	and prepwi.workinstanceid = wi.workinstanceid;

-- update the ourput and reject counts - do this for each possble workresult

update public.workresultinstance wri_ins
set workresultinstancevalue = uploadunitrejectcount,
	workresultinstancecompleteddate = uploadenddate,
	workresultinstancemodifieddate = now(),
	workresultinstancemodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid)
from entity.runtime_upload_prepped prep
	inner join public.workinstance wi
		on workinstanceexternalid = uploadrecordid
			and workinstancecustomerid = prep.customerid
			and import_batch = etl_batch
	inner join worktemplate wt
		on workinstanceworktemplateid = worktemplateid
	inner join public.worktemplatetype wtt
		on worktemplatetypeworktemplateuuid = wt.id
			and worktemplatetypesystagid in (988)			
	inner join public.workresultinstance wri
		on wri.workresultinstanceworkinstanceid = workinstanceid
	inner join  view_workresult wr
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultname = 'Reject Count'
			and languagetranslationtypeid = 20
where wri_ins.workresultinstanceid = wri.workresultinstanceid;

update public.workresultinstance wri_ins
set workresultinstancevalue = uploadunitrunoutput,
	workresultinstancecompleteddate = uploadenddate,
	workresultinstancemodifieddate = now(),
	workresultinstancemodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid)
from entity.runtime_upload_prepped prep
	inner join public.workinstance wi
		on workinstanceexternalid = uploadrecordid
			and workinstancecustomerid = prep.customerid
			and import_batch = etl_batch
	inner join worktemplate wt
		on workinstanceworktemplateid = worktemplateid
	inner join public.worktemplatetype wtt
		on worktemplatetypeworktemplateuuid = wt.id
			and worktemplatetypesystagid in (988)	
	inner join public.workresultinstance wri
		on wri.workresultinstanceworkinstanceid = workinstanceid
	inner join  view_workresult wr
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultname = 'Run Output Count'
			and languagetranslationtypeid = 20
where wri_ins.workresultinstanceid = wri.workresultinstanceid;


update public.workresultinstance wri_ins
set workresultinstancevalue = uploadunitrunoutput,
	workresultinstancecompleteddate = uploadenddate,
	workresultinstancemodifieddate = now(),
	workresultinstancemodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid)
from entity.runtime_upload_prepped prep
	inner join public.workinstance wi
		on workinstanceexternalid = uploadrecordid
			and workinstancecustomerid = prep.customerid
			and import_batch = etl_batch
	inner join worktemplate wt
		on workinstanceworktemplateid = worktemplateid
	inner join public.worktemplatetype wtt
		on worktemplatetypeworktemplateuuid = wt.id
			and worktemplatetypesystagid in (988)	
	inner join public.workresultinstance wri
		on wri.workresultinstanceworkinstanceid = workinstanceid
	inner join  view_workresult wr
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresulttypeid = 737	
			and languagetranslationtypeid = 20
where wri_ins.workresultinstanceid = wri.workresultinstanceid;


-- ad all missing records

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
from (select workinstanceid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
		uploademployeetendreluuid,
		uploadowneruuid,
		uploadrunid,
		uploadrecordid,
		uploadlocationuuid, 
		uploadactivityname, 
		batchinstanceuuid,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (988)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid	
	where uploadactivityname = 'Idle Time' and workinstanceid isNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate,uploadrunid, timezone, uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run;

-- location

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
 	customerid,  
	locationid,  
 	now(),
 	now(),
 	uploadstartdate,
 	uploadenddate,
 	workresultid,
 	uploadrecordid,
 	languageid,
 	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	967,   -- this is result closed
	timezone
from (select workinstanceid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
		uploademployeetendreluuid,
		uploadowneruuid,
		uploadrecordid,
		locationid, 
		uploadactivityname, 
		batchinstanceuuid,
		languageid,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (988)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Idle Time' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate, timezone, uploademployeetendreluuid,uploadowneruuid,uploadrecordid, locationid, uploadactivityname,batchinstanceuuid,languageid) as run
	inner join  workresult
 		on workresultworktemplateid = templateid
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
 	customerid,  
	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	now(),
 	now(),
 	uploadstartdate,
 	uploadenddate,
 	workresultid,
 	uploadrecordid,
 	languageid,
 	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ), 
	967,   -- this is result closed
	timezone
from (select workinstanceid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
		languageid,
		uploademployeetendreluuid,
		uploadowneruuid,
		uploadrecordid,
		uploadlocationuuid, 
		uploadactivityname, 
		batchinstanceuuid,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (988)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Idle Time' and workinstanceid notNull and import_batch = etl_batch 
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate, timezone, languageid,uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  workresult
 		on workresultworktemplateid = templateid
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
 	customerid,
	case when workinstancestatusid = 710
		then EXTRACT(EPOCH FROM (uploadenddate - uploadstartdate))
		else null
	end,
 	now(),
 	now(),
 	uploadstartdate,
 	uploadenddate,
 	workresultid,
 	uploadrecordid,
 	languageid,
	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	967,   -- this is result closed
	timezone
from (select workinstanceid,
		workinstancestatusid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
		languageid,
		uploademployeetendreluuid,
		uploadowneruuid,uploadrecordid,
		uploadlocationuuid, 
		uploadactivityname, 
		batchinstanceuuid,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (988)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Idle Time' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,workinstancestatusid,customerid,templateid, siteid, uploadstartdate, timezone, languageid,uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  workresult
 		on workresultworktemplateid = templateid
 			and workresulttypeid = 737	
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

-- rason code

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
 	customerid,
	uploadreasoncodename,
 	now(),
 	now(),
 	uploadstartdate,
 	uploadenddate,
 	workresultid,
 	uploadrecordid,
 	languageid,
	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	967,   -- this is result closed
	timezone
from (select workinstanceid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
		languageid,
		uploademployeetendreluuid,
		uploadowneruuid,uploadrecordid,
		uploadlocationuuid, 
		uploadactivityname, 
		batchinstanceuuid,
		uploadreasoncodename,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (988)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Idle Time' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid,uploadreasoncodename, uploadstartdate, timezone, languageid,uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  view_workresult
 		on workresultworktemplateid = templateid
 			and workresultname = 'Reason Code'
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
 	customerid,
	null,
 	now(),
 	now(),
 	uploadstartdate,
 	uploadenddate,
 	workresultid,
 	uploadrecordid,
 	languageid,
	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	967,   -- this is result closed
	timezone
from (select workinstanceid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
		languageid,
		uploademployeetendreluuid,
		uploadowneruuid,uploadrecordid,
		uploadlocationuuid, 
		uploadactivityname, 
		batchinstanceuuid,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (988)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Idle Time' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate, timezone,languageid, uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  workresult
 		on workresultworktemplateid = templateid
	left join workresultinstance
		on  workresultinstanceworkresultid = workresultid
			and workresultinstanceworkinstanceid = workinstanceid
where workresultinstanceid isNull);

update public.workinstance
set workinstanceoriginatorworkinstanceid = workinstanceid,
	workinstancemodifieddate = clock_timestamp()
where workinstanceoriginatorworkinstanceid isNull;

RAISE NOTICE 'idle instances loaded';

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.create_idle_instances(uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_idle_instances(uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_idle_instances(uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.create_idle_instances(uuid) TO graphql;

END;


-- Type: PROCEDURE ; Name: entity.create_run_instances(uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.create_run_instances(IN etl_batch uuid)
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagemasterid bigint;
	parenttypeid bigint;
	locationtypeid bigint;

Begin

-- check if run exists.  Update run if it does.  

-- update the workinstanace
update public.workinstance wi
set workinstancecompleteddate = case when uploadenddate notNull
	 									then (uploadenddate + interval '1 millisecond')
										 else uploadenddate
									end,
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
			and worktemplatetypesystagid in (987)
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
			and worktemplatetypesystagid in (987)			
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
			and worktemplatetypesystagid in (987)	
	inner join public.workresultinstance wri
		on wri.workresultinstanceworkinstanceid = workinstanceid
	inner join  view_workresult wr
 		on workresultworktemplateid = workinstanceworktemplateid
 			and workresultname = 'Run Output Count'
			and languagetranslationtypeid = 20
where wri_ins.workresultinstanceid = wri.workresultinstanceid;
			 

-- if it does not exist create it  
-- handle duplicates.

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
	workinstanceoriginatorworkinstanceid,
	workinstancepreviousid)
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
	(uploadstartdate - interval '1 millisecond'),
	case when uploadenddate notNull
		then (uploadenddate + interval '1 millisecond')
		 else uploadenddate
	end,
	uploadrecordid, 
	timezone,
	(select workerinstanceid from workerinstance where workerinstanceuuid = uploademployeetendreluuid ),
	uploadowneruuid||'-'||uploadrecordid||'-'||uploadlocationuuid||'-'||uploadstartdate,  -- refid = owner+row+location+activity+timestamp?
	(select workinstanceid from workinstance where id = batchinstanceuuid),
	(select workinstanceid from workinstance where id = batchinstanceuuid)	
from (select workinstanceid,
		customerid,
		templateid, 
		siteid, 
		uploadstartdate, 
		timezone, 
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
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid	
	where uploadactivityname = 'Run' and workinstanceid isNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate, timezone, uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run;

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
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Run' and workinstanceid notNull and import_batch = etl_batch
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
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Run' and workinstanceid notNull and import_batch = etl_batch
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
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Run' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,workinstancestatusid,customerid,templateid, siteid, uploadstartdate, timezone, languageid,uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  workresult
 		on workresultworktemplateid = templateid
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
 	customerid,
	uploadunitrejectcount,
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
		max(uploadunitrejectcount) as uploadunitrejectcount,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Run' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate, timezone, languageid,uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  view_workresult
 		on workresultworktemplateid = templateid
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
 	customerid,
	uploadunitrunoutput,
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
		max(uploadunitrunoutput) as uploadunitrunoutput,
		max(uploadenddate) as uploadenddate
	from entity.runtime_upload_prepped prep
		left join (select * from public.workinstance wi
						inner join worktemplate wt
							on workinstanceworktemplateid = worktemplateid
						inner join public.worktemplatetype wtt
							on worktemplatetypeworktemplateuuid = wt.id
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Run' and workinstanceid notNull and import_batch = etl_batch
	group by workinstanceid,customerid,templateid, siteid, uploadstartdate, timezone, languageid,uploademployeetendreluuid,uploadowneruuid,uploadrecordid, uploadlocationuuid, uploadactivityname,batchinstanceuuid) as run
	inner join  view_workresult
 		on workresultworktemplateid = templateid
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
								and worktemplatetypesystagid in (987)) run		
		on	workinstancecustomerid = prep.customerid
			and workinstanceexternalid = uploadrecordid
	where uploadactivityname = 'Run' and workinstanceid notNull and import_batch = etl_batch
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

update entity.runtime_upload_prepped
set workinstanceuuid = wi.id
from workinstance wi
	left join worktemplate wt
		on workinstanceworktemplateid = worktemplateid
	left join public.worktemplatetype wtt
		on worktemplatetypeworktemplateuuid = wt.id
			and worktemplatetypesystagid in (987)
where workinstanceexternalid = uploadrecordid
	and workinstancecustomerid = customerid
	and workinstanceuuid isNull
	 and import_batch = etl_batch;

RAISE NOTICE 'run instances loaded';

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.create_run_instances(uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_run_instances(uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_run_instances(uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.create_run_instances(uuid) TO graphql;

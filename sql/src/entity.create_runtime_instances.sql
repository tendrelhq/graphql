
-- Type: PROCEDURE ; Name: entity.create_runtime_instances(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.create_runtime_instances()
 LANGUAGE plpgsql
AS $procedure$
DECLARE 
	temprow RECORD;
	templocationentityuuid uuid;
	tempcode RECORD;
	tempsystaguuid text;
	tempsystagid bigint;
	tempreasoncodeuuid uuid;
	etl_batch uuid;

Begin

-- call entity.create_runtime_instances()

etl_batch = (select * from gen_random_uuid());

INSERT INTO entity.runtime_upload_prepped(
	uploadowneruuid, 
	uploadbatchid, 
	uploadrecordid, 
	uploadpreviousrecordid, 
	uploadparentuuid, 
	uploadparentname, 
	uploadlocationuuid, 
	uploadlocationname, 
	uploadstartdate, 
	uploadenddate, 
	uploadduration, 
	uploademployee, 
	uploademployeeid, 
	uploademployeetendreluuid, 
	uploadactivityuuid, 
	uploadactivityname, 
	uploadreasoncodeuuid, 
	uploadreasoncodename, 
	uploadunitrunoutput, 
	uploadunitrejectcount, 
	uploadresultuuid, 
	uploadresultname, 
	uploadunittypename, 
	uploadunittypeuuid, 
	uploadunitvalue, 
	uploadcreateddate,
	uploadrunid,
	originaluuid,
	import_batch)
select
	st.uploadowneruuid, 
	st.uploadbatchid, 
	st.uploadrecordid, 
	st.uploadpreviousrecordid, 
	st.uploadparentuuid, 
	st.uploadparentname, 
	st.uploadlocationuuid, 
	st.uploadlocationname, 
	st.uploadstartdate, 
	st.uploadenddate, 
	st.uploadduration, 
	st.uploademployee, 
	st.uploademployeeid, 
	st.uploademployeetendreluuid, 
	st.uploadactivityuuid, 
	st.uploadactivityname, 
	st.uploadreasoncodeuuid, 
	st.uploadreasoncodename, 
	st.uploadunitrunoutput, 
	st.uploadunitrejectcount, 
	st.uploadresultuuid, 
	st.uploadresultname, 
	st.uploadunittypename, 
	st.uploadunittypeuuid, 
	st.uploadunitvalue, 
	st.uploadcreateddate,
	st.uploadrunid,
	st.uploaduuid,
	etl_batch
from entity.runtime_upload_staging st
	left join entity.runtime_upload_prepped pp
		on st.uploaduuid = pp.originaluuid
where pp.uploaduuid isNull
order by uploadstartdate
;

delete from entity.runtime_upload_staging
where uploaduuid in (select originaluuid 
						from entity.runtime_upload_prepped
						where import_batch = etl_batch);

-- get customer needed for workinstances

update  entity.runtime_upload_prepped
set customerid = (select customerid 
					from entity.crud_customer_read_min(uploadowneruuid,null, null, false,null,null,null, null))
where customerid isNull and import_batch = etl_batch;

-- process the location
update entity.runtime_upload_prepped
	set uploadlocationname = location.locationname,
		locationid = location.locationid
from ( select locationentityuuid,locationname, locationid,locationtimezone,locationcustomerid 
		from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) location
where locationentityuuid = uploadlocationuuid
	and locationcustomerid = customerid
	and uploadlocationname isNull
	and import_batch = etl_batch;

update entity.runtime_upload_prepped
	set uploadlocationuuid = locationentityuuid,
			locationid = location.locationid
from ( select locationentityuuid,locationname , locationid, locationcustomerid 
	from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) location
	where uploadlocationname = location.locationname
		and locationcustomerid = customerid
		and uploadlocationuuid isNull
		and import_batch = etl_batch;
		
-- process parents

update entity.runtime_upload_prepped
	set uploadparentname = location.locationname,
		siteid = location.locationid,
		timezone = location.locationtimezone
from ( select locationentityuuid,locationname , locationid , locationtimezone, locationcustomerid 
		from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) location
where locationentityuuid = uploadparentuuid
	and uploadparentname isNull
	and import_batch = etl_batch;

update entity.runtime_upload_prepped
	set uploadlocationuuid = locationentityuuid,
		siteid = location.locationid,
		timezone = location.locationtimezone
from ( select locationentityuuid,locationname , locationid , locationtimezone, locationcustomerid 
	from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) location
	where uploadparentname = location.locationname
		and locationcustomerid = customerid
		and uploadlocationuuid isNull
		and import_batch = etl_batch;

-- Need to harden this.  Skip if there are 2 sites?  grab the first site?  Right now this will be random.

update entity.runtime_upload_prepped
	set uploadparentuuid = locationentityuuid,
		siteid = location.locationid,
		timezone = location.locationtimezone
from ( select locationentityuuid, locationownerentityuuid,locationparententityuuid, locationid, locationtimezone , locationcustomerid 
	from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		where locationentityuuid = locationparententityuuid
	group by locationentityuuid, locationownerentityuuid, locationparententityuuid, locationid, locationtimezone, locationcustomerid 
	) location
where uploadowneruuid = locationownerentityuuid 
	and locationcustomerid = customerid 
	and uploadparentuuid isNull
	and import_batch = etl_batch;

-- create missing records

BEGIN FOR temprow IN
		SELECT uploadowneruuid, uploadparentuuid,uploadlocationname 
		from entity.runtime_upload_prepped 
		where uploadlocationuuid isNull and import_batch = etl_batch
		group by uploadowneruuid, uploadparentuuid,uploadlocationname
	LOOP
		call entity.crud_location_create(
			temprow.uploadowneruuid, --create_locationownerentityuuid
			temprow.uploadparentuuid,	--create_locationparententityuuid   -- Null if self
			null,   --create_locationcornerstoneentityuuid
			null, --create_locationcornerstoneorder 
			null, -- create_locationtaguuid,
			'Runtime Location',  -- create_locationtag   -- need to lookup the runtime tag
			temprow.uploadlocationname,  -- create_locationname
			temprow.uploadlocationname,  -- locationdisplayname 
			null, -- locationscanid	
			null,  -- locationtimezone   -- Defaults to UTC
			'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- languagetypeuuid  
			null, -- locationexternalid
			null, -- locationexternalsystemuuid
			null, -- locationlatitude 
			null, -- locationlongitude
			null, -- locationradius
			null,
			null,
			templocationentityuuid, -- OUT create_locationentityuuid
			null);
	  	update entity.runtime_upload_prepped
			set uploadlocationuuid = templocationentityuuid    
		where uploadlocationname = temprow.uploadlocationname and import_batch = etl_batch;
	END LOOP;
END;

update entity.runtime_upload_prepped
	set uploadstartdate = (uploadenddate - make_interval(secs => uploadduration))
where uploadstartdate isNull and import_batch = etl_batch;

update entity.runtime_upload_prepped
	set uploadenddate = (uploadstartdate + make_interval(secs => uploadduration))
where uploadenddate isNull and import_batch = etl_batch;

-- find/create the employee

update entity.runtime_upload_prepped
	set uploademployeetendreluuid = workerinstanceuuid
from workerinstance 
where workerinstanceexternalid = uploademployeeid
	and workerinstancecustomerid = customerid
	and uploademployeetendreluuid isNull
	and import_batch = etl_batch;

update entity.runtime_upload_prepped
	set uploademployeetendreluuid = workerinstanceuuid
from worker
	inner join workerinstance
		on workerinstanceworkerid = workerid
where workerfullname = uploademployee
	and workerinstancecustomerid = customerid
	and uploademployeetendreluuid isNull and import_batch = etl_batch;

-- create the employee
INSERT INTO public.worker(
	workerlastname, 
	workerfirstname, 
	workeremail, 
	workerstartdate, 
	workerfullname, 
	workerlanguageid, 
	workerusername, 
	workerpassword,
	workerexternalid,
	workermodifiedby)
select 
	'Uploaded',
	uploademployeeid,  
	uploademployeeid||'@'||'Uploaded',
	now(),
	uploademployee, 
	20,
	uploademployeeid||'@'||uploadowneruuid,
	uploademployeeid||'@'||uploadowneruuid,
	uploademployeeid,
	null
from entity.runtime_upload_prepped
	left join worker
		on uploademployeeid||'@'||uploadowneruuid = workerusername
where workerid isNull and uploademployee isNull and uploademployeeid notNull and uploademployeetendreluuid isNull and import_batch = etl_batch
group by uploademployeeid,  
	uploademployeeid||'@'||'Uploaded',
	uploademployee, 
	uploademployeeid,
	uploademployeeid||'@'||uploadowneruuid,
	uploademployeeid;

--- future -- handle name being uploaded

INSERT INTO public.workerinstance(
	workerinstanceworkerid, 
	workerinstancecustomerid, 
	workerinstancestartdate, 
	workerinstancelanguageid, 
	workerinstanceexternalid,
	workerinstancescanid, 
	workerinstanceuserroleid,
	workerinstancemodifiedby)
select 
	workerid,
	customerid,
	now(),
	20,
	workerexternalid,
	uploademployeeid,  
	773,  -- worker role
	null
from worker w
	inner join entity.runtime_upload_prepped p
		on w.workerusername = p.uploademployeeid||'@'||p.uploadowneruuid
			and import_batch = etl_batch
	left join workerinstance
		on workerinstanceworkerid = workerid  
			and workerinstancecustomerid = customerid
where workerinstanceid isnull
group by workerid,customerid,workerexternalid,uploademployeeid;

update entity.runtime_upload_prepped
	set uploademployeetendreluuid = workerinstanceuuid
from worker
	inner join workerinstance 
		on workerinstanceworkerid = workerid
where uploademployeeid||'@'||uploadowneruuid = workerusername
	and workerinstancecustomerid = customerid
	and uploademployeetendreluuid isNull
	and import_batch = etl_batch;

-- find create the activities

update entity.runtime_upload_prepped
	set uploadactivityuuid = wt.id,
		templateid = wt.worktemplateid
from view_worktemplate wt
where wt.worktemplatename = uploadactivityname
	and wt.worktemplatecustomerid = customerid
	and wt.languagetranslationtypeid = 20
	and uploadactivityuuid isNull
	and import_batch = etl_batch;

-- find/create the reason code 

update entity.runtime_upload_prepped
	set uploadreasoncodeuuid = entityinstanceuuid
from entity.entityinstance
where entityinstanceownerentityuuid = uploadowneruuid
	and entityinstancetype = uploadreasoncodename
	and entityinstanceentitytemplatename = 'Customer Tag'
	and entityinstanceparententityuuid = 'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b'
	and uploadreasoncodeuuid isNull
	and import_batch = etl_batch;

-- if the reason code does not exist, create it

BEGIN FOR tempcode IN
		SELECT uploadowneruuid, uploadreasoncodename 
		from entity.runtime_upload_prepped 
		where uploadreasoncodeuuid isNull 
			and uploadreasoncodename notNull 
			and import_batch = etl_batch
		group by uploadowneruuid, uploadreasoncodename 
	LOOP
		call entity.crud_custag_create(
			tempcode.uploadowneruuid, --create_systagownerentityuuid
			'f875b28c-ccc9-4c69-b5b4-9f10ad89d23b' , --create_systagparententityuuid
			null,   --create_systagcornerstoneentityuuid
			null, --create_systagcornerstoneorder 
			tempcode.uploadreasoncodename,  -- create_systag
			'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', -- create_languagetypeuuid  
			null,  -- 	create_systagexternalid text,
			null, -- create_systagexternalsystemuuid
			null, 
			null, 
			tempsystagid, -- OUT create_systagid
			tempsystaguuid, -- OUT create_systaguuid text,
			tempreasoncodeuuid, -- OUT create_systagentityuuid uuid
			null);
	  	update entity.runtime_upload_prepped
			set uploadreasoncodeuuid = tempreasoncodeuuid    
		where uploadreasoncodename = tempcode.uploadreasoncodename and import_batch = etl_batch;
	END LOOP;
END;

-- add the constraint for the reason code

INSERT INTO public.worktemplateconstraint(
	worktemplateconstraintcreateddate, 
	worktemplateconstraintmodifieddate, 
	worktemplateconstraintmodifiedby, 
	worktemplateconstraintrefid, 
	worktemplateconstraintrefuuid, 
	worktemplateconstraintconstrainedtypeid, 
	worktemplateconstraintconstraintid, 
	worktemplateconstrainttemplateid, 
	worktemplateconstraintresultid, 
	worktemplateconstraintcustomerid, 
	worktemplateconstraintcustomeruuid)
select 
	now(),
	now(),
	337,
	null,
	null,
	'systag_4bbc3e18-de10-4f93-aabb-b1d051a2923d',
	custaguuid,
	wt.id,
	wr.id,
	wt.worktemplatecustomerid,
	(select customeruuid from public.customer where customerid = worktemplatecustomerid)
from worktemplate wt
	inner join (select templateid, uploadreasoncodeuuid, uploadreasoncodename
				from entity.runtime_upload_prepped prep
				where uploadreasoncodename notNull and import_batch = etl_batch
				group by templateid, uploadreasoncodeuuid, uploadreasoncodename ) batch
		on templateid = worktemplateid
	inner join view_workresult wr
		on  workresultworktemplateid = worktemplateid
			and languagetranslationtypeid = 20
			and workresultname = 'Reason Code'
	inner join public.custag
		on custagcustomerid = worktemplatecustomerid
			and custagid = (select entityinstanceoriginalid from entity.entityinstance where entityinstanceuuid = batch.uploadreasoncodeuuid::uuid)
	left join public.worktemplateconstraint
		on worktemplateconstrainttemplateid = wt.id
			and worktemplateconstraintresultid = wr.id
			and custagsystaguuid = worktemplateconstraintconstrainedtypeid
			and custaguuid = worktemplateconstraintconstraintid
			and custagcustomerid = worktemplateconstraintcustomerid
where worktemplateconstraintid isNull;

-- need result logic to create and update random results.  Come back to this.  

-- insert instances

call entity.create_batch_instances(etl_batch);
call entity.create_run_instances(etl_batch);
call entity.create_pulse_instances(); -- at this point this does nothing.  
call entity.create_downtime_instances(etl_batch);
call entity.create_idle_instances(etl_batch);

-- find the workinstanceid

update entity.runtime_upload_prepped
set workinstanceuuid = id
from workinstance
where workinstancerefuuid = (uploadowneruuid||'-'||uploadrecordid||'-'||uploadlocationuuid||'-'||uploadstartdate)
	and workinstancecustomerid = customerid
	and workinstanceuuid isNull
	and import_batch = etl_batch;

-- tie records to their run 

update workinstance
set workinstancepreviousid = run_id
from (select prep.workinstanceuuid,runs.workinstanceid as run_id, customerid
		from entity.runtime_upload_prepped prep
			inner join ( select *, 
								case when workinstancecompleteddate isNull
									then (now() + interval '5 minutes')
									else workinstancecompleteddate
								end as calcenddate
						from public.workinstance wi
							inner join worktemplate wt
								on workinstanceworktemplateid = worktemplateid
									and workinstancecustomerid in (select distinct customerid from entity.runtime_upload_prepped where import_batch = etl_batch)
									and workinstancestartdate <= (select max(uploadstartdate) from entity.runtime_upload_prepped where import_batch = etl_batch)
									and workinstancestartdate > (select max(uploadstartdate) from entity.runtime_upload_prepped where import_batch = etl_batch) - interval '30 days'
							inner join public.worktemplatetype wtt
								on worktemplatetypeworktemplateuuid = wt.id
									and worktemplatetypesystagid in  (987)
							inner join  workresult
								on workresultworktemplateid = workinstanceworktemplateid
									and workresultentitytypeid = 852
									and workresultisprimary = true	
							inner join workresultinstance
								on workresultinstanceworkresultid = workresultid
									and workresultinstanceworkinstanceid = workinstanceid) runs
				on customerid = workinstancecustomerid
					and locationid::text = workresultinstancevalue
					and uploadstartdate >  workinstancestartdate
					and uploadenddate < calcenddate
					and templateid in (select worktemplateid
										from worktemplate
											inner join public.worktemplatetype 
												on worktemplatetypeworktemplateuuid = id
													and worktemplatetypesystagid in  (988, 989)
													and worktemplatecustomerid = customerid)
			where import_batch = etl_batch) p2
where id = p2.workinstanceuuid
	and workinstancecustomerid = customerid;

delete from entity.runtime_upload_prepped where import_batch = etl_batch;

END; 

$procedure$;


REVOKE ALL ON PROCEDURE entity.create_runtime_instances() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_runtime_instances() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_runtime_instances() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.create_runtime_instances() TO graphql;

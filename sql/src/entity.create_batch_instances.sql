
-- Type: PROCEDURE ; Name: entity.create_batch_instances(uuid); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.create_batch_instances(IN etl_batch uuid)
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagemasterid bigint;
	parenttypeid bigint;
	locationtypeid bigint;

Begin
-- create new batches for the owner  

update entity.runtime_upload_prepped
set batchinstanceuuid = wi.id
from public.workinstance wi
	inner join worktemplate wt
		on workinstanceworktemplateid = worktemplateid
	inner join public.worktemplatetype wtt
		on worktemplatetypeworktemplateuuid = wt.id
			and worktemplatetypesystagid in (1075)
where uploadbatchid = workinstanceexternalid and batchinstanceuuid isNull 	
	and customerid = workinstancecustomerid and import_batch = etl_batch;

if ((select count(*) from entity.runtime_upload_prepped where batchinstanceuuid isNull and import_batch = etl_batch) > 0)
	then
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
			workinstancerefuuid)
		(select 
		 	batches.customerid,
			(select worktemplateid 
				from worktemplate wt
					inner join public.worktemplatetype wtt
						on worktemplatetypeworktemplateuuid = wt.id
							and worktemplatecustomerid = batches.customerid
							and worktemplatetypesystagid = 1075 ), -- fix this
			batches.siteid,
			811,
			707,
			batches.mindate,
			batches.mindate, 
			null,  	
			batches.uploadbatchid,
			batches.timezone,
		 	(select workerinstanceid from workerinstance where workerinstanceuuid = batches.modby), 
			batches.uploadbatchid 
		from (select customerid,uploadowneruuid,uploadbatchid,siteid,timezone,  min(uploadstartdate) as mindate, min(uploademployeetendreluuid) as modby
				from entity.runtime_upload_prepped
					left join (
						select languagemastersource, workinstancecustomerid 
						from workinstance wi
							inner join worktemplate wt
								on workinstanceworktemplateid = worktemplateid
							inner join public.worktemplatetype wtt
								on worktemplatetypeworktemplateuuid = wt.id
									and worktemplatetypesystagid = 1075  -- fix this
							inner join languagemaster
								on workinstancenameid = languagemasteruuid
						group by languagemastersource,workinstancecustomerid) batches
						on languagemastersource = uploadbatchid
							and workinstancecustomerid = customerid
				where languagemastersource isNull and import_batch = etl_batch
				group by customerid,uploadowneruuid,uploadbatchid,siteid,timezone) batches);
		
		INSERT INTO public.languagemaster(
				languagemastercustomerid,
				languagemastersourcelanguagetypeid,
				languagemastersource,
				languagemastermodifiedby,
				languagemasterrefid)
		select workinstancecustomerid, 20, workinstanceexternalid, workinstancemodifiedby, workinstanceid
		from workinstance
			inner join worktemplate wt
				on workinstanceworktemplateid = worktemplateid
					and workinstancenameid isNull
					and workinstanceexternalid notNull
					and workinstancestatusid = 707
			inner join public.worktemplatetype wtt
				on worktemplatetypeworktemplateuuid = wt.id
					and worktemplatetypesystagid = 1075;
		
		update workinstance
		set workinstancenameid = languagemasteruuid
		from languagemaster
		where workinstanceid = languagemasterrefid
			and workinstancenameid isNull;
		
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
			workinstancesiteid,  
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
		from workinstance 
			inner join (select uploadbatchid, customerid, languageid, etl_batch
						from entity.runtime_upload_prepped prep
						where  import_batch = etl_batch
						group by uploadbatchid,customerid, languageid, etl_batch)batches
				on row(workinstancerefuuid,workinstancecustomerid) = row(batches.uploadbatchid, batches.customerid)
					and workinstancestatusid = 707
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
		from workinstance 
			inner join (select uploadbatchid, customerid, languageid
						from entity.runtime_upload_prepped prep
						where  import_batch = etl_batch
						group by uploadbatchid,customerid, languageid)batches
				on row(workinstancerefuuid,workinstancecustomerid) = row(batches.uploadbatchid, batches.customerid)
					and workinstancestatusid = 707
			inner join  workresult
		 		on workresultworktemplateid = workinstanceworktemplateid
		 			and workresultentitytypeid = 850
		 			and workresultisprimary = true			
			left join workresultinstance
				on  workresultinstanceworkresultid = workresultid
					and workresultinstanceworkinstanceid = workinstanceid
		where workresultinstanceid isNull);
		
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
			966,   -- this is result open
			workinstancetimezone
		from workinstance 
			inner join (select uploadbatchid, customerid, languageid
						from entity.runtime_upload_prepped prep
						where  import_batch = etl_batch
						group by uploadbatchid,customerid, languageid)batches
				on row(workinstancerefuuid,workinstancecustomerid) = row(batches.uploadbatchid, batches.customerid)
					and workinstancestatusid = 707
			inner join  workresult
		 		on workresultworktemplateid = workinstanceworktemplateid
		 			and workresulttypeid = 737	
			left join workresultinstance
				on  workresultinstanceworkresultid = workresultid
					and workresultinstanceworkinstanceid = workinstanceid
		where workresultinstanceid isNull);
		
		update public.workinstance
		set workinstanceoriginatorworkinstanceid = workinstanceid,
			workinstancemodifieddate = clock_timestamp()
		where workinstanceoriginatorworkinstanceid isNull;

		update entity.runtime_upload_prepped
		set batchinstanceuuid = wi.id
		from public.workinstance wi
			inner join worktemplate wt
				on workinstanceworktemplateid = worktemplateid
			inner join public.worktemplatetype wtt
				on worktemplatetypeworktemplateuuid = wt.id
					and worktemplatetypesystagid in (1075)
		where uploadbatchid = workinstanceexternalid and batchinstanceuuid isNull 	and customerid = workinstancecustomerid  and import_batch = etl_batch;
end if;

RAISE NOTICE 'batch instances loaded';

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.create_batch_instances(uuid) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_batch_instances(uuid) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.create_batch_instances(uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.create_batch_instances(uuid) TO graphql;

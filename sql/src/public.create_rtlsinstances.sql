BEGIN;

/*
DROP PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint);
*/


-- Type: PROCEDURE ; Name: create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.create_rtlsinstances(IN create_customeruuid text, IN create_locationuuid text, IN create_workerinstanceuuid text, IN create_localuuid text, IN create_previouslocaluuid text, IN create_rtlsactivitytype text, IN create_createddate numeric, IN create_onlinestatus text, IN create_accuracy numeric, IN create_altitude numeric, IN create_altitudeaccuracy numeric, IN create_heading numeric, IN create_latitude numeric, IN create_longitude numeric, IN create_speed numeric, IN create_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
	tempcustomerid bigint;
	tempsiteid bigint;
	templocationid bigint;
	temptemplateid bigint;
	tempworkinstanceid bigint;
	tempworkerinstanceid bigint;
	temppreviousid  bigint;
	tempdate timestamp with time zone;
	temptz text;
	tempresultid  bigint;

Begin

-- Future - insert CheckIn/Out
-- Future RTLS tempalte is a a new task type

tempcustomerid = (select customerid
					from customer
					where customeruuid = create_customeruuid);

tempsiteid = (select locationsiteid
					from location
					where locationcustomerid = tempcustomerid
						and locationuuid = create_locationuuid);

templocationid = (select locationid
					from location
					where locationcustomerid = tempcustomerid
						and locationuuid = create_locationuuid);

-- Future - Add guardrails if tempcustomerid isNull

-- Find RTLS template for this customer.

temptemplateid = (select worktemplateid
					from worktemplate
						inner join public.worktemplatetype
							on worktemplateid = worktemplatetypeworktemplateid
								and worktemplatetypesystaguuid = (select systaguuid
																	from systag
																	where systaguuid = 'f0d0bca1-827a-46da-80bc-af1c8ef914db'  )
					where worktemplatecustomerid = tempcustomerid
						and worktemplatesiteid = tempsiteid);

tempdate = (SELECT to_timestamp( TRUNC(create_createddate/ 1000)));

temppreviousid = (select workinstanceid
					from workinstance
					where workinstancecustomerid = tempcustomerid
						and  workinstanceexternalid = create_previouslocaluuid);

tempworkerinstanceid = (select workerinstanceid
							from workerinstance
							where workerinstanceuuid =  create_workerinstanceuuid);


temptz = (select locationtimezone from location where locationid = tempsiteid);

-- Futue proof this checking to see if the wi already exists.

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
	workinstancepreviousid,
	workinstancemodifiedby)
values (
 	tempcustomerid,
	temptemplateid,
	tempsiteid,
	811,
	710,
	tempdate,
	tempdate,
	tempdate,
	create_localuuid,
	temptz,
	temppreviousid,
 	create_modifiedbyid) ;

tempworkinstanceid = (select workinstanceid from workinstance where workinstanceexternalid = create_localuuid );
-- insert primary location

tempresultid = (select workresultid
				from workresult
				where workresultworktemplateid = temptemplateid
					and workresultentitytypeid = 852
		 			and workresultisprimary = true);

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	templocationid,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert primary worker

tempresultid = (select workresultid
				from workresult
				where workresultworktemplateid = temptemplateid
					and workresultentitytypeid = 850
		 			and workresultisprimary = true);

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	tempworkerinstanceid,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert TAT

tempresultid = (select workresultid
				from workresult
				where workresultworktemplateid = temptemplateid
					and workresulttypeid = 737);

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	1,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert tendrel version geo info -- Future work

-- insert 'RTLS - Online Status'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Online Status');

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_onlinestatus,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Accuracy'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Accuracy') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_accuracy,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Altitude'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Altitude') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_altitude,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Altitude Accuracy'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Altitude Accuracy') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_altitudeAccuracy,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Heading'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Heading') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_heading,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Latitude'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Latitude') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_latitude,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Longitude'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Longitude') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_longitude,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

-- insert 'RTLS - Speed'

tempresultid = (select workresultid
				from view_workresult
				where workresultworktemplateid = temptemplateid
					and languagetranslationtypeid = 20
					and workresultname = 'RTLS - Speed') ;

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
	workresultinstancestatusid)
values (
 	tempworkinstanceid,
 	tempcustomerid,
	create_speed,
	tempdate,
	now(),
	tempdate,
	tempdate,
	tempresultid,
 	create_localuuid,
 	20,
 	create_modifiedbyid,
	967   -- this is result closed
	);

update public.workinstance
set workinstanceoriginatorworkinstanceid = tempworkinstanceid,
	workinstancemodifieddate = clock_timestamp()
where workinstanceid = tempworkinstanceid;

--RAISE NOTICE 'instance loaded';

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE create_rtlsinstances(text,text,text,text,text,text,numeric,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,bigint) TO tendreladmin WITH GRANT OPTION;

END;

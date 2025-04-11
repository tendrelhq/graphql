
-- Type: FUNCTION ; Name: func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]); Owner: bombadil

CREATE OR REPLACE FUNCTION public.func_read_rtls_nth_record(read_startdate timestamp with time zone, read_enddate timestamp with time zone, read_originationidarray bigint[], read_customeruuidarray text[], read_workinstanceuuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
 RETURNS TABLE(workinstanceid bigint, workinstanceuuid text, workinstancecustomerid bigint, workinstanceworktemplateid bigint, workinstancesiteid bigint, workinstancepreviousid bigint, workinstanceoriginatorworkinstanceid bigint, workinstancestartdate timestamp with time zone, workinstancecompleteddate timestamp with time zone, workinstanceexternalid text, workinstancetimezone text, locationid bigint, workerinstanceid bigint, workerinstanceuuid text, latitude numeric, longitude numeric, onlinestatus text, accuracy numeric, altitude numeric, altaccuracy numeric, heading numeric, speed numeric, previousworkinstanceexternalid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

tempworkerarray bigint[];
templocationarray bigint[];
tempcustomerarray text[];
tempworkinstanceidarray bigint[];
tempworkinstancearray text[];
tempstardate timestamp with time zone;
tempenddate timestamp with time zone;
tempfactor bigint;

BEGIN

/*

-- future add in language type (For now hardcoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_read_rtls_nth_record(null,null,null, null,null,null, null)

-- send in an array of customeruuids
select * from public.func_read_rtls_nth_record(null,null,null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,null, null)

-- send in an array of locationuuids
select * from public.func_read_rtls_nth_record(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_read_rtls_nth_record(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_read_rtls_nth_record('10/27/2024',null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record(null,'10/27/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record('10/27/2024','10/28/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in originationid
select * from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],
			null,null,null, null)
select count(*) from workinstance where workinstanceoriginatorworkinstanceid = 2079961

-- send in workinstances
select * from public.func_read_rtls_nth_record(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- group by originationid
select wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone,min(wi.workinstancestartdate), count(*)
from public.func_read_rtls_nth_record(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18']) as wi
group by wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone

*/

if (read_customeruuidarray isNull or array_length(read_customeruuidarray, 1) = 0)
	then tempcustomerarray = ARRAY(
		select customeruuid
		from customerconfig
			inner join customer
				on customerconfigcustomeruuid = customeruuid
					and customerconfigvalue = 'true'
			inner join systag t
				on t.systaguuid = customerconfigtypeuuid
					and t.systagtype = 'RTLS'
			inner join systag category on t.systagparentid = category.systagid );
	else tempcustomerarray = read_customeruuidarray;
End if;

-- eventually move this to uuid or even entity
-- I think this does not work.  Return to it.

if (read_locationuuidarray isNull or array_length(read_locationuuidarray, 1) = 0)
	then templocationarray = ARRAY(
		select loc.locationid from location loc
		where loc.locationcustomerid in (select customerid from customer
									where customeruuid = any (tempcustomerarray))); -- replace this with a call to get all rtls locations for the customers
	else templocationarray = ARRAY(
		select lo2.locationid from location lo2
		where lo2.locationuuid = any (read_locationuuidarray));
End if;

-- Should we skip this?

if (read_workerinstanceuuidarray isNull or array_length(read_workerinstanceuuidarray, 1) = 0)
	then tempworkerarray = ARRAY(
		select worker_instance2.workerinstanceid from workerinstance worker_instance2
		where worker_instance2.workerinstancecustomerid in (select customerid from customer
										where customeruuid = any (tempcustomerarray)));
	else tempworkerarray = ARRAY(
		select worker_instance3.workerinstanceid from workerinstance worker_instance3
		where worker_instance3.workerinstanceuuid = any (read_workerinstanceuuidarray));
End if;

tempstardate =
	case
		when read_startdate isnull
			then '01/01/1900'
		else read_startdate
	end;

tempenddate =
	case
		when read_enddate isnull
			then clock_timestamp()
		else read_enddate
	end;

-- I need to add usage of location id.  Forgot to do this.

if (read_originationidarray isNull or array_length(read_originationidarray, 1) = 0)
		and (read_workinstanceuuidarray isNull or array_length(read_workinstanceuuidarray, 1) = 0)
	then create temp table tempworkinstancetable as
		(select wi.workinstanceid, wi.id, wi.workinstancecompleteddate, wi.workinstanceoriginatorworkinstanceid
			FROM workinstance wi
				join public.worktemplatetype wtt
					on wi.workinstanceworktemplateid = wtt.worktemplatetypeworktemplateid
						and worktemplatetypesystaguuid in ('f0d0bca1-827a-46da-80bc-af1c8ef914db')  -- RTLS
						and worktemplatetypecustomeruuid = any (tempcustomerarray)  -- Customer
						and wi.workinstancestatusid in (707,710)  -- in progress or Completed
						and wi.workinstancetrustreasoncodeid = 762  -- Trusted
						and wi.workinstancestartdate > tempstardate
						and wi.workinstancestartdate < tempenddate
						and wi.workinstancecompleteddate > tempstardate
						and wi.workinstancecompleteddate < tempenddate
			order by wi.workinstanceid	);
	else  create temp table tempworkinstancetable as
				(select wi2.workinstanceid, wi2.id, wi2.workinstancecompleteddate, wi2.workinstanceoriginatorworkinstanceid
				from workinstance wi2
				where wi2.workinstanceoriginatorworkinstanceid = any(read_originationidarray)
				order by wi2.workinstanceid);
end if;

if (select count(*) from tempworkinstancetable) <= 100
	then tempfactor = 1;
	else tempfactor = ((select count(*) from tempworkinstancetable) / 100);
end if;

create temp table tempworkinstancetable2 as
(select nbrrows.workinstanceid, nbrrows.id, nbrrows.workinstanceoriginatorworkinstanceid, nbrrows.workinstancecompleteddate
	from (select row_number() OVER(ORDER BY t.workinstancecompleteddate desc) AS rownbr , *
			from tempworkinstancetable t ) nbrrows
	WHERE (nbrrows.rownbr - 1) % tempfactor = 0
union
select maxrecord.workinstanceid, maxrecord.id, maxrecord.workinstanceoriginatorworkinstanceid, maxtable.maxdate as workinstancecompleteddate
	from tempworkinstancetable maxrecord
		inner join (select twt.workinstanceoriginatorworkinstanceid as originator, max(twt.workinstancecompleteddate) as maxdate
					from tempworkinstancetable twt
					group by twt.workinstanceoriginatorworkinstanceid) as maxtable
			on maxtable.originator = maxrecord.workinstanceoriginatorworkinstanceid
				and maxtable.maxdate = maxrecord.workinstancecompleteddate
union
select minrecord.workinstanceid, minrecord.id, minrecord.workinstanceoriginatorworkinstanceid, mintable.mindate as workinstancecompleteddate
	from tempworkinstancetable minrecord
		inner join (select twt2.workinstanceoriginatorworkinstanceid as originator, min(twt2.workinstancecompleteddate) as mindate
					from tempworkinstancetable twt2
					group by twt2.workinstanceoriginatorworkinstanceid) as mintable
			on mintable.originator = minrecord.workinstanceoriginatorworkinstanceid
				and mintable.mindate = minrecord.workinstancecompleteddate
							);

return query
select
	returnrecord.workinstanceid,
	 returnrecord.workinstanceuuid,
	 returnrecord.workinstancecustomerid,
	 returnrecord.workinstanceworktemplateid,
	 returnrecord.workinstancesiteid,
	 returnrecord.workinstancepreviousid,
	 returnrecord.workinstanceoriginatorworkinstanceid,
	 returnrecord.workinstancestartdate,
	 returnrecord.workinstancecompleteddate,
	 returnrecord.workinstanceexternalid,
	 returnrecord.workinstancetimezone,
	 returnrecord.locationid,
	 returnrecord.workerinstanceid,
	 returnrecord.workerinstanceuuid,
	 returnrecord.latitude,
	 returnrecord.longitude,
	 returnrecord.onlinestatus,
	 returnrecord.accuracy,
	 returnrecord.altitude,
	 returnrecord.altaccuracy,
	 returnrecord.heading,
	 returnrecord.speed,
	 returnrecord.previousworkinstanceexternalid
	from public.func_readrtls(
		read_startdate,
		read_enddate,
		read_originationidarray,
		read_customeruuidarray,
		null,
		read_locationuuidarray,  -- replace this once this is fixed.
		read_workerinstanceuuidarray -- replace this once this is fixed.
			) as returnrecord
			inner join tempworkinstancetable2 rt2
				on rt2.workinstanceid = returnrecord.workinstanceid;

drop table tempworkinstancetable;
drop table tempworkinstancetable2;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_nth_record(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO bombadil WITH GRANT OPTION;

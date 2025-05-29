BEGIN;

/*
DROP FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]);
*/


-- Type: FUNCTION ; Name: func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_readrtls(read_startdate timestamp with time zone, read_enddate timestamp with time zone, read_originationidarray bigint[], read_customeruuidarray text[], read_workinstanceuuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
 RETURNS TABLE(workinstanceid bigint, workinstanceuuid text, workinstancecustomerid bigint, workinstanceworktemplateid bigint, workinstancesiteid bigint, workinstancepreviousid bigint, workinstanceoriginatorworkinstanceid bigint, workinstancestartdate timestamp with time zone, workinstancecompleteddate timestamp with time zone, workinstanceexternalid text, workinstancetimezone text, locationid bigint, workerinstanceid bigint, workerinstanceuuid text, latitude numeric, longitude numeric, onlinestatus text, accuracy numeric, altitude numeric, altaccuracy numeric, heading numeric, speed numeric, previousworkinstanceexternalid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare

tempworkerarray bigint[];
templocationarray bigint[];
tempcustomerarray text[];
tempworkinstance text[];
tempstardate timestamp with time zone;
tempenddate timestamp with time zone;

BEGIN

/*

-- future add in language type (For now hardoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_readrtls(null,null,null, null,null,null, null)

-- send in an array of customeruuids
select * from public.func_readrtls(null,null,null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,null, null)

-- send in an array of locationuuids
select * from public.func_readrtls(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_readrtls(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_readrtls('10/27/2024',null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_readrtls(null,'10/27/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_readrtls('10/27/2024','10/28/2024',null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in originationid
select * from public.func_readrtls(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null,ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in workinstances
select * from public.func_readrtls(null,null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_readrtls(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- group by originationid
select wi.workinstancecustomerid,wi.workinstanceworktemplateid,wi.workinstancesiteid, wi.workinstanceoriginatorworkinstanceid,wi.workinstancetimezone, min(wi.workinstancestartdate), max(wi.workinstancestartdate), count(*)
from public.func_readrtls(null,null,ARRAY[2079961],ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18']) as wi
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

if (read_locationuuidarray isNull or array_length(read_locationuuidarray, 1) = 0)
	then templocationarray = ARRAY(
		select loc.locationid::text from location loc
		where loc.locationcustomerid in (select customerid from customer
									where customeruuid = any (tempcustomerarray))); -- replace this with a call to get all rtls locations for the customers
	else templocationarray = ARRAY(
		select lo2.locationid::text from location lo2
		where lo2.locationuuid = any (read_locationuuidarray));
End if;

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

if (read_originationidarray isNull or array_length(read_originationidarray, 1) = 0)
		and (read_workinstanceuuidarray isNull or array_length(read_workinstanceuuidarray, 1) = 0)
	then tempworkinstance = Array
		(select id
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
						and wi.workinstancecompleteddate < tempenddate);
elseif(read_originationidarray isNull or array_length(read_originationidarray, 1) > 0)
	then tempworkinstance = ARRAY(select wi2.id
									from workinstance wi2
									where wi2.workinstanceoriginatorworkinstanceid = any(read_originationidarray));
end if;

return query
	select
		wi.workinstanceid,
		wi.id as workinstanceuuid,
		wi.workinstancecustomerid,
		wi.workinstanceworktemplateid,
		wi.workinstancesiteid,
		wi.workinstancepreviousid,
		wi.workinstanceoriginatorworkinstanceid,
		wi.workinstancestartdate,
		wi.workinstancecompleteddate,
		wi.workinstanceexternalid,
		wi.workinstancetimezone,
		wril.workresultinstancevalue::bigint as locationid,
		wriw.workresultinstancevalue::bigint as workerinstanceid,
		worker_instance.workerinstanceuuid,
		wrilat.workresultinstancevalue::numeric as latitude,
		wrilon.workresultinstancevalue::numeric as longitude,
		wrirtls.workresultinstancevalue::text as onlinestatus,
		wriaccuracy.workresultinstancevalue::numeric as accuracy,
		wrialtitude.workresultinstancevalue::numeric as altitude,
		wrialtitudeaccuracy.workresultinstancevalue::numeric as altaccuracy,
		wriheading.workresultinstancevalue::numeric as heading,
		wrispeed.workresultinstancevalue::numeric as speed,
		pwi.workinstanceexternalid
	FROM workinstance wi
		JOIN (select *   -- get primary location
				from public.func_read_workresultinstancevalues_bigint(tempworkinstance, null,'Location',true )) wril
			ON wi.workinstanceid = wril.workresultinstanceworkinstanceid
				and wril.workresultinstancevalue = any (templocationarray)
		LEFT JOIN (select *   -- get primary worker
				from public.func_read_workresultinstancevalues_bigint(tempworkinstance,null,'Worker',true )) wriw
			ON wi.workinstanceid = wriw.workresultinstanceworkinstanceid
				and wriw.workresultinstancevalue = any (tempworkerarray)
		inner join (select *   -- get latitude
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Latitude',false )) wrilat
			ON wi.workinstanceid = wrilat.workresultinstanceworkinstanceid
		inner join (select *   -- get longitude
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Longitude',false )) wrilon
			ON wi.workinstanceid = wrilon.workresultinstanceworkinstanceid
		inner join (select *
						from public.func_read_workresultinstancevalues_text(tempworkinstance, null,
								'RTLS - Online Status', '7ebd10ee-5018-4e11-9525-80ab5c6aebee',false)) wrirtls
			ON wi.workinstanceid = wrirtls.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsaccuracy
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Accuracy',false )) wriaccuracy
			ON wi.workinstanceid = wriaccuracy.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsaltitude
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Altitude',false )) wrialtitude
			ON wi.workinstanceid = wrialtitude.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsaltitudeaccuracy
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Altitude Accuracy',false )) wrialtitudeaccuracy
			ON wi.workinstanceid = wrialtitudeaccuracy.workresultinstanceworkinstanceid
		inner join (select *   -- get fact_rtlsheading
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Heading',false )) wriheading
			ON wi.workinstanceid = wriheading.workresultinstanceworkinstanceid
		inner join (select *   -- get rtlsspeed
				from public.func_read_workresultinstancevalues_numeric(tempworkinstance,null,'RTLS - Speed',false )) wrispeed
			ON wi.workinstanceid = wrispeed.workresultinstanceworkinstanceid
        left join workinstance pwi
            ON pwi.workinstanceid = wi.workinstancepreviousid
		inner join workerinstance worker_instance
			ON worker_instance.workerinstanceid = wriw.workresultinstancevalue
	where wriw.workresultinstancevalue = any (tempworkerarray)
	order by wi.workinstanceid
	;

End;
$function$;


REVOKE ALL ON FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_readrtls(timestamp with time zone,timestamp with time zone,bigint[],text[],text[],text[],text[]) TO tendreladmin WITH GRANT OPTION;

END;

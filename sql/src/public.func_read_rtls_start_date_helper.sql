
-- Type: FUNCTION ; Name: func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]); Owner: bombadil

CREATE OR REPLACE FUNCTION public.func_read_rtls_start_date_helper(read_enddate timestamp with time zone, read_customeruuidarray text[], read_locationuuidarray text[], read_workerinstanceuuidarray text[])
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

-- future add in language type (For now hardcoded to english)
-- future move this to entity
-- might need to add site to the call.  Right now it does not respect site.

-- get all
select * from public.func_read_rtls_last_known_location(null,null,null, null)

-- send in an array of customeruuids
select * from public.func_read_rtls_last_known_location(null, ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],null, null)

-- send in an array of locationuuids
select * from public.func_read_rtls_last_known_location(null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], null)

-- send in and array of workerinstanceuuids
select * from public.func_read_rtls_last_known_location(null,null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

-- send in dates
select * from public.func_read_rtls_last_known_location(null,ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])
select * from public.func_read_rtls_last_known_location('11/1/2024',ARRAY['customer_540281d1-163e-491d-86b0-b3d6b2a66278'],ARRAY['location_d6513ed1-6902-4db4-ade8-3f4af7526715'], ARRAY['worker-instance_777aaca3-28e3-4968-a5ee-d4285422ca18'])

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

tempenddate =
	case
		when read_enddate isnull
			then clock_timestamp()
		else read_enddate
	end;

tempstardate = tempenddate - interval '4 days';

return query
select fullrecords.*
from (select wri.workresultinstancevalue as maxworkerid, min(wi.workinstancecompleteddate) as maxdate
		from worktemplate wt
			inner join worktemplatetype wtt
				on wtt.worktemplatetypeworktemplateuuid = id
					and wtt.worktemplatetypecustomeruuid = any (tempcustomerarray)
					and wtt.worktemplatetypesystaguuid = 'f0d0bca1-827a-46da-80bc-af1c8ef914db'
			inner join workresult wr
				on wt.worktemplateid = wr.workresultworktemplateid
					AND wr.workresulttypeid = 848
					AND wr.workresultentitytypeid = 850
					AND wr.workresultisprimary = true
			inner join workinstance wi
				on wt.worktemplateid = wi.workinstanceworktemplateid
					and wi.workinstancestartdate > tempstardate
					and wi.workinstancecompleteddate < tempenddate
			inner join workresultinstance wri
				on wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = wr.workresultid
					and wri.workresultinstancevalue notNull
		group by wri.workresultinstancevalue) maxrecords
	inner join (select * from public.func_readrtls(tempstardate, tempenddate, null, tempcustomerarray, null, read_locationuuidarray, read_workerinstanceuuidarray)) fullrecords
				on maxworkerid::bigint = fullrecords.workerinstanceid
					and maxdate = fullrecords.workinstancecompleteddate;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_rtls_start_date_helper(timestamp with time zone,text[],text[],text[]) TO bombadil WITH GRANT OPTION;

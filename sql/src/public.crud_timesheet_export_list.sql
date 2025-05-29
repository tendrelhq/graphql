BEGIN;

/*
DROP FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint);
*/


-- Type: FUNCTION ; Name: crud_timesheet_export_list(timestamp with time zone,boolean,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_timesheet_export_list(read_date timestamp with time zone, isenddate boolean, read_customer_id bigint)
 RETURNS TABLE(worker_name text, worker_scanid text, day1_start_date date, day1_clock_start_time timestamp without time zone, day1_break_start_time timestamp without time zone, day1_break_end_time timestamp without time zone, day1_clock_end_time timestamp without time zone, day1_paid_hours numeric, day2_start_date date, day2_clock_start_time timestamp without time zone, day2_break_start_time timestamp without time zone, day2_break_end_time timestamp without time zone, day2_clock_end_time timestamp without time zone, day2_paid_hours numeric, day3_start_date date, day3_clock_start_time timestamp without time zone, day3_break_start_time timestamp without time zone, day3_break_end_time timestamp without time zone, day3_clock_end_time timestamp without time zone, day3_paid_hours numeric, day4_start_date date, day4_clock_start_time timestamp without time zone, day4_break_start_time timestamp without time zone, day4_break_end_time timestamp without time zone, day4_clock_end_time timestamp without time zone, day4_paid_hours numeric, day5_start_date date, day5_clock_start_time timestamp without time zone, day5_break_start_time timestamp without time zone, day5_break_end_time timestamp without time zone, day5_clock_end_time timestamp without time zone, day5_paid_hours numeric, day6_start_date date, day6_clock_start_time timestamp without time zone, day6_break_start_time timestamp without time zone, day6_break_end_time timestamp without time zone, day6_clock_end_time timestamp without time zone, day6_paid_hours numeric, day7_start_date date, day7_clock_start_time timestamp without time zone, day7_break_start_time timestamp without time zone, day7_break_end_time timestamp without time zone, day7_clock_end_time timestamp without time zone, day7_paid_hours numeric)
 LANGUAGE plpgsql
AS $function$

DECLARE
	min_date date;
	max_date date;

BEGIN

-- select * from public.crud_timesheet_export_list('01/06/2025',true,57)
-- select * from public.crud_timesheet_export_list('01/06/2025',false,57)

if isenddate = false
	then
		min_date = read_date;
		max_date = read_date + interval '6 days';
	else
		min_date = read_date - interval '6 days';	
		max_date = read_date;		
end if;


create temp table onerow as 
	(SELECT 	
		clock.worker_name,
		clock.worker_scanid,
		clock.worker_id,		
		clock.start_date,
		clock.start_time as clock_start_time,
		break.start_time as break_start_time,
		clock.end_time as clock_end_time,
		break.end_time as break_end_time,
	   EXTRACT(epoch FROM ((clock.end_time - clock.start_time) - (break.end_time -  break.start_time)))/3600 as paid_hours--,
	FROM (
		SELECT worker.dim_workerfullname AS worker_name,
			worker.dim_workerinstancescanid AS worker_scanid,
			worker.dim_workerinstanceid AS worker_id,
			wtt.dim_worktemplatetypename AS template_type,
			case 
				when wriesd.workresultinstancevalue isNull
					then  wi.workinstancestartdatetz::date
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)::date
			end AS start_date,
			case 
				when wriesd.workresultinstancevalue isNull
					then  wi.workinstancestartdatetz
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)
			end AS start_time,
			case 
				when wrieed.workresultinstancevalue isNull
					then  wi.workinstancecompleteddatetz
				else (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
					 AT TIME ZONE wi.workinstancetimezone)
			end AS end_time,
			wi.workinstancetimezone                   AS site_timezone
		FROM public.workinstance AS wi -- public.view_workinstance_full_v2 AS wi
			INNER JOIN datawarehouse.dim_worktemplate_v2 wt
				ON wi.workinstanceworktemplateid = wt.dim_worktemplateid
					AND workinstancecustomerid = read_customer_id
					AND workinstancestatusid IN (707, 710)
					AND wi.workinstancestartdatetz >=
					  min_date::date - INTERVAL '14 day' -- whatever stardate is minus 7 days.
			INNER JOIN datawarehouse.dim_worktemplatetype wtt
				ON wt.dim_dimworktemplatetypeid = wtt.dim_dimworktemplatetypeid
					AND wtt.dim_worktemplatetypeid IN (883)
			LEFT JOIN public.workresultinstance wriesd
				ON wriesd.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriesd.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Start Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			INNER JOIN datawarehouse.dim_statustype_v2 AS st
				ON wi.workinstancestatusid = st.dim_statustypeid
					AND ((wi.workinstancestartdatetz >= min_date::date
							AND wi.workinstancestartdatetz <= max_date::date
							AND wriesd.workresultinstancevalue ISNULL)
						OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) >= min_date::date)
						AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) <= max_date::date
						OR (wi.workinstancestatusid = 707
							AND ((wi.workinstancestartdatetz <= max_date::date
								AND wriesd.workresultinstancevalue ISNULL)
								OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
									AT TIME ZONE wi.workinstancetimezone) <= max_date::date))))
			LEFT JOIN PUBLIC.workresultinstance wrieed
				ON wrieed.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrieed.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'End Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			INNER JOIN datawarehouse.dim_trustreasontype_v2 AS tr
				ON wi.workinstancetrustreasoncodeid = tr.dim_trustreasontypeid
			INNER JOIN PUBLIC.workresultinstance wris
				ON wris.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wris.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'Start Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN PUBLIC.workresultinstance wrie
				ON wrie.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrie.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'End Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN datawarehouse.dim_location_v2 AS loce
				ON wrie.workresultinstancevalue::BIGINT = loce.dim_locationid
			INNER JOIN PUBLIC.workresultinstance wriw
				ON wriw.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriw.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Worker'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid
							AND dim_workresultisprimary = FALSE)
			INNER JOIN datawarehouse.dim_worker_v2 worker
			  	ON wriw.workresultinstancevalue::BIGINT = worker.dim_workerinstanceid) AS clock
	left join (
		SELECT 
			worker.dim_workerfullname AS worker_name,
			worker.dim_workerinstancescanid AS worker_scanid,
			worker.dim_workerinstanceid AS worker_id,
			wtt.dim_worktemplatetypename AS template_type,
			case 
				when wriesd.workresultinstancevalue isNull
					then wi.workinstancestartdatetz::date
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
					AT TIME ZONE wi.workinstancetimezone)::date
			end AS start_date,
			case 
				when wriesd.workresultinstancevalue isNull
					then  wi.workinstancestartdatetz
				else (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)
			end AS start_time,
			case 
				when wrieed.workresultinstancevalue isNull
					then wi.workinstancecompleteddatetz
				else (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
			 		AT TIME ZONE wi.workinstancetimezone)
				end AS end_time,
			wi.workinstancetimezone                   AS site_timezone
		FROM public.workinstance wi
			INNER JOIN datawarehouse.dim_worktemplate_v2 wt
				ON wi.workinstanceworktemplateid = wt.dim_worktemplateid
					AND workinstancecustomerid = read_customer_id
					AND workinstancestatusid IN (707, 710)
					AND wi.workinstancestartdatetz >=
						min_date::date - INTERVAL '14 day' -- whatever stardate is minus 7 days.
			INNER JOIN datawarehouse.dim_worktemplatetype wtt
				ON wt.dim_dimworktemplatetypeid = wtt.dim_dimworktemplatetypeid
					AND wtt.dim_worktemplatetypeid IN (884)
			LEFT JOIN public.workresultinstance wriesd
				ON wriesd.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriesd.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Start Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
						INNER JOIN datawarehouse.dim_statustype_v2 AS st
				ON wi.workinstancestatusid = st.dim_statustypeid
					AND ((wi.workinstancestartdatetz >= min_date::date
							AND wi.workinstancestartdatetz <= max_date::date
							AND wriesd.workresultinstancevalue ISNULL)
						OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) >= min_date::date)
						AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
							AT TIME ZONE wi.workinstancetimezone) <= max_date::date
						OR (wi.workinstancestatusid = 707
							AND ((wi.workinstancestartdatetz <= max_date::date
								AND wriesd.workresultinstancevalue ISNULL)
								OR ((TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
									AT TIME ZONE wi.workinstancetimezone) <= max_date::date))))
			LEFT JOIN PUBLIC.workresultinstance wrieed
				ON wrieed.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrieed.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'End Override'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			INNER JOIN datawarehouse.dim_trustreasontype_v2 AS tr
				ON wi.workinstancetrustreasoncodeid = tr.dim_trustreasontypeid
			INNER JOIN PUBLIC.workresultinstance wris
				ON wris.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wris.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'Start Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN PUBLIC.workresultinstance wrie
				ON wrie.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wrie.workresultinstanceworkresultid IN
						(SELECT dimwr.dim_workresultid
						FROM datawarehouse.dim_workresult_v2 dimwr
						WHERE dim_workresultname = 'End Location'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
			LEFT JOIN datawarehouse.dim_location_v2 AS loce
				ON wrie.workresultinstancevalue::BIGINT = loce.dim_locationid
			INNER JOIN PUBLIC.workresultinstance wriw
				ON wriw.workresultinstanceworkinstanceid = wi.workinstanceid
					AND wriw.workresultinstanceworkresultid IN
						(SELECT dim_workresultid
						FROM datawarehouse.dim_workresult_v2
						WHERE dim_workresultname = 'Worker'
							AND dim_dimworktemplateid = wt.dim_dimworktemplateid
							AND dim_workresultisprimary = FALSE)
			INNER JOIN datawarehouse.dim_worker_v2 worker
			  	ON wriw.workresultinstancevalue::BIGINT = worker.dim_workerinstanceid) AS break
		on clock.worker_id = break.worker_id
			and clock.start_date = break.start_date
	ORDER BY clock_start_time);

create temp table workerlist as 
	(select 
		orow.worker_name,
		orow.worker_scanid,
		orow.worker_id
	from onerow orow
	group by orow.worker_name,	orow.worker_scanid, orow.worker_id);

RETURN QUERY 
	select 
		wl.worker_name,
		wl.worker_scanid,
		min_date as day1_start_date,
		day1.clock_start_time as day1_clock_start_time,
		day1.break_start_time as day1_break_start_time,
		day1.clock_end_time as day1_clock_end_time,
		day1.break_end_time as day1_break_end_time,
		day1.paid_hours as day1_paid_hours,
		(min_date + interval '1 day')::date as day2_start_date,
		day2.clock_start_time as day2_clock_start_time,
		day2.break_start_time as day2_break_start_time,
		day2.clock_end_time as day2_clock_end_time,
		day2.break_end_time as day2_break_end_time,
		day2.paid_hours as day2_paid_hours,
		(min_date + interval '2 day')::date as day3_start_date,
		day3.clock_start_time as day3_clock_start_time,
		day3.break_start_time as day3_break_start_time,
		day3.clock_end_time as day3_clock_end_time,
		day3.break_end_time as day3_break_end_time,
		day3.paid_hours as day3_paid_hours,
		(min_date + interval '3 day')::date as day4_start_date,
		day4.clock_start_time as day4_clock_start_time,
		day4.break_start_time as day4_break_start_time,
		day4.clock_end_time as day4_clock_end_time,
		day4.break_end_time as day4_break_end_time,
		day4.paid_hours as day4_paid_hours,
		(min_date + interval '4 day')::date as day5_start_date,
		day5.clock_start_time as day5_clock_start_time,
		day5.break_start_time as day5_break_start_time,
		day5.clock_end_time as day5_clock_end_time,
		day5.break_end_time as day5_break_end_time,
		day5.paid_hours as day5_paid_hours,
		(min_date + interval '5 day')::date  as day6_start_date,
		day6.clock_start_time as day6_clock_start_time,
		day6.break_start_time as day6_break_start_time,
		day6.clock_end_time as day6_clock_end_time,
		day6.break_end_time as day6_break_end_time,
		day6.paid_hours as day6_paid_hours,
		(min_date + interval '6 day')::date  as day7_start_date,
		day7.clock_start_time as day7_clock_start_time,
		day7.break_start_time as day7_break_start_time,
		day7.clock_end_time as day7_clock_end_time,
		day7.break_end_time as day7_break_end_time,
		day7.paid_hours as day7_paid_hours
	from workerlist wl
		left join onerow day1
			on wl.worker_id = day1.worker_id
				and day1.start_date::date = min_date
		left join onerow day2
			on wl.worker_id = day2.worker_id
				and day2.start_date = min_date + interval '1 day'
		left join onerow day3
			on wl.worker_id = day3.worker_id
				and day3.start_date = min_date + interval '2 day'
		left join onerow day4
			on wl.worker_id = day4.worker_id
				and day4.start_date = min_date + interval '3 day'
		left join onerow day5
			on wl.worker_id = day5.worker_id
				and day5.start_date = min_date + interval '4 day'
		left join onerow day6
			on wl.worker_id = day6.worker_id
				and day6.start_date = min_date + interval '5 day'
		left join onerow day7
			on wl.worker_id = day7.worker_id
				and day7.start_date = min_date + interval '6 day'
	order by wl.worker_name, wl.worker_scanid;

drop table onerow;
drop table workerlist;

END;

$function$;


REVOKE ALL ON FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_export_list(timestamp with time zone,boolean,bigint) TO tendreladmin WITH GRANT OPTION;

END;

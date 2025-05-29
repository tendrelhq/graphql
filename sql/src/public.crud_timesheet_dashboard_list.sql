BEGIN;

/*
DROP FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint);
*/


-- Type: FUNCTION ; Name: crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_timesheet_dashboard_list(min_date timestamp with time zone, max_date timestamp with time zone, read_customer_id bigint)
 RETURNS TABLE(worker_name text, worker_first_name text, worker_last_name text, worker_scanid text, worker_id bigint, workinstance_uuid text, template_type text, trust_reason text, start_time timestamp without time zone, start_location_name text, start_override timestamp without time zone, start_override_by text, end_time timestamp without time zone, end_location_name text, end_override timestamp without time zone, end_override_by text, start_display timestamp without time zone, end_display timestamp without time zone, site_timezone text)
 LANGUAGE plpgsql
AS $function$

DECLARE

    maxdate timestamp WITH TIME ZONE;

BEGIN

    --maxdate = (select max(workinstancemodifieddate)
--			from workinstance
--			where workinstancecustomerid = 57); --read_customer_id;

--if (maxdate > now() - interval '1000 minutes')
--	then
    RETURN QUERY
        SELECT foo.worker_name,
               foo.worker_first_name,
               foo.worker_last_name,
               foo.worker_scanid,
               foo.worker_id,
               foo.workinstance_uuid,
               foo.template_type,
               foo.trust_reason,
               foo.start_time,
               foo.start_location_name,
               foo.start_override,
               foo.start_override_by,
               foo.end_time,
               foo.end_location_name,
               foo.end_override,
               foo.end_override_by,
               CASE
                   WHEN foo.start_override IS NULL THEN foo.start_time
                   ELSE foo.start_override
                   END AS start_display,
               CASE
                   WHEN foo.end_override IS NULL THEN foo.end_time
                   ELSE foo.end_override
                   END AS end_display,
               foo.site_timezone
        FROM (SELECT worker.dim_workerfullname                 AS worker_name,
                     worker.dim_workerfirstname                AS worker_first_name,
                     worker.dim_workerlastname                 AS worker_last_name,
                     worker.dim_workerinstancescanid           AS worker_scanid,
                     worker.dim_workerinstanceid               AS worker_id,
                     wi.id                                     AS workinstance_uuid,
                     wtt.dim_worktemplatetypename              AS template_type,
                     tr.dim_trustreasontypename                AS trust_reason,
                     wi.workinstancestartdatetz                AS start_time,
                     locs.dim_locationname                     AS start_location_name, -- added
                     (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                         AT TIME ZONE wi.workinstancetimezone) AS start_override,
                     workerexception.dim_workerfullname        AS start_override_by,
                     wi.workinstancecompleteddatetz            AS end_time,
                     locs.dim_locationname                     AS end_location_name,   -- added
                     (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                         AT TIME ZONE wi.workinstancetimezone) AS end_override,
                     workerexception.dim_workerfullname        AS end_override_by,
                     wi.workinstancetimezone                   AS site_timezone
              FROM public.workinstance AS wi -- public.view_workinstance_full_v2 AS wi
                       INNER JOIN datawarehouse.dim_worktemplate_v2 wt
                                  ON wi.workinstanceworktemplateid = wt.dim_worktemplateid
                                      AND workinstancecustomerid = read_customer_id
                                      AND workinstancestatusid IN (707, 710)
                                      AND wi.workinstancestartdatetz >=
                                          min_date - INTERVAL '14 day' -- whatever stardate is minus 7 days.
--						and (wi.workinstancecompleteddatetz <= max_date + interval '7 day'  -- whatever stardate is minus 7 days.
--								or wi.workinstancecompleteddatetz isNull)
                       INNER JOIN datawarehouse.dim_worktemplatetype wtt
                                  ON wt.dim_dimworktemplatetypeid = wtt.dim_dimworktemplatetypeid
                                      AND wtt.dim_worktemplatetypeid IN (883, 884)
                       LEFT JOIN public.workresultinstance wriesd
                                 ON wriesd.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wriesd.workresultinstanceworkresultid IN
                                         (SELECT dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2
                                          WHERE dim_workresultname = 'Start Override'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       LEFT JOIN PUBLIC.workresultinstance wrieed
                                 ON wrieed.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wrieed.workresultinstanceworkresultid IN
                                         (SELECT dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2
                                          WHERE dim_workresultname = 'End Override'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       INNER JOIN datawarehouse.dim_statustype_v2 AS st
                                  ON wi.workinstancestatusid = st.dim_statustypeid
                                      AND (
                                         -- Case 1: Entry starts within the date range
                                         -- for all of these, we trust the override time if it exists.
                                         (
                                             (wi.workinstancestartdatetz >= min_date::date
                                                 AND wi.workinstancestartdatetz <= max_date::date
                                                 AND wriesd.workresultinstancevalue IS NULL)
                                                 OR
                                             (wriesd.workresultinstancevalue IS NOT NULL
                                                 AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) >= min_date::date
                                                 AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) <= max_date::date)
                                             )
                                             OR
                                             -- Case 2: Entry ends within the date range
                                         (
                                             (wi.workinstancecompleteddatetz >= min_date::date
                                                 AND wi.workinstancecompleteddatetz <= max_date::date
                                                 AND wrieed.workresultinstancevalue ISNULL)
                                                 OR
                                             (wrieed.workresultinstancevalue IS NOT NULL
                                                 AND (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) >= min_date::date
                                                 AND (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                                                     AT TIME ZONE wi.workinstancetimezone) <= max_date::date)
                                             )
                                             OR
                                             -- Case 3: Entry spans the entire date range
                                         (
                                             (
                                                 (wi.workinstancestartdatetz <= min_date::date
                                                     AND wriesd.workresultinstancevalue ISNULL)
                                                     OR
                                                 (wriesd.workresultinstancevalue IS NOT NULL
                                                     AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                         AT TIME ZONE wi.workinstancetimezone) <= min_date::date)
                                                 )
                                                 AND
                                             (
                                                 (wi.workinstancecompleteddatetz >= max_date::date
                                                     AND wrieed.workresultinstancevalue ISNULL)
                                                     OR
                                                 wi.workinstancecompleteddatetz IS NULL
                                                     OR
                                                 (wrieed.workresultinstancevalue IS NOT NULL
                                                     AND (TO_TIMESTAMP(wrieed.workresultinstancevalue::bigint / 1000)
                                                         AT TIME ZONE wi.workinstancetimezone) >= max_date::date)
                                                 )
                                             )
                                             OR
                                             -- Case 4: Entry is in progress (started before max_date)
                                         (
                                             wi.workinstancestatusid = 707
                                                 AND
                                             (
                                                 (wi.workinstancestartdatetz <= max_date::date
                                                     AND wriesd.workresultinstancevalue ISNULL)
                                                     OR
                                                 (wriesd.workresultinstancevalue IS NOT NULL
                                                     AND (TO_TIMESTAMP(wriesd.workresultinstancevalue::bigint / 1000)
                                                         AT TIME ZONE wi.workinstancetimezone) <= max_date::date)
                                                 )
                                             )
                                         )

                       INNER JOIN datawarehouse.dim_trustreasontype_v2 AS tr
                                  ON wi.workinstancetrustreasoncodeid = tr.dim_trustreasontypeid
                  --                                       AND (wi.workinstancecompleteddatetz ISNULL
--                                           OR ((wi.workinstancecompleteddatetz <= (max_date)::DATE
--                                               AND wrieed.workresultinstancevalue ISNULL)
--                                               OR ((TO_TIMESTAMP(wrieed.workresultinstancevalue::BIGINT / 1000)
--                                                   AT TIME ZONE wi.workinstancetimezone) <= (max_date)::DATE)))
                       INNER JOIN PUBLIC.workresultinstance wris
                                  ON wris.workresultinstanceworkinstanceid = wi.workinstanceid
                                      AND wris.workresultinstanceworkresultid IN
                                          (SELECT dimwr.dim_workresultid
                                           FROM datawarehouse.dim_workresult_v2 dimwr
                                           WHERE dim_workresultname = 'Start Location'
                                             AND dim_dimworktemplateid = wt.dim_dimworktemplateid)
                       INNER JOIN datawarehouse.dim_location_v2 AS locs
                                  ON wris.workresultinstancevalue::BIGINT = locs.dim_locationid
                       INNER JOIN PUBLIC.location locs2
                                  ON locs2.locationid = locs.dim_locationid
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
                                  ON wriw.workresultinstancevalue::BIGINT = worker.dim_workerinstanceid
                       LEFT JOIN PUBLIC.workresultinstance wriwe
                                 ON wriwe.workresultinstanceworkinstanceid = wi.workinstanceid
                                     AND wriwe.workresultinstanceworkresultid IN
                                         (SELECT dimwr.dim_workresultid
                                          FROM datawarehouse.dim_workresult_v2 dimwr
                                          WHERE dim_workresultname = 'Override By'
                                            AND dim_dimworktemplateid = wt.dim_dimworktemplateid
                                            AND dim_workresultisprimary = FALSE)
                       LEFT JOIN datawarehouse.dim_worker_v2 workerexception
                                 ON wriwe.workresultinstancevalue::BIGINT = workerexception.dim_workerinstanceid) AS foo
        ORDER BY start_time;

END;

$function$;


REVOKE ALL ON FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list(timestamp with time zone,timestamp with time zone,bigint) TO tendreladmin WITH GRANT OPTION;

END;

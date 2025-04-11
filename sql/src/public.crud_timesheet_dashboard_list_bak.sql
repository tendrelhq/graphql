
-- Type: FUNCTION ; Name: crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION public.crud_timesheet_dashboard_list_bak(min_date timestamp with time zone, max_date timestamp with time zone, customer_id bigint)
 RETURNS TABLE(worker_name text, worker_first_name text, worker_last_name text, worker_scanid text, worker_id bigint, workinstance_uuid text, template_type text, trust_reason text, start_time timestamp without time zone, start_location_name text, start_override timestamp without time zone, start_override_by text, end_time timestamp without time zone, end_location_name text, end_override timestamp without time zone, end_override_by text, start_display timestamp without time zone, end_display timestamp without time zone, site_timezone text)
 LANGUAGE sql
AS $function$

SELECT worker.dim_workerfullname                   AS worker_name,
       worker.dim_workerfirstname                  AS worker_first_name,
       worker.dim_workerlastname                   AS worker_last_name,
       worker.dim_workerinstancescanid             AS worker_scanid,
       worker.dim_workerinstanceid                 AS worker_id,
       w.id                                        AS workinstance_uuid,
       s.systagtype                                AS template_type,
       trusttype.dim_trustreasontypename           AS trust_reason,
       wts.fact_workinstancestartdate              AS start_time,
       loc.dim_locationname                        AS start_location_name,
       wts.fact_workinstanceexceptionstartdate     AS start_override,
       excworker.dim_workerfullname                AS start_override_by,
       --wts.fact_workresultexceptionstartuuid       AS start_override_result_uuid,
       wts.fact_workinstancecompleteddate          AS end_time,
       loc.dim_locationname                        AS end_location_name,
       wts.fact_workinstanceexceptioncompleteddate AS end_override,
       excworker.dim_workerfullname                AS end_override_by,
       wts.fact_workinstancedisplaystartdate       AS start_display,
       wts.fact_workinstancedisplaycompleteddate   AS end_display,
       loc.dim_locationtimezone                    AS site_timezone
--wts.fact_workresultexceptionenduuid         AS end_override_result_uuid
FROM datawarehouse.fact_timesheet wts
         JOIN datawarehouse.dim_customer_v2 cust
              ON wts.dim_dimcustomerid = cust.dim_dimcustomerid
                  AND cust.dim_customerid = customer_id
         INNER JOIN workinstance w
                    ON wts.fact_workinstanceid = w.workinstanceid
                        AND w.workinstancestatusid != 711
         JOIN worktemplate wt ON w.workinstanceworktemplateid = wt.worktemplateid
         JOIN worktemplatetype wtt ON wt.id = wtt.worktemplatetypeworktemplateuuid
         JOIN systag s ON wtt.worktemplatetypesystaguuid = s.systaguuid
         JOIN datawarehouse.dim_location_v2 loc
              ON wts.dim_dimlocationid = loc.dim_dimlocationid
         JOIN datawarehouse.dim_worker_v2 worker
              ON wts.dim_dimworkerid = worker.dim_dimworkerid
         LEFT JOIN datawarehouse.dim_worker_v2 excworker
                   ON wts.dim_dimworkerexceptionid = excworker.dim_dimworkerid
         JOIN datawarehouse.dim_trustreasontype_v2 trusttype
              ON wts.dim_dimtrustreasontypeid = trusttype.dim_dimtrustreasontypeid

WHERE (
          (wts.fact_workinstancedisplaystartdate >= min_date::date
              AND wts.fact_workinstancedisplaystartdate <= max_date::date)
              OR
          (w.workinstancestatusid = 707 -- grab "In Progress" work that was started before the max time
              AND wts.fact_workinstancestartdate <= max_date::date)
          )
ORDER BY wts.fact_workinstancedisplaystartdate;
$function$;


REVOKE ALL ON FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_timesheet_dashboard_list_bak(timestamp with time zone,timestamp with time zone,bigint) TO bombadil WITH GRANT OPTION;

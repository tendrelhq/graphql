
-- Type: FUNCTION ; Name: superset_timesheet_missingclockin(text,integer,date); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.superset_timesheet_missingclockin(read_customeruuid text, read_days integer, reference_day date)
 RETURNS TABLE(workerinstanceid bigint, workerusername text, workerfullname text, workerfirstname text, workerlastname text, workerinstancescanid text, workerinstancestartdate timestamp with time zone, workerinstanceenddate timestamp with time zone, workerinstancecountit boolean, workerinstancetendreluser boolean, workerlastclockin date, sitename text, customer text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
    tempcustomerid bigint;
    temptimezone   text;
    tempdate       date;
	temptimestamp timestamp with time zone;

BEGIN

    tempcustomerid = (select cu.customerid
                      from public.customer cu
                      where read_customeruuid = cu.customeruuid);

    temptimezone = (select distinct dim_sitetimezone
                    from datawarehouse.fact_timesheet ts
                             inner join datawarehouse.dim_site_v2 site
                                        on site.dim_dimsiteid = ts.dim_dimsiteid
                    where fact_customerid = tempcustomerid
                      and fact_workinstancedisplaystartdate > now() - ('14 days')::interval);

    tempdate = case
                   when reference_day notNull
                       then reference_day
                   else (now() AT TIME ZONE temptimezone)::date
        end;

	temptimestamp = case
                   when reference_day notNull
                       then reference_day
                   else (now() AT TIME ZONE temptimezone)
       	 end;

    return query select worker.dim_workerinstanceid                         AS workerinstanceid,
                        worker.dim_workerusername                           AS workerusername,
                        worker.dim_workerfullname                           AS workerfullname,
                        worker.dim_workerfirstname                          AS workerfirstname,
                        worker.dim_workerlastname                           AS workerlastname,
                        worker.dim_workerinstancescanid                     AS workerinstancescanid,
                        worker.dim_workerinstancestartdate                  AS workerinstancestartdate,
                        worker.dim_workerinstanceenddate                    AS workerinstanceenddate,
                        worker.dim_workerinstancecountit                    AS workerinstancecountit,
                        worker.dim_workerinstancetendreluser                AS workerinstancetendreluser,
                        lastworkers.fact_workinstancedisplaystartdate ::Date as workerlastclockin,
                        lastworkers.dim_sitename                            as sitename,
                        lastworkers.dim_customername                        as customer
                 from ( select
							fact_workerinstanceid,
							dim_sitename,
							dim_sitetimezone,
							dim_customername,
							max(fact_workinstancedisplaystartdate) as fact_workinstancedisplaystartdate
						from
							(select wri.workresultinstancevalue as fact_workerinstanceid,
								   dim_sitename,
								   dim_sitetimezone,
								   dim_customername,
								   case when foo.workresultinstancevalue isNull
								   			then (workinstancestartdatetz)
										else (TO_TIMESTAMP(foo.workresultinstancevalue / 1000) AT TIME ZONE owi.workinstancetimezone)
									End as fact_workinstancedisplaystartdate
							from workinstance AS owi
		                       INNER JOIN worktemplatetype wtt
                                  ON owi.workinstanceworktemplateid = wtt.worktemplatetypeworktemplateid
                                      AND wtt.worktemplatetypesystagid IN (883, 884)
										and owi.workinstancecustomerid = tempcustomerid
										and owi.workinstancestartdatetz::date > tempdate - ('14 days')::interval
										-- and owi.workinstancestartdatetz::date <= tempdate
										and owi.workinstancestatusid in (707, 710)
								 inner join datawarehouse.dim_site_v2 site
									on site.dim_siteid = owi.workinstancesiteid
								 inner join datawarehouse.dim_customer_v2 cust
									on cust.dim_customerid = owi.workinstancecustomerid
								 inner join workresultinstance wri
									on owi.workinstanceid = wri.workresultinstanceworkinstanceid
								inner join datawarehouse.dim_workresult_v2 wr
									on wr.dim_workresultid = wri.workresultinstanceworkresultid
										and dim_workresultname = 'Worker'
										and dim_workresultisprimary = false
								left join (select * from datawarehouse.func_timesheet_override_bigint(tempcustomerid,tempdate)) as foo
										on foo.workresultinstanceworkinstanceid =  owi.workinstanceid) as foofoo
							group by foofoo.fact_workerinstanceid, dim_sitename, dim_sitetimezone, dim_customername
								)  as lastworkers
					inner join datawarehouse.dim_worker_v2 worker
							 on lastworkers.fact_workerinstanceid::bigint = worker.dim_workerinstanceid
								 and (dim_workerinstanceenddate isNull
									 or dim_workerinstanceenddate  >= temptimestamp )
				where fact_workinstancedisplaystartdate::date <> tempdate;


End;

$function$;


REVOKE ALL ON FUNCTION superset_timesheet_missingclockin(text,integer,date) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION superset_timesheet_missingclockin(text,integer,date) TO PUBLIC;
GRANT EXECUTE ON FUNCTION superset_timesheet_missingclockin(text,integer,date) TO tendreladmin WITH GRANT OPTION;

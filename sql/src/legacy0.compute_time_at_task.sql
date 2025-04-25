
-- Type: FUNCTION ; Name: legacy0.compute_time_at_task(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.compute_time_at_task(workinstanceid bigint)
 RETURNS interval
 LANGUAGE sql
 STABLE
AS $function$
  with
      ov_start as (
          select nullif(workresultinstancevalue, '') as value
          from public.workresultinstance
          inner join public.workresult
              on workresultinstanceworkresultid = workresultid
              and workresulttypeid = 868
              and workresultorder = 0
              and workresultisprimary = true
          where workresultinstanceworkinstanceid = $1
          limit 1
      ),

      ov_end as (
          select nullif(workresultinstancevalue, '') as value
          from public.workresultinstance
          inner join public.workresult
              on workresultinstanceworkresultid = workresultid
              and workresulttypeid = 868
              and workresultorder = 1
              and workresultisprimary = true
          where workresultinstanceworkinstanceid = $1
          limit 1
      )

  select
      coalesce(to_timestamp(ov_end.value::bigint / 1000.0), workinstance.workinstancecompleteddate)
      - coalesce(to_timestamp(ov_start.value::bigint / 1000.0), workinstance.workinstancestartdate)
  from public.workinstance
  left join ov_start on true
  left join ov_end on true
  where workinstance.workinstanceid = $1;
$function$;


REVOKE ALL ON FUNCTION legacy0.compute_time_at_task(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.compute_time_at_task(bigint) TO tendrelservice;
GRANT EXECUTE ON FUNCTION legacy0.compute_time_at_task(bigint) TO graphql;

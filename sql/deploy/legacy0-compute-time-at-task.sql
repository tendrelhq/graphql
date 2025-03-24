-- Deploy graphql:legacy0-compute-time-at-task to pg

BEGIN;

-- No GRANTs required :)

-- Assumptions:
-- 1. workresulttypeid must point at 'Date' := 868
-- 2. workresultisprimary must be true
-- 3. workresultorder should be 0 for 'start' and 1 for 'end'
-- 4. workresultinstancevalues are stored in epoch millisecond form

create or replace function legacy0.compute_time_at_task(workinstanceid bigint)
returns interval
as $$
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
$$
language sql
stable;

COMMIT;

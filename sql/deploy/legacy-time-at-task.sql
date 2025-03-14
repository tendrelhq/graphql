-- Deploy graphql:legacy-time-at-task to pg

BEGIN;

-- Assumptions:
-- 1. workresulttypeid must point at 'Date' := 868
-- 2. workresultisprimary must be true
-- 3. workresultorder should be 0 for 'start' and 1 for 'end'

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
      coalesce(ov_end.value::timestamptz, workinstance.workinstancecompleteddate)
      - coalesce(ov_start.value::timestamptz, workinstance.workinstancestartdate)
  from public.workinstance
  left join ov_start on true
  left join ov_end on true
  where workinstance.workinstanceid = $1;
$$
language sql
stable;

COMMIT;

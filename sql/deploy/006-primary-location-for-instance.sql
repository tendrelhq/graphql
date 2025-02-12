-- Deploy graphql:006-primary-location-for-instance to pg
begin
;

create function legacy0.primary_location_for_instance(instance_id text)
returns table(id text, _id bigint)
as $$
  with cte as materialized (
      select workresultinstancevalue::bigint as value
      from public.workinstance
      inner join public.workresult
          on  workinstanceworktemplateid = workresultworktemplateid
          and workresulttypeid = (
              select systagid
              from public.systag
              where systagparentid = 699 and systagtype = 'Entity'
          )
          and workresultentitytypeid = (
              select systagid
              from public.systag
              where systagparentid = 849 and systagtype = 'Location'
          )
          and workresultisprimary = true
      inner join public.workresultinstance
          on  workinstanceid = workresultinstanceworkinstanceid
          and workresultid = workresultinstanceworkresultid
      where workinstance.id = instance_id
  )

  select locationuuid as id, locationid as _id
  from cte, public.location
  where cte.value = locationid
$$
language sql
stable
strict
;

commit
;

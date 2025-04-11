
-- Type: FUNCTION ; Name: legacy0.primary_location_for_instance(text); Owner: bombadil

CREATE OR REPLACE FUNCTION legacy0.primary_location_for_instance(instance_id text)
 RETURNS TABLE(id text, _id bigint)
 LANGUAGE sql
 STABLE STRICT
AS $function$
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
$function$;


REVOKE ALL ON FUNCTION legacy0.primary_location_for_instance(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.primary_location_for_instance(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.primary_location_for_instance(text) TO bombadil WITH GRANT OPTION;


-- Type: FUNCTION ; Name: engine0.task_children(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.task_children(text)
 RETURNS TABLE(id text)
 LANGUAGE sql
 STABLE
AS $function$
  with recursive cte as (
    select *
    from public.workinstance
    where workinstance.id = $1
    union all
    select child.*
    from cte, public.workinstance as child
    where cte.workinstanceid = child.workinstancepreviousid
  ) cycle id set is_cycle using path
  select cte.id
  from cte
  where not is_cycle
  order by
    workinstancestartdate,
    workinstanceid
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.task_children(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.task_children(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.task_children(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.task_children(text) TO graphql;

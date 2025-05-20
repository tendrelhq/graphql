drop function if exists engine0.task_chain;

create function engine0.task_chain(text)
returns table(id text)
as $$
  with recursive cte as (
    select *
    from public.workinstance
    where workinstance.id = $1
    union all
    select child.*
    from cte, public.workinstance as child
    where cte.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
      and cte.workinstanceid = child.workinstancepreviousid
  ) cycle id set is_cycle using path
  select cte.id
  from cte
  where not is_cycle
  order by
    workinstancestartdate,
    workinstanceid
  ;
$$
language sql
stable;

revoke all on function engine0.task_chain from public;
grant execute on function engine0.task_chain to graphql;

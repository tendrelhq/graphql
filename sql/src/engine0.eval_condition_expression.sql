
-- Type: FUNCTION ; Name: engine0.eval_condition_expression(text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.eval_condition_expression(lhs text, op text, rhs text, type text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select r.*
  from
    (select lhs::boolean, rhs::boolean) as e,
    lateral (
      select false where op = '<'
      union all
      select false where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'Boolean'
  union all
  select r.*
  from
    (
      select
        to_timestamp(lhs::bigint / 1000.0) as lhs,
        to_timestamp(rhs::bigint / 1000.0) as rhs
    ) as e,
    lateral (
      select e.lhs < e.rhs where op = '<'
      union all
      select e.lhs > e.rhs where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'Date'
  union all
  select r.*
  from
    (select lhs::numeric, rhs::numeric) as e,
    lateral (
      select e.lhs < e.rhs where op = '<'
      union all
      select e.lhs > e.rhs where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'Number'
  union all
  select r.*
  from
    (select lhs::text, rhs::text) as e,
    lateral (
      select e.lhs < e.rhs where op = '<'
      union all
      select e.lhs > e.rhs where op = '>'
      union all
      select e.lhs is not distinct from e.rhs where op = '='
      union all
      select e.lhs is distinct from e.rhs where op = '<>'
    ) as r
  where type = 'String'
$function$;


REVOKE ALL ON FUNCTION engine0.eval_condition_expression(text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_condition_expression(text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_condition_expression(text,text,text,text) TO tendreladmin WITH GRANT OPTION;

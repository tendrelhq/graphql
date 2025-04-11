
-- Type: FUNCTION ; Name: engine0.eval_field_condition(jsonb); Owner: bombadil

CREATE OR REPLACE FUNCTION engine0.eval_field_condition(ctx jsonb)
 RETURNS TABLE(ok boolean)
 LANGUAGE sql
 STABLE
AS $function$
  -- op_lhs is a workresult uuid
  -- op is a systag type
  -- op_rhs is the raw, expected value
  -- task is a workinstance uuid
  select
    coalesce(
      engine0.eval_condition_expression(
        lhs := workresultinstancevalue,
        op := args.op,
        rhs := args.op_rhs,
        type := systagtype
      ),
      false
    ) as ok
  from jsonb_to_record(ctx) as args (op_lhs text, op text, op_rhs text, task text)
  inner join public.workinstance on workinstance.id = args.task
  inner join public.workresult on workresult.id = args.op_lhs
  inner join public.systag on workresulttypeid = systagid
  inner join public.workresultinstance
    on workinstanceid = workresultinstanceworkinstanceid
    and workresultid = workresultinstanceworkresultid
  ;
$function$;


REVOKE ALL ON FUNCTION engine0.eval_field_condition(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_condition(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.eval_field_condition(jsonb) TO bombadil WITH GRANT OPTION;

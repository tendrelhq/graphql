BEGIN;

/*
DROP FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]);
*/


-- Type: FUNCTION ; Name: engine0.evaluate_instantiation_plan(text,text,engine0.closure[]); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.evaluate_instantiation_plan(target text, target_type text, conditions engine0.closure[])
 RETURNS TABLE(system regproc, result boolean)
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  x engine0.closure;
begin
  foreach x in array conditions loop
    return query 
      select x.f as system, fx.ok
      from engine0.invoke(x) as fx(ok boolean)
    ;
  end loop;

  return;
end $function$;

COMMENT ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) IS '

# engine0.evaluate_instantiation_plan

Evaluate an instantiation plan.

';

REVOKE ALL ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.evaluate_instantiation_plan(text,text,engine0.closure[]) TO graphql;

END;

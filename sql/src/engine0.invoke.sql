BEGIN;

/*
DROP FUNCTION engine0.invoke(engine0.closure);
*/


-- Type: FUNCTION ; Name: engine0.invoke(engine0.closure); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.invoke(x engine0.closure)
 RETURNS SETOF record
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query execute format('select * from %s($1)', x.f) using x.ctx;
end $function$;


REVOKE ALL ON FUNCTION engine0.invoke(engine0.closure) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.invoke(engine0.closure) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.invoke(engine0.closure) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.invoke(engine0.closure) TO graphql;

END;

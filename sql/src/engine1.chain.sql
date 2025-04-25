
-- Type: FUNCTION ; Name: engine1.chain(engine1.closure); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.chain(engine1.closure)
 RETURNS SETOF engine1.closure
 LANGUAGE plpgsql
AS $function$
begin
  if $1.f != 'engine1.id'::regproc then
    return query execute format('select * from %s($1)', $1.f) using $1.ctx;
  end if;
  return;
end $function$;


REVOKE ALL ON FUNCTION engine1.chain(engine1.closure) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.chain(engine1.closure) TO tendrelservice;
GRANT EXECUTE ON FUNCTION engine1.chain(engine1.closure) TO graphql;

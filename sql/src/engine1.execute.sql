
-- Type: FUNCTION ; Name: engine1.execute(engine1.closure); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.execute(engine1.closure)
 RETURNS SETOF engine1.closure
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with recursive cte as (
        select $1.f, $1.ctx
        union all
        select r.*
        from cte, engine1.chain(cte.*) as r
    )
    select cte.f, jsonb_agg(cte.ctx)
    from cte
    where cte.f = 'engine1.id'::regproc -- we only care about the results
    group by cte.f
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine1.execute(engine1.closure) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.execute(engine1.closure) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.execute(engine1.closure) TO tendreladmin WITH GRANT OPTION;

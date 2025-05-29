BEGIN;

/*
DROP FUNCTION engine1.instantiate(jsonb);
*/


-- Type: FUNCTION ; Name: engine1.instantiate(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
      select t.instance as node
      from
        jsonb_to_recordset(ctx) as x(
            template_id text,
            location_id text,
            target_state text,
            target_type text,
            chain_root_id text,
            chain_prev_id text
        ),
        engine0.instantiate(
            template_id := x.template_id,
            location_id := x.location_id,
            target_state := x.target_state,
            target_type := x.target_type,
            chain_root_id := x.chain_root_id,
            chain_prev_id := x.chain_prev_id,
            modified_by := 895
        ) as t
      group by t.instance
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'created', jsonb_agg(jsonb_build_object('node', cte.node))
    )
  from cte
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.instantiate(jsonb) TO graphql;

END;

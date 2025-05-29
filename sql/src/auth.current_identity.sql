BEGIN;

/*
DROP FUNCTION auth.current_identity(bigint,text);
*/


-- Type: FUNCTION ; Name: auth.current_identity(bigint,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION auth.current_identity(parent bigint, identity text)
 RETURNS bigint
 LANGUAGE sql
 STABLE STRICT
AS $function$
  select workerinstanceid
  from public.workerinstance
  inner join public.worker
      on  workerinstanceworkerid = workerid
      and workeridentityid = identity
  where workerinstancecustomerid = parent
$function$;

COMMENT ON FUNCTION auth.current_identity(bigint,text) IS '

# auth.current_identity

Returns the (big)serial primary key that corresponds to the given [customer, user] pair.

## usage

```sql
update location
set locationmodifiedby = auth.current_identity(locationcustomerid, $1)
where locationid = $2
```

';

REVOKE ALL ON FUNCTION auth.current_identity(bigint,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION auth.current_identity(bigint,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION auth.current_identity(bigint,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION auth.current_identity(bigint,text) TO graphql;

END;

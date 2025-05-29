BEGIN;

/*
DROP FUNCTION debug.inspect_t(text,anyelement);
DROP FUNCTION debug.inspect(anyelement);

DROP SCHEMA debug;
*/

CREATE SCHEMA debug;

GRANT USAGE ON SCHEMA debug TO graphql;

-- DEPENDANTS


-- Type: FUNCTION ; Name: debug.inspect(anyelement); Owner: tendreladmin

CREATE OR REPLACE FUNCTION debug.inspect(r anyelement)
 RETURNS anyelement
 LANGUAGE plpgsql
AS $function$
begin
  raise notice 'inspect: %', r;
  return r;
end $function$;

COMMENT ON FUNCTION debug.inspect(anyelement) IS '

# debug.inspect

Log $1 and then return it.

## usage

```sql
select debug.inspect(foo.id) as id from foo;

NOTICE:  inspect: 1007
NOTICE:  inspect: 1008
NOTICE:  inspect: 1009
  id
------
 1007
 1008
 1009
(3 rows)
```

';

REVOKE ALL ON FUNCTION debug.inspect(anyelement) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION debug.inspect(anyelement) TO PUBLIC;
GRANT EXECUTE ON FUNCTION debug.inspect(anyelement) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION debug.inspect(anyelement) TO graphql;

-- Type: FUNCTION ; Name: debug.inspect_t(text,anyelement); Owner: tendreladmin

CREATE OR REPLACE FUNCTION debug.inspect_t(t text, r anyelement)
 RETURNS anyelement
 LANGUAGE plpgsql
AS $function$
begin
  raise notice 'inspect: % := %', t, r;
  return r;
end $function$;

COMMENT ON FUNCTION debug.inspect_t(text,anyelement) IS '

# debug.inspect_t

Log $1 and $2, then return $2. This is the tagged version of `debug.inspect`.

## usage

```sql
select debug.inspect_t(''foo.id'', foo.id) as id from foo;

NOTICE:  inspect: foo.id := 1007
NOTICE:  inspect: foo.id := 1008
NOTICE:  inspect: foo.id := 1009
  id
------
 1007
 1008
 1009
(3 rows)
```

';

REVOKE ALL ON FUNCTION debug.inspect_t(text,anyelement) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION debug.inspect_t(text,anyelement) TO PUBLIC;
GRANT EXECUTE ON FUNCTION debug.inspect_t(text,anyelement) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION debug.inspect_t(text,anyelement) TO graphql;

END;


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

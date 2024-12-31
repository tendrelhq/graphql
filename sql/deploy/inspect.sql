-- Deploy graphql:inspect to pg
begin
;

create schema util
;

create function util.inspect(r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: %', r;
  return r;
end $$
language plpgsql
;

comment on function util.inspect is $$

# util.inspect

Log $1 and then return it.

## usage

```sql
select util.inspect(foo.id) as id from foo;

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

$$;

create function util.inspect_t(t text, r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: % := %', t, r;
  return r;
end $$
language plpgsql
;

comment on function util.inspect_t is $$

# util.inspect_t

Log $1 and $2, then return $2. This is the tagged version of `util.inspect`.

## usage

```sql
select util.inspect_t('foo.id', foo.id) as id from foo;

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

$$;


commit
;


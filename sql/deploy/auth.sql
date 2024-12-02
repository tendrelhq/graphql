-- Deploy graphql:auth to pg
begin
;

create schema auth;

create function auth.current_identity(parent bigint, identity text)
returns bigint
as $$
  select workerinstanceid
  from public.workerinstance
  inner join public.worker
      on  workerinstanceworkerid = workerid
      and workeridentityid = identity
  where workerinstancecustomerid = parent
$$
language sql
stable
strict
;

comment on function auth.current_identity is $$

# auth.current_identity

Returns the (big)serial primary key that corresponds to the given [customer, user] pair.

## usage

```sql
update location
set locationmodifiedby = auth.current_identity(locationcustomerid, $1)
where locationid = $2
```

$$;

commit
;

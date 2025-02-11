-- Deploy graphql:001-init to pg
begin
;

create schema auth;
create schema debug;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema auth from graphql;
    revoke all on schema debug from graphql;
    grant usage on schema auth to graphql;
    grant usage on schema debug to graphql;
    alter default privileges in schema auth grant execute on routines to graphql;
    alter default privileges in schema debug grant execute on routines to graphql;
  end if;
end $$;

-- BEGIN auth utility functions
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

-- END auth utility functions
-- BEGIN debugging utility functions
create function debug.inspect(r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: %', r;
  return r;
end $$
language plpgsql
;

comment on function debug.inspect is $$

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

$$;

create function debug.inspect_t(t text, r anyelement)
returns anyelement
as $$
begin
  raise notice 'inspect: % := %', t, r;
  return r;
end $$
language plpgsql
;

comment on function debug.inspect_t is $$

# debug.inspect_t

Log $1 and $2, then return $2. This is the tagged version of `debug.inspect`.

## usage

```sql
select debug.inspect_t('foo.id', foo.id) as id from foo;

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

-- END debugging utility functions
-- BEGIN name utility functions
create function
    public.create_name(
        customer_id text, source_language text, source_text text, modified_by bigint
    )
returns table(_id bigint, id text)
as $$
  insert into public.languagemaster (
    languagemastercustomerid,
    languagemastersourcelanguagetypeid,
    languagemastersource,
    languagemastermodifiedby
  )
  select
    c.customerid,
    s.systagid,
    source_text,
    modified_by
  from public.customer as c, public.systag as s
  where
    c.customeruuid = customer_id
    and s.systagparentid = 2
    and s.systagtype = source_language
  returning languagemasterid as _id, languagemasteruuid as id;
$$
language sql
strict
;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    grant execute on function public.create_name to graphql;
  end if;
end $$;

-- END name utility functions
create schema ast;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema ast from graphql;
    grant usage on schema ast to graphql;
    alter default privileges in schema ast grant execute on routines to graphql;
  end if;
end $$;

-- BEGIN type constructor utility functions
create function
    ast.create_system_type(type_name text, type_hierarchy text, modified_by bigint)
returns table(_id bigint, id text)
as $$
begin
  return query
    with ins_name as (
        select t.*
        from
            public.customer as c,
            public.create_name(
                customer_id := c.customeruuid,
                source_language := 'en',
                source_text := type_name,
                modified_by := modified_by
            ) as t
        where c.customerid = 0
    )
    insert into public.systag (
        systagcustomerid,
        systagparentid,
        systagtype,
        systagnameid,
        systagmodifiedby
    )
    select
        0 as customer, -- 'Tendrel'
        p.systagid,
        type_name,
        ins_name._id,
        modified_by
    from ins_name
    inner join public.systag as p on p.systagtype = type_hierarchy
    returning systagid as _id, systaguuid as id
  ;
  --
  if not found then
    raise exception 'failed to create type';
  end if;

  return;
end $$
language plpgsql
strict
;

create function
    ast.create_user_type(
        customer_id text,
        language_type text,
        type_name text,
        type_hierarchy text,
        modified_by bigint
    )
returns table(_id bigint, id text)
as $$
begin
  return query
    select custagid as _id, custaguuid as id
    from public.custag
    where
        custagcustomerid = (
            select customerid
            from public.customer
            where customeruuid = customer_id
        )
        and custagsystagid = (
            select systagid
            from public.systag
            where systagtype = type_hierarchy
        )
        and custagtype = type_name
  ;

  if not found then
    return query
      with ins_name as (
          select *
          from public.create_name(
              customer_id := customer_id,
              source_language := language_type,
              source_text := type_name,
              modified_by := modified_by
          )
      )

      insert into public.custag (
          custagcustomerid,
          custagsystagid,
          custagtype,
          custagnameid,
          custagmodifiedby
      )
      select
          c.customerid,
          s.systagid,
          type_name,
          ins_name._id,
          modified_by
      from public.customer as c, public.systag as s, ins_name
      where c.customeruuid = customer_id and s.systagtype = type_hierarchy
      returning custagid as _id, custaguuid as id
    ;
  end if;

  return;
end $$
language plpgsql
strict
;

-- END type constructor utility functions
commit
;

-- Deploy graphql:engine1 to pg

BEGIN;

create schema engine1;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'graphql') then
    revoke all on schema engine1 from graphql;
    grant usage on schema engine1 to graphql;
    alter default privileges in schema engine1 grant execute on routines to graphql;
  end if;

  if exists (select 1 from pg_roles where rolname = 'tendrelservice') then
    revoke all on schema engine1 from tendrelservice;
    grant usage on schema engine1 to tendrelservice;
    alter default privileges in schema engine1 grant execute on routines to tendrelservice;
  end if;
end $$;

create type engine1.closure as (
    f regproc,
    ctx jsonb
);

create type engine1.node as (
  kind text,
  id text
);

-- The identity function. Perhaps our most useful tool? Perhaps.
create or replace function engine1.id(jsonb)
returns setof jsonb
as 'select $1'
language sql
immutable;

-- Chain a closure into another set of closures.
create or replace function engine1.chain(engine1.closure)
returns setof engine1.closure
as $$
begin
  if $1.f != 'engine1.id'::regproc then
    return query execute format('select * from %s($1)', $1.f) using $1.ctx;
  end if;
  return;
end $$
language plpgsql;

create type engine1.result as (
  ok boolean,
  created engine1.node[],
  deleted text[],
  updated engine1.node[],
  errors text[]
);

create or replace function engine1.execute(engine1.closure)
returns setof engine1.closure
as $$
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
end $$
language plpgsql
strict;

create or replace function engine1.base64_encode(data bytea)
returns text
as $$
  select translate(encode(data, 'base64'), E'+/e\n', '-_');
$$
language sql
immutable;

create or replace function engine1.base64_decode(data text)
returns bytea
as $$
  with
    t as (select translate(data, '-_', '+/') as trans),
    rem as (select length(t.trans) % 4 as remainder from t) -- compute padding size
  select decode(
      t.trans ||
        case when rem.remainder > 0 then repeat('=', (4 - rem.remainder)) else '' end,
      'base64'
  ) from t, rem;
$$
language sql
immutable;

COMMIT;

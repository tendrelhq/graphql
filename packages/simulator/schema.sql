begin;

-- Tendrel (modern) schema v0.
--

-- Immutable, content-addressed datapoints.
create schema data;

create table data.store (
  hash text primary key,
  value jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Raw data values are content-addressed.
create function data.hash(blob jsonb) returns text
as $$
  select 'this is a fake hash'
$$
language sql
immutable;

create function data.store_pre_update() returns trigger
as $$
begin
  new.updated_at := current_timestamp;
  return new;
end
$$
language plpgsql;

create trigger store_pre_update before update on data.store
for each row execute function data.store_pre_update();

-- An entity represents a distinct object within the system.
create schema entity;

-- A component characterizes an entity as possessing a particular trait.
create table entity.component (
  entity uuid not null,
  type text not null,
  data text references data.store (hash),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint entity_component_pk primary key (entity, type)
);

create function entity.component_pre_update() returns trigger
as $$
begin
  new.updated_at := current_timestamp;
  return new;
end
$$
language plpgsql;

create trigger component_pre_update before update on entity.component
for each row execute function entity.component_pre_update();

create function entity.with_component(text)
returns setof entity.component
as $$
  select *
  from entity.component as ec
  where ec.type = $1
$$
language sql
stable;

create index on entity.component (type);

create function entity.with_component_data(text)
returns table(entity text, data jsonb)
as $$
  select
    ec.entity,
    jsonb_object_agg(ec.type, store.value)
  from entity.component as ec
  left join data.store on ec.data = store.hash
  where ec.type = $1
  group by ec.entity
$$
language sql
stable;

rollback;

begin;

create schema object;
--
-- Blobs store raw data.
create table object.blob (
  --
);
--
-- Trees represent hierarchies, containing pointers to blobs and other trees.
create table object.tree (
  --
);
--
-- Point to a tree and contain additional metadata about the commit, including
-- the author, notes, parent commits, etc.
create table object.commit (
  --
);
--
-- References a specific object and can contain additional metadata.
create table object.tag (
  --
);

create table state (
  name text primary key,
  description text references data.store(hash)
);

create table transition (
  from_state text not null references state(name),
  to_state text not null references state(name),
  description text references data.store(hash)
);

rollback;

begin;

drop table if exists entity_parent;
drop table if exists entity_component;
drop table if exists entity;

create table entity (
  id uuid primary key default gen_random_uuid()
);

create table entity_component (
  entity uuid not null references entity (id),
  type text not null,
  data jsonb,
  primary key (entity, type)
);

create table entity_parent (
  entity uuid not null references entity (id),
  parent uuid not null references entity (id),
  constraint no_self_references check (entity <> parent)
);

-- drop function if exists create_entity();
create function create_entity() returns uuid
as $$
  insert into entity (id) values (default)
  returning id;
$$
language sql;

insert into entity_component(entity, type, data)
values (
  create_entity(),
  'Facility',
  jsonb_build_object(
      'name', 'Frozen Tendy Factory'
  )
);

insert into entity_component(entity, type, data)
select create_entity(), t, d
from (
  values
    ('Line', '{"name":"Mixing Line"}'::jsonb),
    ('Line', '{"name":"Fill Line"}'),
    ('Line', '{"name":"Assembly Line"}'),
    ('Line', '{"name":"Cartoning Line"}'),
    ('Line', '{"name":"Packaging Line"}')
) as i(t, d);

drop view if exists entity_component_agg;
create view entity_component_agg as
select id as entity, ec.type, ec.data
from entity e
left join entity_component ec on e.id = ec.entity;

-- source_sql
select entity, type, data from entity_component_agg order by 1;
-- category_sql
select distinct type from entity_component_agg;

select *
from crosstab(
    'select entity, type, data from entity_component_agg order by 1;',
    'select distinct type from entity_component_agg;'
) as ct(entity uuid, line jsonb, facility jsonb);

rollback;

begin;

  -- The question is IMO do we think the K1 demo is the future? Keller's dumb
  -- pipe is certainly one way of doing things, but can we be better? Yes.
  --
  -- The other question is do we think people will want to try it? Hmm...
  --
  -- How would it work for K1 / the machine data people of the world?
  --
  -- 1. Give them an ISO that they can stick on Pi. "It can talk MQTT, just
  --    point your machines at it"
  -- 2. Give them a web app that they can run locally (i.e. no need to connect
  --    to the cloud) and configure their machines.
  -- 3. Keller's API is the dumb pipe that gets the data into the system.
  -- 4. There also exists
  --
  --
  -- (2) Note that this would be the Device Code flow. The machines would
  -- initiate the flow on startup and you would have to approve it via the web
  -- app.
  --
  --
  -- Don't forget that this whole thing is about collecting data. How you make
  -- it available to the end user is another matter entirely. So, what does "raw
  -- data" look like? Where does it go?
  
  create table raw_data (
    timestamp timestamp not null,
    value jsonb not null
  );

  -- Ok... the bare minimum. I like it. One problem though: time. We can't
  -- really control it can we? In fact, as a property on our raw data is doesn't
  -- even really make sense. Time is completely relative to that which is
  -- creating the data! For example: the machine does not care that it is 3pm,
  -- but it *does* care that it is about to finish the 1000th cycle.
  
  create table raw_data (
    t text not null, -- "time"
    v jsonb not null
  );

  -- Just a key/value store? Yes, but...
  -- We still don't quite have "time" right. Half right, but not full right.
  -- What are we missing? Identity! Two machines produce the value 42 as t=7,
  -- are these two datapoints identical? No! (well maybe) but for the sake of
  -- argument we'll say that they *should be distinct*.
  
  create table raw_data (
    k version_vector not null, -- "version"
    v jsonb not null
  );

rollback;

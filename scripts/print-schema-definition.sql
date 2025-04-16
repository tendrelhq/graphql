select
  nspname as name,
  ddlx_create(oid, '{}') as src
from pg_namespace
where nspname = :nspname

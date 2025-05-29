select
  nspname as name,
  ddlx_script(oid, '{}') as src
from pg_namespace
where nspname = :nspname

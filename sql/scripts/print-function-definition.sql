select
  pg_namespace.nspname || '.' || pg_proc.proname as name,
  ddlx_script(pg_proc.oid, '{}') as src
from pg_proc
inner join pg_namespace on pg_proc.pronamespace = pg_namespace.oid
where pg_namespace.nspname = :nspname

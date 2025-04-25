-- Verify graphql:api-user-roles on pg

BEGIN;

select 1 / count(*) from pg_catalog.pg_roles where rolname = 'anonymous';
select 1 / count(*) from pg_catalog.pg_roles where rolname = 'authenticated';
select 1 / count(*) from pg_catalog.pg_roles where rolname = 'god';
select 1 / count(*) from pg_catalog.pg_roles where rolname = 'graphql';

ROLLBACK;

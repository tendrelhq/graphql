-- Verify graphql:jwt on pg

begin;

select pg_catalog.has_schema_privilege('crypto', 'usage');
select 1/count(*) from pg_extension where extname = 'pgcrypto';

select pg_catalog.has_schema_privilege('jwt', 'usage');
select pg_catalog.has_function_privilege('jwt.base64_encode(bytea)', 'execute');
select pg_catalog.has_function_privilege('jwt.base64_decode(text)', 'execute');
select pg_catalog.has_function_privilege('jwt.sign(json, text, text)', 'execute');
select pg_catalog.has_function_privilege('jwt.verify(text, text, text)', 'execute');

rollback;

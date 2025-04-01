-- Verify graphql:rudimentary-jwk on pg

BEGIN;

select pg_catalog.has_function_privilege('auth.jwk_sign(auth._jwk,json)', 'execute') ;
select pg_catalog.has_function_privilege('auth.jwt_sign(json)', 'execute') ;
select pg_catalog.has_function_privilege('auth.jwt_verify(text)', 'execute') ;

ROLLBACK;

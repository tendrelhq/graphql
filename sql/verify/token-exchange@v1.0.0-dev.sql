-- Verify graphql:token-exchange on pg

BEGIN;

select
  pg_catalog.has_function_privilege(
    'api.token(api.grant_type,text,api.token_type,text,text)', 'execute'
  )
;

ROLLBACK;

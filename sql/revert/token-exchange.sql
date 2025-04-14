-- Deploy graphql:token-exchange to pg

BEGIN;

drop function if exists api.token_introspect;
drop function if exists api.token;
drop type api.grant_type;
drop type api.token_type;

drop function auth.jwt_verify;
drop function auth.jwt_sign;
drop function auth.jwk_sign;
drop function auth.jwk_alg_sign;
drop function auth.extract_signing_key;
drop table auth._jwk;

COMMIT;

-- Revert graphql:rudimentary-jwk from pg

BEGIN;

drop function auth.jwt_verify;
drop function auth.jwt_sign;
drop function auth.jwk_sign;
drop function auth.jwk_alg_sign;
drop function auth.extract_signing_key;
drop table auth._jwk;

COMMIT;

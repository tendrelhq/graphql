-- Revert graphql:jwt from pg

begin;

drop function jwt.verify;
drop function jwt.try_cast_double;
drop function jwt.sign;
drop function jwt.algorithm_sign;
drop function jwt.base64_decode;
drop function jwt.base64_encode;
drop schema jwt;

drop extension pgcrypto;
drop schema crypto;

commit;

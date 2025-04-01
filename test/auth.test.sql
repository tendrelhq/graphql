begin;
set local client_min_messages to 'notice';
set local search_path to tap;

select plan(8);

select is(auth.current_identity(0, 'user_2jJ7Xl0LFewQGKKNYwfFWAM0Lmc'), 818::bigint);
select is(auth.current_identity(-1, 'user_2jJ7Xl0LFewQGKKNYwfFWAM0Lmc'), null);
select is(auth.current_identity(0, ''), null);

insert into auth._jwk(kty, alg, params, _description)
values (
  'oct',
  'HS256',
  jsonb_build_object('k', gen_random_uuid()),
  'just for testing :)'
);

select alike(auth.jwt_sign('{"foo":"bar"}'), '%.%.%');

select is('{"foo":"bar"}', jwt.payload::text)
from auth.jwt_verify(auth.jwt_sign('{"foo":"bar"}')) as jwt;

select ok(jwt.valid)
from auth.jwt_verify(auth.jwt_sign('{"foo":"bar"}')) as jwt;

select ok(jwt.valid = false)
from auth.jwt_verify(auth.jwt_sign(('{"foo":"bar","exp":' || extract(epoch from now() - '5 min'::interval) || '}')::json)) as jwt;

select ok(jwt.valid = false)
from auth.jwt_verify(auth.jwt_sign(('{"foo":"bar","nbf":' || extract(epoch from now() + '5 min'::interval) || '}')::json)) as jwt;

select * from finish();
rollback;

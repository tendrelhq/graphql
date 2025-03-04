begin;
set local client_min_messages to 'notice';
set local search_path to tap;

select plan(4);

select is(jwt.base64_encode('foobar'::bytea), 'Zm9vYmFy');
select is(jwt.base64_decode('Zm9vYmFy'), 'foobar'::bytea);

select is(
  jwt.sign(
    '{"role":"anon","iss":"urn:tendrel:dev","iat":1741735616,"sub":"foo"}',
    'secret'
  ),
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InVybjp0ZW5kcmVsOmRldiIsImlhdCI6MTc0MTczNTYxNiwic3ViIjoiZm9vIn0.xIi_ZqtSKajnDt-yq7iB-nI7HhE22esEDJg7tOSKiQY'
);

select results_eq(
  $$
    select header::text, payload::text, valid
    from jwt.verify(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InVybjp0ZW5kcmVsOmRldiIsImlhdCI6MTc0MTczNTYxNiwic3ViIjoiZm9vIn0.xIi_ZqtSKajnDt-yq7iB-nI7HhE22esEDJg7tOSKiQY',
      'secret'
    )
  $$,
  $$
    values (
      '{"alg":"HS256","typ":"JWT"}',
      '{"role":"anon","iss":"urn:tendrel:dev","iat":1741735616,"sub":"foo"}',
      true
    )
  $$
);

select * from finish();
rollback;

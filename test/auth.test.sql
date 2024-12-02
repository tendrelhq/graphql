-- noqa: disable=AM04,LT06
begin
;

set local client_min_messages to 'notice'
;
set local search_path to tap
;

select plan(3)
;

select is (auth.current_identity(0, 'user_2iADtxE5UonU4KO5lphsG59bkR9'), 895::bigint)
;

select is (auth.current_identity(-1, 'user_2iADtxE5UonU4KO5lphsG59bkR9'), null)
;

select is (auth.current_identity(0, ''), null)
;

select *
from finish()
;

rollback
;

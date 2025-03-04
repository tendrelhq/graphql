begin;
set local client_min_messages to 'notice';
set local search_path to tap;

select plan(3);

select is (auth.current_identity(0, 'user_2jJ7Xl0LFewQGKKNYwfFWAM0Lmc'), 818::bigint);
select is (auth.current_identity(-1, 'user_2jJ7Xl0LFewQGKKNYwfFWAM0Lmc'), null);
select is (auth.current_identity(0, ''), null);

select * from finish();
rollback;

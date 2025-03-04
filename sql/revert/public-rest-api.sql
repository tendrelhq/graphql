-- Revert graphql:public-rest-api from pg
begin;
-- The following avoids 'notice' messages pertaining to cascading deletes.
set local client_min_messages = 'warning';

drop schema _api cascade;
drop schema api cascade;
drop role anon;

commit;

-- Revert graphql:auth from pg
begin
;

drop function auth.current_identity
;

drop schema auth;

commit
;

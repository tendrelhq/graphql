-- Revert graphql:inspect from pg
begin
;

drop function if exists util.inspect
;

drop function if exists util.inspect_t
;

drop schema if exists util cascade
;

commit
;


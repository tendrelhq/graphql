-- Revert graphql:worker from pg
begin
;

drop function if exists util.create_worker
;

commit
;


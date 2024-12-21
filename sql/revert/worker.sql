-- Revert graphql:worker from pg
begin
;

drop function util.create_worker
;

commit
;


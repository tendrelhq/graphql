-- Revert graphql:inspect from pg
begin
;

drop function util.inspect
;

drop function util.inspect_t
;

drop schema util cascade
;

commit
;


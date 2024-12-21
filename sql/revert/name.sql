-- Revert graphql:name from pg
begin
;

drop function util.create_name
;

commit
;


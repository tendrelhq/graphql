-- Revert graphql:name from pg
begin
;

drop function if exists util.create_name
;

commit
;

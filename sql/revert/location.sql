-- Revert graphql:location from pg
begin
;

drop function if exists util.create_location
;

commit
;


-- Revert graphql:location from pg
begin
;

drop function util.create_location
;

commit
;


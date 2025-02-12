-- Revert graphql:006-primary-location-for-instance from pg
begin
;

drop function if exists legacy0.primary_location_for_instance
;

commit
;

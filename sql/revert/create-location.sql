-- Revert graphql:create-location from pg
begin;

drop function if exists legacy0.create_location;

commit;

-- Revert graphql:runtime from pg
begin
;

drop function if exists mft.destroy_demo
;

drop function if exists mft.create_demo
;

drop function if exists mft.create_location
;

drop function if exists mft.create_customer
;

drop schema if exists mft
;

commit
;

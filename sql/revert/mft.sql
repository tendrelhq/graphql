-- Revert graphql:mft from pg
begin
;

drop function mft.destroy_demo
;

drop function mft.create_demo
;

drop function mft.create_location
;

drop function mft.create_customer
;

drop schema mft
;

commit
;


-- Revert graphql:runtime from pg
begin
;

drop function if exists runtime.destroy_demo
;

drop function if exists runtime.create_demo
;

drop function if exists runtime.create_location
;

drop function if exists runtime.create_customer
;

drop schema if exists runtime
;

commit
;

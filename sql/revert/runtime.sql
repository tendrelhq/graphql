-- Revert graphql:runtime from pg
begin
;

drop function if exists runtime.destroy_demo
;

drop function if exists runtime.add_demo_to_customer
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

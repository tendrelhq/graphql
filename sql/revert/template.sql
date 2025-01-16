-- Revert graphql:template from pg
begin
;

drop function if exists util.create_task_t
;

drop function if exists util.create_template_type
;

drop function if exists util.create_template_constraint_on_location
;

drop function if exists util.create_field_t
;

drop function if exists util.create_morphism
;

drop function if exists util.instantiate
;

commit
;

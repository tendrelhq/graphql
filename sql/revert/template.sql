-- Revert graphql:template from pg
begin
;

drop function util.create_task_t
;

drop function util.create_template_type
;

drop function util.create_template_constraint_on_location
;

drop function util.create_field_t
;

commit
;


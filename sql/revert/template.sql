-- Revert graphql:template from pg
begin
;

drop function if exists util.create_rrule
;

drop function if exists util.evaluate_rrules
;

drop function if exists util.compute_rrule_next_occurrence
;

drop function if exists util.create_task_t
;

drop function if exists util.create_template_type
;

drop function if exists util.create_template_constraint_on_location
;

drop function if exists util.create_field_t
;

drop function if exists util.create_instantiation_rule
;

drop function if exists util.instantiate
;

commit
;

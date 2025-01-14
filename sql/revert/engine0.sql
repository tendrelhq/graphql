-- Revert graphql:engine0 from pg
begin
;

drop function if exists engine0.execute
;

drop function if exists engine0.build_instantiation_plan
;

drop function if exists engine0.evaluate_instantiation_plan
;

drop function if exists engine0.eval_field_condition
;

drop function if exists engine0.eval_state_condition
;

drop function if exists engine0.eval_field_and_state_condition
;

drop function if exists engine0.invoke
;

drop type if exists engine0.closure cascade
;

drop schema if exists engine0
;

commit
;


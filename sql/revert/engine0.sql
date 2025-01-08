-- Revert graphql:engine0 from pg
begin
;

drop function if exists engine0.execute
;

drop function if exists engine0.plan_build
;

drop function if exists engine0.plan_check
;

drop function if exists engine0.eval_field_condition
;

drop function if exists engine0.eval_state_condition
;

drop function if exists engine0.eval_field_and_state_condition
;

drop type if exists engine0.closure
;

drop schema if exists engine0
;

commit
;


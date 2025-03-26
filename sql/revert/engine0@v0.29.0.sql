-- Revert graphql:engine0 from pg
begin;

drop function if exists engine0.execute;
drop function if exists engine0.build_instantiation_plan;
drop function if exists engine0.evaluate_instantiation_plan;
drop function if exists engine0.eval_field_condition;
drop function if exists engine0.eval_state_condition;
drop function if exists engine0.eval_field_and_state_condition;
drop function if exists engine0.invoke;
drop function if exists engine0.instantiate;
drop function if exists engine0.evaluate_rrules;
drop function if exists engine0.compute_rrule_next_occurrence;

drop type if exists engine0.closure;

drop schema if exists engine0;

commit;

-- Revert graphql:apply-field-edits from pg
begin;

drop function if exists auth.set_actor;
drop function if exists engine0.apply_field_edit;
drop type if exists engine0.diagnostic;
drop type if exists engine0.diagnostic_kind;
drop type if exists engine0.diagnostic_severity;
drop type if exists engine0.on_error;

commit;

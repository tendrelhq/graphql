-- Revert graphql:create-template-constraint from pg
begin;

drop function if exists legacy0.create_template_constraint_on_location;

commit;

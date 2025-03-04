-- Revert graphql:004-legacy-entities from pg
begin;
-- The following avoids 'notice' messages pertaining to cascading deletes.
set local client_min_messages = 'warning';

drop function if exists legacy0.create_location;
drop function if exists legacy0.create_worker;
drop function if exists legacy0.create_task_t;
drop function if exists legacy0.create_template_type;
drop function if exists legacy0.create_template_constraint_on_location;
drop function if exists legacy0.create_field_t;
drop function if exists legacy0.create_instantiation_rule;
drop function if exists legacy0.create_rrule;

drop schema if exists legacy0;

commit;

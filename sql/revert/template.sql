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

drop function util.create_morphism
;

drop function util.instantiate
;

-- drop function util.chain_into
-- ;
--
-- drop type chain_strategy;
-- drop type field_input;
commit
;


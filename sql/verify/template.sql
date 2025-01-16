-- Verify graphql:template on pg
begin
;

select
    pg_catalog.has_function_privilege('util.create_template_type'::regproc, 'execute')
;

select
    pg_catalog.has_function_privilege(
        'util.create_template_constraint_on_location'::regproc, 'execute'
    )
;

select pg_catalog.has_function_privilege('util.create_field_t'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('util.create_morphism'::regproc, 'execute')
;

select pg_catalog.has_function_privilege('util.instantiate'::regproc, 'execute')
;

-- select pg_catalog.has_function_privilege('util.chain_into'::regproc, 'execute')
-- ;
rollback
;

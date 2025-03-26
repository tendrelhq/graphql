-- Verify graphql:engine0 on pg
begin;

select
    pg_catalog.has_function_privilege(
        'engine0.eval_field_condition'::regproc, 'execute'
    )
;
select
    pg_catalog.has_function_privilege(
        'engine0.eval_field_and_state_condition'::regproc, 'execute'
    )
;

rollback;

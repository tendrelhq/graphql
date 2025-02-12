-- Verify graphql:006-primary-location-for-instance on pg
begin
;

select
    pg_catalog.has_function_privilege(
        'legacy0.primary_location_for_instance'::regproc, 'execute'
    )
;

rollback
;

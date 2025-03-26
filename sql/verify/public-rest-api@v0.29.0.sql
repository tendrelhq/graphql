-- Verify graphql:public-rest-api on pg
begin;

select pg_catalog.has_schema_privilege('api', 'usage');

-- select locale, value, created_at, updated_at
-- from api.localized
-- where false;

select
    id,
    activated_at,
    deactivated_at,
    created_at,
    updated_at,
    external_id,
    scan_code,
    modified_by,
    owner,
    type,
    parent,
    external_system,
    _deleted,
    _draft,
    _order,
    _primary
from api.template
where false;

select pg_catalog.has_function_privilege('api.display_name(api.template)', 'execute');

select pg_catalog.has_function_privilege('api.fields(api.template)', 'execute');

select
    id,
    template,
    type_id,
    created_at,
    updated_at,
    activated_at,
    deactivated_at,
    default_value,
    _deleted,
    _draft,
    _order,
    _primary
from api.template_field
where false;

select pg_catalog.has_function_privilege('api.display_name(api.template_field)', 'execute');

select pg_catalog.has_function_privilege('api.type(api.template_field)', 'execute');

select
    id,
    template,
    created_at,
    updated_at,
    activated_at,
    deactivated_at,
    _deleted,
    _draft,
    _order
from api.instance
where false;

select pg_catalog.has_function_privilege('api.display_name(api.instance)', 'execute');

select pg_catalog.has_function_privilege('api.template(api.instance)', 'execute');

select id, instance, template, created_at, updated_at, _deleted, _draft
from api.instance_field
where false;

select pg_catalog.has_function_privilege('api.display_name(api.instance_field)', 'execute');

select pg_catalog.has_function_privilege('api.parent(api.instance_field)', 'execute');

select pg_catalog.has_function_privilege('api.template(api.instance_field)', 'execute');

select pg_catalog.has_function_privilege('api.value(api.instance_field)', 'execute');

rollback;

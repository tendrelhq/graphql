-- Revert graphql:001-init from pg
begin;
-- The following avoids 'notice' messages pertaining to cascading deletes.
set local client_min_messages = 'warning';

drop function if exists ast.create_system_type;
drop function if exists ast.create_user_type;
drop function if exists public.create_name;
drop function if exists auth.current_identity;
drop function if exists debug.inspect;
drop function if exists debug.inspect_t;

drop schema if exists ast;
drop schema if exists debug;
drop schema if exists auth;

commit;

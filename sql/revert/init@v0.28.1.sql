-- Revert graphql:init from pg
begin;
-- The following avoids 'notice' messages pertaining to cascading deletes.
set local client_min_messages = 'warning';

drop function if exists ast.create_system_type;
drop function if exists ast.create_user_type;
drop function if exists auth.current_identity;
drop function if exists debug.inspect;
drop function if exists debug.inspect_t;
drop function if exists i18n.create_localized_content;
drop function if exists i18n.update_localized_content;

drop schema if exists ast;
drop schema if exists debug;
drop schema if exists i18n;
drop schema if exists auth;

commit;

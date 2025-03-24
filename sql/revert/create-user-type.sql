-- Revert graphql:create-user-type from pg
begin;

drop function if exists ast.create_user_type;

commit;

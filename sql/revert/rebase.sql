-- Revert graphql:rebase from pg

BEGIN;

revoke all on function engine0.rebase from graphql;
drop function if exists engine0.rebase;

COMMIT;

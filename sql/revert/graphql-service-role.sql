-- Revert graphql:graphql-service-role from pg

BEGIN;

revoke all on all tables in schema entity from graphql;
revoke all on schema entity from graphql;

revoke all on schema auth from graphql;
revoke all on all routines in schema auth from graphql;

revoke all on all sequences in schema public from graphql;
revoke all on all tables in schema public from graphql;
revoke all on schema public from graphql;

drop role graphql;

COMMIT;

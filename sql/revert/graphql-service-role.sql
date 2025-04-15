-- Revert graphql:graphql-service-role from pg

BEGIN;

revoke usage on schema public from graphql;
revoke all on all tables in schema public from graphql;

revoke usage on schema ast from graphql;
revoke execute on all routines in schema ast from graphql;

revoke usage on schema auth from graphql;
revoke execute on all routines in schema auth from graphql;

revoke usage on schema debug from graphql;
revoke execute on all routines in schema debug from graphql;

revoke usage on schema engine0 from graphql;
revoke execute on all routines in schema engine0 from graphql;

revoke usage on schema engine1 from graphql;
revoke execute on all routines in schema engine1 from graphql;

revoke usage on schema entity from graphql;
revoke execute on all routines in schema entity from graphql;
revoke all on all tables in schema entity from graphql;

revoke usage on schema i18n from graphql;
revoke execute on all routines in schema i18n from graphql;

revoke usage on schema legacy0 from graphql;
revoke execute on all routines in schema legacy0 from graphql;

revoke usage on schema runtime from graphql;
revoke execute on all routines in schema runtime from graphql;

drop role graphql;

COMMIT;

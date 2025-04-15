-- Deploy graphql:graphql-service-role to pg

BEGIN;

create role graphql login;

grant usage on schema public to graphql;
grant all on all tables in schema public to graphql;

grant usage on schema ast to graphql;
grant execute on all routines in schema ast to graphql;

grant usage on schema auth to graphql;
grant execute on all routines in schema auth to graphql;

grant usage on schema debug to graphql;
grant execute on all routines in schema debug to graphql;

grant usage on schema engine0 to graphql;
grant execute on all routines in schema engine0 to graphql;

grant usage on schema engine1 to graphql;
grant execute on all routines in schema engine1 to graphql;

grant usage on schema entity to graphql;
grant execute on all routines in schema entity to graphql;
grant all on all tables in schema entity to graphql;

grant usage on schema i18n to graphql;
grant execute on all routines in schema i18n to graphql;

grant usage on schema legacy0 to graphql;
grant execute on all routines in schema legacy0 to graphql;

grant usage on schema runtime to graphql;
grant execute on all routines in schema runtime to graphql;

COMMIT;

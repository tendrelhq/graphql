-- Deploy graphql:graphql-service-role to pg

BEGIN;

create role graphql login;

grant usage on schema public to graphql;
grant all on all tables in schema public to graphql;
grant all on all sequences in schema public to graphql;

grant usage on schema entity to graphql;
grant all on all tables in schema entity to graphql;

grant usage on schema auth to graphql;
grant execute on function auth.jwk_sign to graphql;

COMMIT;

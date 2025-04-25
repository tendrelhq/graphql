CREATE SCHEMA public;
COMMENT ON SCHEMA public IS 'standard public schema';

ALTER SCHEMA public OWNER TO pg_database_owner;
GRANT USAGE ON SCHEMA public TO graphql;
GRANT USAGE ON SCHEMA public TO PUBLIC;

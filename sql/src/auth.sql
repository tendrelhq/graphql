CREATE SCHEMA IF NOT EXISTS auth;

GRANT USAGE ON SCHEMA auth TO graphql;

-- auth._jwk can only be accessed by way of auth.jwt_sign which is SECURITY DEFINER
REVOKE ALL ON TABLE auth._jwk FROM public;
REVOKE ALL ON TABLE auth._jwk FROM graphql;
REVOKE ALL ON TABLE auth._jwk FROM tendrelservice;
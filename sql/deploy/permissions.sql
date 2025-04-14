-- Deploy graphql:permissions to pg

BEGIN;

-- First things first: `public`.
-- This role forms the base of all other roles. As such, it only should grant
-- the bare minimum set of privileges required by *every role*.
revoke all on schema _api from public;
revoke all on schema  api from public;
revoke all on all routines in schema _api from public;
revoke all on all routines in schema  api from public;
revoke all on all tables in schema api from public;
-- Like I said, bare minimum.
grant usage on schema _api to public;

-- Next up is the `anonymous` role. This role gains a few extra privileges as it
-- is the default role used by the REST backend, namely the ability to do a
-- token exchange. Recall: even the so-called "anonymous" role requires a valid
-- JWT!
create role anonymous nologin;
grant usage on schema api to anonymous;
grant execute on function _api.pre_request_hook to anonymous;
grant execute on function api.token to anonymous;

-- The `authenticated` role is the typical one used for REST requests. It gives
-- the user rwx privileges. Keep in mind the underlying tables are further
-- protected by RLS. [^RLS is not currently implemented]
create role authenticated nologin in role anonymous;
grant execute on function api.token_introspect to authenticated;

grant execute on all routines in schema _api to authenticated;
grant execute on all routines in schema  api to authenticated;
grant all on table api.entity_description to authenticated;
grant all on table api.entity_instance to authenticated;
grant all on table api.entity_instance_field to authenticated;
grant all on table api.entity_instance_file to authenticated;
grant all on table api.entity_tag to authenticated;
grant all on table api.entity_template to authenticated;
grant all on table api.entity_field to authenticated;

-- Lastly, Good 'ol Tom, the `god` role. This role is available to any user who
-- has access to the Tendrel internal customer so, essentially, just us devs.
-- The most notable capability of this role is its `bypassrls` attribute...
-- I give you.... god mode!
create role god nologin bypassrls in role authenticated;

-- This last bit enables user impersonation via the graphql service role. The
-- following grants essentially allow for `set role to <rolname>`.
do $$
begin
  if exists(select 1 from pg_roles where rolname = 'graphql') then
    grant anonymous to graphql;
    grant authenticated to graphql;
    grant god to graphql;
  end if;
end $$;

-- Refresh the PostgREST schema cache.
notify pgrst, 'reload schema';

COMMIT;

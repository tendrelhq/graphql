-- Deploy graphql:public-rest-api to pg
begin;

-- This is our "exposed schema".
-- @see https://docs.postgrest.org/en/v12/references/api/schemas.html#schemas
create schema if not exists api;
-- This schema holds utility functions, e.g. our pre-request hook. It is not
-- exposed and therefore cannot be directly "hit" via the REST api.
create schema if not exists _api;

-- PATCH: add SECURITY DEFINER
create or replace function _api.parse_accept_language(accept_language text)
returns table(tag text, quality float)
as $$
declare
  v_parts text[];
  v_part text;
  v_language text;
  v_quality text;
  v_language_parts text[];
begin
  if nullif(accept_language, '') is null then
    tag := 'en';
    quality := 1.0;
    return next;
    return;
  end if;

  v_parts := string_to_array(accept_language, ',');

  foreach v_part in array v_parts loop
    v_part := trim(v_part);
    v_quality := 1.0;
    v_language_parts := string_to_array(v_part, ';');
    v_language := trim(v_language_parts[1]);
    if array_length(v_language_parts, 1) > 1 then
      v_quality := substring(trim(v_language_parts[2]) FROM 'q=([0-9]*\.?[0-9]+)');
      if nullif(v_quality, '') is null then
        v_quality := 1.0;
      end if;
    end if;

    tag := lower(v_language);
    quality := v_quality;
    return next;
  end loop;

  return;
end $$
language plpgsql
immutable
security definer; --> this is new

create or replace function _api.pre_request_hook()
returns void
as $$
declare
  accept_language text := nullif(current_setting('request.headers', true)::json ->> 'accept-language', '')::text;
  preferred_language text;
begin
  -- TODO: This just uses the Accept-Language header to determine language
  -- preference. It does not yet look at the user's configured preference, e.g.
  -- workerlanguagetypeid (or whatever it is).
  select systagtype into preferred_language
  from _api.parse_accept_language(accept_language)
  inner join public.systag on systagparentid = 2 and systagtype = tag
  order by quality desc
  limit 1;

  perform set_config('user.preferred_language', preferred_language, true);

  return;
end $$
language plpgsql
-- To avoid leaking systag, we create this function as SECURITY DEFINER.
-- In the future we work through the normal entity tables/views and remove the
-- SECURITY DEFINER attribute.
security definer; 

commit;

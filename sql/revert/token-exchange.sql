-- Revert graphql:token-exchange from pg

BEGIN;

revoke execute on function api.token from anonymous, authenticated, god;
revoke execute on function api.token_introspect from authenticated, god;

revoke usage on type api.grant_type from anonymous, authenticated, god;
revoke usage on type api.token_type from anonymous, authenticated, god;

drop role authenticated;
drop role anonymous;
drop role god;

drop function if exists api.token;
drop type api.grant_type;
drop type api.token_type;

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
immutable;

COMMIT;

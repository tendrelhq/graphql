
-- Type: FUNCTION ; Name: _api.pre_request_hook(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION _api.pre_request_hook()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
end $function$;


REVOKE ALL ON FUNCTION _api.pre_request_hook() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _api.pre_request_hook() TO tendreladmin WITH GRANT OPTION;

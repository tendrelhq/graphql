
-- Type: FUNCTION ; Name: _api.parse_accept_language(text); Owner: bombadil

CREATE OR REPLACE FUNCTION _api.parse_accept_language(accept_language text)
 RETURNS TABLE(tag text, quality double precision)
 LANGUAGE plpgsql
 IMMUTABLE SECURITY DEFINER
AS $function$
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
end $function$;


REVOKE ALL ON FUNCTION _api.parse_accept_language(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION _api.parse_accept_language(text) TO bombadil WITH GRANT OPTION;

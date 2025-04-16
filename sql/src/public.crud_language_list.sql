
-- Type: FUNCTION ; Name: crud_language_list(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_language_list(language_id bigint)
 RETURNS TABLE(uuid text, id bigint, name text, code text)
 LANGUAGE plpgsql
AS $function$

Declare
    templanguageid bigint;
BEGIN

    if language_id isNull
    then
        templanguageid = 20;
    else
        templanguageid = language_id;
    end if;

    RETURN QUERY SELECT language.systaguuid as uuid,
                        language.systagid   as id,
                        language.systagname as name,
                        language.systagtype as code
                 FROM public.view_systag language
                 where systagparentid =
                       (select systagid from systag tag where tag.systagparentid = 1 and tag.systagtype = 'Language')
                   and languagetranslationtypeid = templanguageid
                 order by systagname;

End;

$function$;


REVOKE ALL ON FUNCTION crud_language_list(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_language_list(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_language_list(bigint) TO tendreladmin WITH GRANT OPTION;


-- Type: FUNCTION ; Name: api.value(api.z_20250409_instance_field); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.value(api.z_20250409_instance_field)
 RETURNS SETOF text
 LANGUAGE sql
 STABLE SECURITY DEFINER ROWS 1
AS $function$
  select coalesce(
      languagetranslationvalue,
      languagemastersource,
      entityfieldinstancevalue
  ) as value
  from entity.entityfieldinstance
  left join public.languagemaster
      on entityfieldinstancevaluelanguagemasteruuid = languagemasteruuid
  left join public.languagetranslations
      on languagemasterid = languagetranslationmasterid
      and languagetranslationtypeid = (
          select systagid
          from public.systag
          where systagparentid = 2 and systagtype = current_setting('user.preferred_language', true)
      )
  where entityfieldinstanceuuid = $1.id;
$function$;


REVOKE ALL ON FUNCTION api.value(api.z_20250409_instance_field) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.value(api.z_20250409_instance_field) TO tendreladmin WITH GRANT OPTION;

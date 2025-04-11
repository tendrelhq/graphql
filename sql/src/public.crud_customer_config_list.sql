
-- Type: FUNCTION ; Name: crud_customer_config_list(text,bigint); Owner: bombadil

CREATE OR REPLACE FUNCTION public.crud_customer_config_list(customer_uuid_param text, language_id bigint)
 RETURNS TABLE(uuid text, started_at timestamp without time zone, ended_at timestamp without time zone, updated_by_uuid text, type text, type_uuid text, value text, value_type text, value_type_uuid text, category text, category_uuid text, name text, site_uuid text)
 LANGUAGE sql
AS $function$
SELECT customerconfiguuid       as uuid,
       customerconfigstartdate  as started_at,
       customerconfigenddate    as ended_at,
       customerconfigmodifiedby as updated_by_uuid,
       config_type.systagtype   as type,
       customerconfigtypeuuid   as type_uuid,
       customerconfigvalue      as value,
       value_type.systagtype    as value_type,
       value_type.systaguuid    as value_type_uuid,
       category.systagname      as category,
       category.systaguuid      as category_uuid,
       config_type.systagname   as name,
       customerconfigsiteuuid   as site_uuid
FROM public.customerconfig cc
         INNER JOIN public.view_systag config_type
                    ON cc.customerconfigtypeuuid = config_type.systaguuid and
                       config_type.languagetranslationtypeid = language_id
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
         INNER JOIN public.view_systag category
                    ON config_type.systagparentid = category.systagid and
                       category.languagetranslationtypeid = language_id
WHERE customerconfigcustomeruuid = customer_uuid_param
AND customerconfigistemplate = false
ORDER BY category asc, name asc
$function$;


REVOKE ALL ON FUNCTION crud_customer_config_list(text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_list(text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_list(text,bigint) TO bombadil WITH GRANT OPTION;

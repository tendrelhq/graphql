
-- Type: FUNCTION ; Name: crud_customer_config_templates_list(bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.crud_customer_config_templates_list(language_id bigint)
 RETURNS TABLE(uuid text, type_uuid text, type text, value text, value_type text, value_type_uuid text, category text, category_uuid text, name text)
 LANGUAGE sql
AS $function$
SELECT customerconfiguuid     as uuid,
       customerconfigtypeuuid as type_uuid,
       config_type.systagtype as type,
       customerconfigvalue    as value,
       value_type.systagtype  as value_type,
       value_type.systaguuid  as value_type_uuid,
       category.systagname    as category,
       category.systaguuid    as category_uuid,
       config_type.systagname as name
FROM public.customerconfig cc
         INNER JOIN public.view_systag config_type
                    ON cc.customerconfigtypeuuid = config_type.systaguuid and
                       config_type.languagetranslationtypeid = language_id
         INNER JOIN public.systag value_type
                    ON cc.customerconfigvaluetypeuuid = value_type.systaguuid
         INNER JOIN public.view_systag category
                    ON config_type.systagparentid = category.systagid and
                       category.languagetranslationtypeid = language_id
WHERE customerconfigsiteuuid is null
  and customerconfigcustomeruuid = (select customeruuid from customer where customerid = 0)
  and customerconfigistemplate = true
ORDER BY category asc, name asc
$function$;


REVOKE ALL ON FUNCTION crud_customer_config_templates_list(bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_templates_list(bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION crud_customer_config_templates_list(bigint) TO tendreladmin WITH GRANT OPTION;

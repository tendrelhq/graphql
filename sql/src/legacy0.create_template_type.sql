
-- Type: FUNCTION ; Name: legacy0.create_template_type(text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_template_type(template_id text, systag_id text, modified_by bigint)
 RETURNS TABLE(id text)
 LANGUAGE sql
 STRICT
AS $function$
  insert into public.worktemplatetype (
      worktemplatetypecustomerid,
      worktemplatetypeworktemplateuuid,
      worktemplatetypeworktemplateid,
      worktemplatetypesystaguuid,
      worktemplatetypesystagid,
      worktemplatetypemodifiedby
  )
  select
      t.worktemplatecustomerid,
      t.id,
      t.worktemplateid,
      tt.systaguuid,
      tt.systagid,
      modified_by
  from public.worktemplate as t, public.systag as tt
  where t.id = template_id and tt.systaguuid = systag_id
  returning worktemplatetypeuuid as id
$function$;


REVOKE ALL ON FUNCTION legacy0.create_template_type(text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_type(text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_template_type(text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION legacy0.create_template_type(text,text,bigint) TO graphql;

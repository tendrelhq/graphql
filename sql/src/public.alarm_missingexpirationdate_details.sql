
-- Type: FUNCTION ; Name: alarm_missingexpirationdate_details(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.alarm_missingexpirationdate_details()
 RETURNS TABLE(workinstancecustomerid bigint, workinstancesiteid bigint, workinstanceworktemplateid bigint, workinstanceid bigint, workinstancepreviousid bigint)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

DECLARE
    tempcustomerid bigint;
    startdate      timestamp WITH TIME ZONE;

BEGIN

    startdate = (SELECT (MAX(workinstancemodifieddate) - INTERVAL '4 day') AS startdate FROM workinstance);

    RETURN QUERY
        (SELECT wi.workinstancecustomerid,
                wi.workinstancesiteid,
                wi.workinstanceworktemplateid,
                wi.workinstanceid,
                wi.workinstancepreviousid
         FROM public.workinstance wi
                  INNER JOIN public.worktemplatetype wtt
                             ON wtt.worktemplatetypeworktemplateid = wi.workinstanceworktemplateid
         WHERE wi.workinstancestatusid = 707
           AND wtt.worktemplatetypesystaguuid not in ('systag_cbe3ebc9-2d91-4647-beab-9807657c717a', 'ad2f2ced-06ca-46ab-8d75-a2c0a97ad33d')  -- not checklist or runtime
           AND wi.workinstanceexpirationdate ISNULL
           AND workinstancemodifieddate > startdate
           AND workinstancemodifieddate < NOW() - INTERVAL '5 minute');

END;

$function$;


REVOKE ALL ON FUNCTION alarm_missingexpirationdate_details() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION alarm_missingexpirationdate_details() TO PUBLIC;
GRANT EXECUTE ON FUNCTION alarm_missingexpirationdate_details() TO tendreladmin WITH GRANT OPTION;

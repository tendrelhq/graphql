
-- Type: FUNCTION ; Name: check_workresult_name(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.check_workresult_name()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
  BEGIN
      IF EXISTS (
          SELECT workresultworktemplateid, workresultisprimary, languagemastersource, count(*)
          FROM workresult
          INNER JOIN languagemaster
              ON
                  workresultlanguagemasterid = languagemasterid
          WHERE
              workresultcustomerid = NEW.workresultcustomerid
              AND workresultworktemplateid = NEW.workresultworktemplateid
          GROUP BY workresultworktemplateid, workresultisprimary, languagemastersource
          HAVING count(*) > 1
      ) THEN
          RAISE NOTICE 'workresultlanguagemasterid: % already exists on worktemplateid: %', NEW.workresultlanguagemasterid, NEW.workresultworktemplateid;
          RAISE unique_violation USING MESSAGE = 'workresult name must be unique within a customer/template';
      END IF;

      RETURN NULL; -- return value ignore for AFTER triggers
  END
$function$;


REVOKE ALL ON FUNCTION check_workresult_name() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION check_workresult_name() TO PUBLIC;
GRANT EXECUTE ON FUNCTION check_workresult_name() TO tendreladmin WITH GRANT OPTION;

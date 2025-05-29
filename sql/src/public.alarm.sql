BEGIN;

/*
DROP PROCEDURE alarm();
*/


-- Type: PROCEDURE ; Name: alarm(); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.alarm()
 LANGUAGE plpgsql
AS $procedure$
Declare
   alarm_start timestamp with time zone;
Begin

-- Start the timer on this function
	alarm_start = clock_timestamp();

	CALL datawarehouse.alarm();

Commit;

if  (select dwlogginglevel1 from datawarehouse.dw_logginglevels) = false
	Then Return;
end if;

-- Insert into the tendy tracker
--call datawarehouse.insert_tendy_tracker(0, 1378, 12496, 811, 844, 12341, 18068, 12846,12340, import_start);

COMMIT; 
End;

$procedure$;


REVOKE ALL ON PROCEDURE alarm() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE alarm() TO tendreladmin WITH GRANT OPTION;

END;

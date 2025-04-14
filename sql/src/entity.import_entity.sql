
-- Type: PROCEDURE ; Name: entity.import_entity(text); Owner: bombadil

CREATE OR REPLACE PROCEDURE entity.import_entity(IN intervaltype text)
 LANGUAGE plpgsql
AS $procedure$
Declare
    fact_start timestamp with time zone;
Begin

 -- Start the timer on this function
    fact_start = clock_timestamp();
	
if  (select dwrunfactimport from datawarehouse.dw_logginglevels) = false
	Then 
		if  (select dwlogginglevel2 from datawarehouse.dw_logginglevels) = true
			Then   
			        call datawarehouse.insert_tendy_tracker(0, 2517, 12496, 980, 844, 20770, 18068, 20771, 20769, fact_start);
				return;
		end if;
end if;

	call entity.import_entity_systag(intervaltype);
	call entity.import_entity_customer(intervaltype);
	call entity.import_entity_location(intervaltype);
	call entity.import_entity_custag(intervaltype);
	call entity.import_workresultinstanceentityvalue(intervaltype);

  if exists (select 1 from pg_namespace where nspname = 'datawarehouse') then
-- Insert into the tendy tracker

    if (select dwlogginglevel2 from datawarehouse.dw_logginglevels) = false
    Then
        Return;
    end if;

    if intervaltype = '5 minute'
    Then
        call datawarehouse.insert_tendy_tracker(0, 2517, 12496, 980, 844, 20770, 18068, 20771, 20769, fact_start);
        Return;
    end if;

    if intervaltype = '1 hour'
    Then
        call datawarehouse.insert_tendy_tracker(0, 2518, 12496, 980, 844, 20774, 18068, 20775, 20773, fact_start);
        Return;
    end if;

    call datawarehouse.insert_tendy_tracker(0, 2519, 12496, 980, 844, 20778, 18068, 20779, 20777, fact_start);

  end if;
End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.import_entity(text) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity(text) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.import_entity(text) TO bombadil WITH GRANT OPTION;

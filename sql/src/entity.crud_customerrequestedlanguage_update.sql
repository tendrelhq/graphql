BEGIN;

/*
DROP PROCEDURE entity.crud_customerrequestedlanguage_update(bigint,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint);
*/


-- Type: PROCEDURE ; Name: entity.crud_customerrequestedlanguage_update(bigint,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_customerrequestedlanguage_update(IN update_customerrequestedlanguageid bigint, IN update_customerrequestedlanguageownerentityuuid uuid, IN update_languagetype_id uuid, IN update_customerrequestedlanguagedeleted boolean, IN update_customerrequestedlanguagedraft boolean, IN update_customerrequestedlanguagestartdate timestamp with time zone, IN update_customerrequestedlanguageenddate timestamp with time zone, IN update_modifiedbyid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

Begin

/*

-- needs tests
	
*/

UPDATE public.customerrequestedlanguage
	SET customerrequestedlanguagestartdate = case when update_customerrequestedlanguagestartdate notnull 
											then update_customerrequestedlanguagestartdate
											else customerrequestedlanguagestartdate end,
		customerrequestedlanguageenddate = update_customerrequestedlanguageenddate, 
		customerrequestedlanguagemodifieddate = now(),
		customerrequestedlanguagemodifiedby = update_modifiedbyid
	WHERE customerrequestedlanguageid = update_customerrequestedlanguageid; 

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_customerrequestedlanguage_update(bigint,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_update(bigint,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_update(bigint,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_customerrequestedlanguage_update(bigint,uuid,uuid,boolean,boolean,timestamp with time zone,timestamp with time zone,bigint) TO graphql;

END;

BEGIN;

/*
DROP PROCEDURE entity.enable_checklist(uuid,text,uuid,text,uuid,text,text,bigint);
*/


-- Type: PROCEDURE ; Name: entity.enable_checklist(uuid,text,uuid,text,uuid,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.enable_checklist(IN create_customer_uuid uuid, IN create_original_customer_uuid text, IN create_site_uuid uuid, IN create_original_site_uuid text, IN create_language_type_uuid uuid, IN create_original_language_type_uuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
-- Customer temp values
    tempcustomerid bigint;    
	
-- Site/Location temp values
    tempcustagsitetypeid bigint;
	tempcustagsitetypeuuid uuid;
    tempsiteid bigint;
	temptaguuid uuid;
	tempcustaguuid text;
-- template, instance and result
    tempworktemplateid bigint;
    tempworktemplateuuid text;
    tempworkfrequencyid bigint;
    tempworkresultid bigint;
    tempworkresultidforworker bigint;
    tempworkinstanceid bigint;
-- General temp values
    templanguagemasterid bigint;
    template_description_id bigint;
	tempcreate_modifiedby_uud text;
-- checklist
    checklist_config_template_uuid text;
    checklist_config_uuid text;
-- language uuids
  	englishentityuuid uuid;
	englishoriginaluuid text;
	temp_language_type text;
	languageuuid uuid;
	tendreluuid uuid;
	temp_language_type_id bigint;

BEGIN

    RAISE NOTICE 'Start of procedure';

------------------------------------------------------------------
-- Start setting the missing values
-- grab originaluuids or entityuuids depending on what was sent in
-------------------------------------------------------------------

-- setup language variables.  If there is no language type sent in default to english.  
-- Set these as variables just incast the uuids change in the future.

	tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';
	languageuuid = '580f6ee2-42ca-4a5b-9e18-9ea0c168845a';
 	englishentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	englishoriginaluuid = '7ebd10ee-5018-4e11-9525-80ab5c6aebee';

	if create_language_type_uuid isNull
		then  select systagentityuuid ,systagdisplayname, systagid
				into create_language_type_uuid,temp_language_type, temp_language_type_id
				from entity.crud_systag_read_full(tendreluuid,null,null, languageuuid, false,null,null, null,englishentityuuid)
				where systaguuid = create_original_language_type_uuid
				;
	end if;

	if create_original_language_type_uuid isNull
		then  select systaguuid ,systagdisplayname, systagid
				into create_original_language_type_uuid,temp_language_type, temp_language_type_id
				from entity.crud_systag_read_full(tendreluuid,null,null, languageuuid, false,null,null, null,englishentityuuid)
				where systagentityuuid = create_language_type_uuid				
				;
	end if;

-- if language type is still null then set it to the default.

	if create_language_type_uuid isNull or create_original_language_type_uuid isNull
		then create_language_type_uuid = englishentityuuid;
			create_original_language_type_uuid = englishoriginaluuid;
			temp_language_type_id = 20;
			temp_language_type = 'en';
	end if;

-- setup customer variables

	if create_customer_uuid isNull
		then select customerentityuuid, customerid
				into create_customer_uuid,tempcustomerid
				from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
				where customeruuid = create_original_customer_uuid;
	end if;

	if create_original_customer_uuid isNull
		then select customeruuid, customerid
				into create_original_customer_uuid,tempcustomerid		
				from entity.crud_customer_read_min(null,null, null, true, null,null,null,null)
				where customerentityuuid = create_customer_uuid;
	end if;

	if create_customer_uuid isNull or create_original_customer_uuid isNull or tempcustomerid isNull
		then  raise exception 'No owner entity found';
	end if;

-- setup site variables

	if create_site_uuid isNull
		then select locationentityuuid, locationid
				into create_original_site_uuid,tempsiteid	 
				from entity.crud_location_read_min(create_customer_uuid,null,null,null,true,null,null,null,null,null)
				where locationid = create_original_site_uuid;
	end if;

	if create_original_site_uuid isNull
		then select locationuuid, locationid
				into create_original_site_uuid,tempsiteid	
				from entity.crud_location_read_min(create_customer_uuid,null,null,null,true,null,null,null,null,null)
				where locationentityuuid = create_site_uuid;
	end if;

	if create_site_uuid isNull or create_original_site_uuid isNull or tempsiteid isNull
		then  raise exception 'No site entity found';
	end if;

    IF (SELECT EXISTS(SELECT id
                      FROM view_worktemplate
                      WHERE worktemplatename = 'Demo Checklist'
                        AND worktemplatecustomerid = tempcustomerid)) THEN
        RAISE NOTICE 'Checklist template exists, skipping.';
    ELSE
        -- Add in worktemplates for the site id and location types
-- Add in checklist template type

        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'Demo Checklist',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'Use the Tendrel Console to modify this demo checklist or create your own!',
                create_modifiedby)
        RETURNING languagemasterid INTO template_description_id;

-- find and add the site location category to the template

		select  locationtagentityuuid
		into temptaguuid
		from entity.crud_location_read_min(create_customer_uuid,create_site_uuid,null,null,false,null,null,null,null,englishentityuuid);

		select custagid, custaguuid 
		into tempcustagsitetypeid, tempcustaguuid
		from entity.crud_custag_read_min(create_customer_uuid, null, temptaguuid, null, false,null,null, null,englishentityuuid);

        INSERT INTO public.worktemplate(worktemplatecustomerid,
                                        worktemplatesiteid,
                                        worktemplatenameid,
                                        worktemplateneedstranslation,
                                        worktemplateallowondemand,
                                        worktemplateworkfrequencyid,
                                        worktemplatemodifiedby,
                                        worktemplatelocationtypeid,
                                        worktemplatesoplink,
                                        worktemplatedescriptionid)
        VALUES (tempcustomerid,
                tempsiteid,
                templanguagemasterid,
                FALSE,
                TRUE,
                1, -- this is placeholder for the frequencyid we are about to create
                create_modifiedby,
                tempcustagsitetypeid,
                'https://beta.console.tendrel.io/checklist',
                null)   -- FIX THIS:  this is the languagemaster.  Should have been the actual workdescription table.  
        RETURNING worktemplateid,id INTO tempworktemplateid, tempworktemplateuuid;
	
--    add work description 

		INSERT INTO public.workdescription(
			workdescriptionworktemplateid, 
			workdescriptioncustomerid, 
			workdescriptionname, 
			workdescriptioncreateddate, 
			workdescriptionmodifieddate, 
			workdescriptionstartdate, 
			workdescriptionenddate, 
			workdescriptionlanguagemasterid, 
			workdescriptionlanguagetypeid, 
			workdescriptionmodifiedby 
			)
		VALUES (
			tempworktemplateid, 
			tempcustomerid, 
			 'Use the Tendrel Console to modify this demo checklist or create your own!', 
			now(), 
			now(), 
			now(), 
			null, 
			template_description_id, 
			temp_language_type_id, 
			create_modifiedby
		) RETURNING workdescriptionid INTO template_description_id;

--		update worktemplate
--		set worktemplatedescriptionid = template_description_id
--		where worktemplateid = tempworktemplateid;

        RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

        INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                         workfrequencycustomerid,
                                         workfrequencytypeid,
                                         workfrequencyvalue,
                                         workfrequencystartdate,
                                         workfrequencymodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                740,
                1,
                CLOCK_TIMESTAMP(),
                create_modifiedby)
        RETURNING workfrequencyid INTO tempworkfrequencyid;

        RAISE NOTICE 'inserted frequency';

        UPDATE worktemplate w
        SET worktemplateworkfrequencyid = tempworkfrequencyid
        WHERE worktemplateid = tempworktemplateid;

-----------------------------------------------------------------------------------
        RAISE NOTICE 'variable tempcustomerid %',tempcustomerid;
        RAISE NOTICE 'variable create_original_customer_uuid %',create_original_customer_uuid;
		RAISE NOTICE 'variable tempworktemplateuuid %',tempworktemplateuuid;
		RAISE NOTICE 'variable tempcustaguuid %',tempcustaguuid;
-----------------------------------------------------------------------------------						

-- add the contraints

        INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                            worktemplateconstraintcustomeruuid,
                                            worktemplateconstrainttemplateid,
                                            worktemplateconstraintconstraintid, -- Location Type in custag
                                            worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                            worktemplateconstraintmodifiedby)
        VALUES (tempcustomerid,
                create_original_customer_uuid,
                tempworktemplateuuid,
                tempcustaguuid,
                'd8dfd8de-ffdc-4472-8d38-171351668e9d',   -- Is this location type?
                create_modifiedby);

        RAISE NOTICE 'first constraint';

-- Next template for in progress

        INSERT INTO public.worktemplatenexttemplate(worktemplatenexttemplateprevioustemplateid,
                                                    worktemplatenexttemplatenexttemplateid,
                                                    worktemplatenexttemplatecustomerid,
                                                    worktemplatenexttemplateviastatuschange,
                                                    worktemplatenexttemplateviastatuschangeid,
                                                    worktemplatenexttemplatesiteid,
                                                    worktemplatenexttemplatetypeid,
                                                    worktemplatenexttemplatemodifiedby)
        VALUES (tempworktemplateid,
                tempworktemplateid,
                tempcustomerid,
                TRUE,
                707,
                tempsiteid,
                692,
                create_modifiedby);

-- set tiny tendies types

        INSERT INTO worktemplatetype AS w
        (worktemplatetypeworktemplateuuid,
         worktemplatetypesystaguuid,
         worktemplatetypeworktemplateid,
         worktemplatetypesystagid,
         worktemplatetypecustomerid,
         worktemplatetypecustomeruuid)
        VALUES (tempworktemplateuuid,
                'ad2f2ced-06ca-46ab-8d75-a2c0a97ad33d',  -- Is this checklist?
                tempworktemplateid,
                969,
                tempcustomerid,
                create_original_customer_uuid);

        RAISE NOTICE 'inserted template';
		
        -- Add in workresults here
--Time At Task

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresultsiteid,
                                      workresultfortask,
                                      workresultforaudit,
                                      workresulttypeid,
                                      workresultlanguagemasterid,
                                      workresultorder,
                                      workresultisvisible,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                tempsiteid,
                TRUE,
                FALSE,
                737,
                4367,
                0,
                FALSE,
                TRUE,
                create_modifiedby);

-- Checklist - Clicker (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'Clicker Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                700,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                1,
                FALSE,
                TRUE,
                TRUE,
                FALSE,
                TRUE,
                FALSE,
                create_modifiedby);

-- Checklist - Boolean (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'True/False Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                754,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                1,
                FALSE,
                TRUE,
                TRUE,
                FALSE,
                TRUE,
                FALSE,
                create_modifiedby);

-- Checklist - Text (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'Long Text Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultisprimary,
                                      workresultmodifiedby,
                                      workresultdefaultvalue)
        VALUES (tempworktemplateid,
                tempcustomerid,
                702,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                1,
                FALSE,
                TRUE,
                TRUE,
                FALSE,
                TRUE,
                FALSE,
                create_modifiedby,
                'Widgets can be pre-configured with default values in the Tendrel Console, saving time by automatically applying frequently used result values.');

 

-- Primary Location
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'Location',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultentitytypeid,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                848,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                996,
                FALSE,
                FALSE,
                FALSE,
                FALSE,
                TRUE,
                852,
                TRUE,
                create_modifiedby)
        RETURNING workresultid INTO tempworkresultid;

--Primary Worker
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                temp_language_type_id,
                'Worker',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        INSERT INTO public.workresult(workresultworktemplateid,
                                      workresultcustomerid,
                                      workresulttypeid,
                                      workresultforaudit,
                                      workresultstartdate,
                                      workresultlanguagemasterid,
                                      workresultsiteid,
                                      workresultorder,
                                      workresultiscalculated,
                                      workresultiseditable,
                                      workresultisvisible,
                                      workresultisrequired,
                                      workresultfortask,
                                      workresultentitytypeid,
                                      workresultisprimary,
                                      workresultmodifiedby)
        VALUES (tempworktemplateid,
                tempcustomerid,
                848,
                FALSE,
                CLOCK_TIMESTAMP(),
                templanguagemasterid,
                tempsiteid,
                997,
                FALSE,
                FALSE,
                FALSE,
                FALSE,
                TRUE,
                850,
                TRUE,
                create_modifiedby)
        RETURNING workresultid INTO tempworkresultidforworker;

        -- Add in instances
-- Checklist only has ondemand  

        INSERT INTO public.workinstance(workinstancecustomerid,
                                        workinstanceworktemplateid,
                                        workinstancesiteid,
                                        workinstancetypeid,
                                        workinstancestatusid,
                                        workinstancetargetstartdate,
                                        workinstancetimezone,
                                        workinstancerefid, -- put location here to start
                                        workinstancemodifiedby)
        VALUES (tempcustomerid,
                tempworktemplateid,
                tempsiteid,
                692, -- this is the work type for task.
                706, -- this is the status for Open.
                CLOCK_TIMESTAMP(),
                create_timezone,    
                tempsiteid,
                create_modifiedby)
        RETURNING workinstanceid INTO tempworkinstanceid;

        UPDATE workinstance
        SET workinstanceoriginatorworkinstanceid = workinstanceid
        WHERE workinstancecustomerid = tempcustomerid
          AND workinstanceoriginatorworkinstanceid ISNULL;

-- Insert for tasks
        INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                              workresultinstancecustomerid,
                                              workresultinstanceworkresultid,
                                              workresultinstancemodifiedby,
                                              workresultinstancevalue)
        VALUES (tempworkinstanceid,
                tempcustomerid,
                tempworkresultid,
                create_modifiedby,
                tempsiteid);

        INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                              workresultinstancecustomerid,
                                              workresultinstanceworkresultid,
                                              workresultinstancemodifiedby,
                                              workresultinstancevalue)
        VALUES (tempworkinstanceid,
                tempcustomerid,
                tempworkresultidforworker,
                create_modifiedby,
                NULL);

        RAISE NOTICE 'inserted work instances';

-- FIX THIS:  Cleanup widget and format.  We should not ahve to fix them after the fact.  Insert them correctly.  

-- Number
        UPDATE workresult
        SET workresultwidgetid     = 407,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 701
          AND workresultwidgetid IS NULL;

-- Clicker
        UPDATE workresult
        SET workresultwidgetid     = 406,
            workresulttypeid       = 701,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 700
          AND workresultwidgetid IS NULL;

-- boolean
        UPDATE workresult
        SET workresultwidgetid     = 414,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 754
          AND workresultwidgetid IS NULL;

-- tat
        UPDATE workresult
        SET workresultwidgetid     = 413,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 737
          AND workresultwidgetid IS NULL;

--Text
        UPDATE workresult
        SET workresultwidgetid     = 408,
            workresulttypeid       = 771,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 702
          AND workresultwidgetid IS NULL;

--Sentiment
        UPDATE workresult
        SET workresultwidgetid     = 410,
            workresulttypeid       = 701,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 704
          AND workresultwidgetid IS NULL;

--String
        UPDATE workresult
        SET workresultwidgetid     = 412,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 771
          AND workresultwidgetid IS NULL;

-- entity
        UPDATE workresult
        SET workresultwidgetid     = 415,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 848
          AND workresultwidgetid IS NULL;

-- date
        UPDATE workresult
        SET workresultwidgetid     = 419,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 868
          AND workresultwidgetid IS NULL;

-- Geolocation
        UPDATE workresult
        SET workresultwidgetid     = 463,
            workresulttypeid       = 771,
            workresultmodifieddate = CLOCK_TIMESTAMP()
        WHERE workresulttypeid = 890
          AND workresultwidgetid IS NULL;

    END IF;

-- Add in customerconfigs

    SELECT uuid
    INTO Checklist_config_template_uuid
    FROM public.crud_customer_config_templates_list(temp_language_type_id)
    WHERE category = 'Applications'
      AND type = 'Checklist';

	tempcreate_modifiedby_uud = (select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedby);
    -- get uuids
    CALL public.crud_customer_config_create(customer_uuid := create_original_customer_uuid, site_uuid := create_original_site_uuid,
                                            config_template_uuid := Checklist_config_template_uuid,
                                            config_value := 'false', 
											 modified_by := tempcreate_modifiedby_uud,
                                            config_id := Checklist_config_uuid);

END;

$procedure$;


REVOKE ALL ON PROCEDURE entity.enable_checklist(uuid,text,uuid,text,uuid,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.enable_checklist(uuid,text,uuid,text,uuid,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.enable_checklist(uuid,text,uuid,text,uuid,text,text,bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.enable_checklist(uuid,text,uuid,text,uuid,text,text,bigint) TO graphql;

END;

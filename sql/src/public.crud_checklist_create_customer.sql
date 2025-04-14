
-- Type: PROCEDURE ; Name: crud_checklist_create_customer(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_checklist_create_customer(IN create_customeruuid text, IN create_siteuuid text, OUT create_adminuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
-- Customer temp values
    tempcustomerid                 bigint := (SELECT customerid
                                              FROM customer
                                              WHERE customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp values
    tempcustagsitetypeid           bigint;
    tempsiteid                     bigint := (SELECT locationid
                                              FROM location
                                              WHERE locationuuid = create_siteuuid);
    tempsiteuuid                   text;
    tempsitename                   text   := (SELECT locationlookupname
                                              FROM view_location
                                              WHERE locationuuid = create_siteuuid
                                                AND languagetranslationtypeid = 20);
    tempcustagsitetypeuuid         text   := (SELECT custaguuid
                                              FROM custag
                                                       INNER JOIN customer
                                                                  ON custagcustomerid = customerid
                                              WHERE custagtype = tempsitename
                                                AND (create_customeruuid = custagcustomeruuid
                                                  OR tempcustomerid = custagcustomerid));
    tempsitelanguagemasterid       bigint;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
    template_description_id        bigint;
    long_text_default_value_id     bigint;
-- checklist
    checklist_config_template_uuid text;
    checklist_config_uuid          text;

BEGIN

    RAISE NOTICE 'Start of procedure';

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
                20,
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
                20,
                'Use the Tendrel Console to modify this demo checklist or create your own!',
                create_modifiedby)
        RETURNING languagemasterid INTO template_description_id;

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
                template_description_id)
        RETURNING worktemplateid,id INTO tempworktemplateid, tempworktemplateuuid;

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

-- add the contraints

        INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                            worktemplateconstraintcustomeruuid,
                                            worktemplateconstrainttemplateid,
                                            worktemplateconstraintconstraintid, -- Location Type in custag
                                            worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                            worktemplateconstraintmodifiedby)
        VALUES (tempcustomerid,
                create_customeruuid,
                tempworktemplateuuid,
                tempcustagsitetypeuuid,
                'd8dfd8de-ffdc-4472-8d38-171351668e9d',
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
                811,
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
                'ad2f2ced-06ca-46ab-8d75-a2c0a97ad33d',
                tempworktemplateid,
                969,
                tempcustomerid,
                create_customeruuid);

        RAISE NOTICE 'inserted template';
        -- Add in workresults here
--"Time At Task"

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

        -- Checklist    ************

-- Checklist - Geolocation (using our widget.  May remove this later or not use it at all.)
        -- insert into public.languagemaster
        -- (languagemastercustomerid,
        --  languagemastercustomersiteid,
        --  languagemastersourcelanguagetypeid,
        --  languagemastersource,
        --  languagemastermodifiedby)
        -- values (tempcustomerid,
        --         tempsiteid,
        --         20,
        --         'Checklist - Geolocation',
        --         create_modifiedby)
        -- Returning languagemasterid into templanguagemasterid;

        -- INSERT INTO public.workresult(workresultworktemplateid,
        --                               workresultcustomerid,
        --                               workresulttypeid,
        --                               workresultforaudit,
        --                               workresultstartdate,
        --                               workresultlanguagemasterid,
        --                               workresultsiteid,
        --                               workresultorder,
        --                               workresultiscalculated,
        --                               workresultiseditable,
        --                               workresultisvisible,
        --                               workresultisrequired,
        --                               workresultfortask,
        --                               workresultisprimary,
        --                               workresultmodifiedby)
        -- values (tempworktemplateid,
--             tempcustomerid,
--             890,   -- geolocation type
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- -- Checklist - Number (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - Number',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             701,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- Checklist - Clicker (using our widget.  May remove this later or not use it at all.)
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
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
                20,
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
                20,
                'Long Text Widget',
                create_modifiedby)
        RETURNING languagemasterid INTO templanguagemasterid;

        --         insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Widgets can have default values, saving you time if they frequently have the same value. You can configure default values in the Tendrel Console.',
--             create_modifiedby)
--     Returning languagemasterid into long_text_default_value_id;

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

        -- -- Checklist - Sentiment (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - Sentiment',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             704,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- -- Checklist - String (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - String',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             771,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- -- Checklist - Date (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Checklist - Date',
--             create_modifiedby)
--     Returning languagemasterid into templanguagemasterid;

--     INSERT INTO public.workresult(workresultworktemplateid,
--                                   workresultcustomerid,
--                                   workresulttypeid,
--                                   workresultforaudit,
--                                   workresultstartdate,
--                                   workresultlanguagemasterid,
--                                   workresultsiteid,
--                                   workresultorder,
--                                   workresultiscalculated,
--                                   workresultiseditable,
--                                   workresultisvisible,
--                                   workresultisrequired,
--                                   workresultfortask,
--                                   workresultisprimary,
--                                   workresultmodifiedby)
--     values (tempworktemplateid,
--             tempcustomerid,
--             868,
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             1,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

--" Primary Location"
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
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

--"Primary Worker"
        INSERT INTO public.languagemaster
        (languagemastercustomerid,
         languagemastercustomersiteid,
         languagemastersourcelanguagetypeid,
         languagemastersource,
         languagemastermodifiedby)
        VALUES (tempcustomerid,
                tempsiteid,
                20,
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
-- RTLS only has ondemand

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
                811, -- this is the work type for task.
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
        -- Cleanup widget and format
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
    FROM public.crud_customer_config_templates_list(20)
    WHERE category = 'Applications'
      AND type = 'Checklist';

    -- get uuids
    CALL public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := Checklist_config_template_uuid,
                                            config_value := 'true', modified_by := create_adminuuid,
                                            config_id := Checklist_config_uuid);

    COMMIT;

END;

$procedure$;


REVOKE ALL ON PROCEDURE crud_checklist_create_customer(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_checklist_create_customer(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_checklist_create_customer(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

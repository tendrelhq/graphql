BEGIN;

/*
DROP PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint);
*/


-- Type: PROCEDURE ; Name: crud_rtls_create_customer_test(text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.crud_rtls_create_customer_test(IN create_customeruuid text, IN create_siteuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Customer temp values
    tempcustomerid                 bigint := (select customerid from customer where customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp valules
    tempcustagsitetypeid           bigint;
    tempsitename                   text := (select locationlookupname from view_location where locationuuid = create_siteuuid AND languagetranslationtypeid=20);
    tempcustagsitetypeuuid         text := (select custaguuid from custag where custagid =
                                            (select locationcategoryid
                                             from location
                                             where locationuuid=create_siteuuid));
    tempsiteid                     bigint := (select locationid from location where locationuuid = create_siteuuid);
    tempsiteuuid                   text;
-- template, instance and result
    tempworktemplateid             bigint;
    tempworktemplateuuid           text;
    tempworkfrequencyid            bigint;
    tempworkresultid               bigint;
    tempworkresultidforworker      bigint;
    tempworkinstanceid             bigint;
-- General temp values
    templanguagemasterid           bigint;
-- RTLS
    RTLS_config_template_uuid text;
    RTLS_config_uuid          text;

Begin
/*
    RAISE NOTICE 'Start of procedure';

-- Add in worktemplates for the site id and location types
-- Add in RTLS template type
IF (SELECT EXISTS(select id from view_worktemplate
		where worktemplatename = 'RTLS'
		and worktemplatecustomerid = tempcustomerid)) THEN
    RAISE NOTICE 'RTLS template exists, skipping.';
ELSE
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid,
                                    worktemplatereapinprogworkmillis)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            FALSE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid,
            -- expiration of 7 days
            604800000)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            748, -- one time frequency
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
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
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            (select systaguuid from systag where systagtype='RTLS' and systagparentid = (select systagid from systag where systagtype='Template Type')),
            tempworktemplateid,
            968,
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
                                  workresultmodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby);

-- RTLS    ************
-- RTLS - Geolocation (using our widget.  May remove this later or not use it at all.)
--     insert into public.languagemaster
--     (languagemastercustomerid,
--      languagemastercustomersiteid,
--      languagemastersourcelanguagetypeid,
--      languagemastersource,
--      languagemastermodifiedby)
--     values (tempcustomerid,
--             tempsiteid,
--             20,
--             'Geolocation',
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
--             890,   -- geolocation type
--             false,
--             clock_timestamp(),
--             templanguagemasterid,
--             tempsiteid,
--             99,
--             FALSE,
--             TRUE,
--             TRUE,
--             FALSE,
--             TRUE,
--             FALSE,
--             create_modifiedby);

-- RTLS - Accuracy
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Accuracy',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
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

-- RTLS - Altitude
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Altitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
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

-- RTLS - Altitude Accuracy
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Altitude Accuracy',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Heading (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Heading',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            4,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Latitude (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Latitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            5,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Longitude (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Longitude',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Speed (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Speed',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            701,
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            7,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby);

-- RTLS - Online Status (using our widget.  May remove this later or not use it at all.)
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Online Status',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
                                  workresulttranslate)
    values (tempworktemplateid,
            tempcustomerid,
            771,   -- Really this is a drop down and probably a pointer to possible statuses.
            false,
            clock_timestamp(),
            templanguagemasterid,
            tempsiteid,
            8,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            FALSE,
            create_modifiedby,
            FALSE);

--" Primary Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
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
    Returning workresultid into tempworkresultid;

--"Primary Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
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
    returning workresultid into tempworkresultidforworker;

-- Cleanup widget and format
-- Number
    update workresult
    set workresultwidgetid     = 407,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 701
      and workresultwidgetid is null;

-- Clicker
    update workresult
    set workresultwidgetid     = 406,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 700
      and workresultwidgetid is null;

-- boolean
    update workresult
    set workresultwidgetid     = 414,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 754
      and workresultwidgetid is null;

-- tat
    update workresult
    set workresultwidgetid     = 413,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 737
      and workresultwidgetid is null;

--Text
    update workresult
    set workresultwidgetid     = 408,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 702
      and workresultwidgetid is null;

--Sentiment
    update workresult
    set workresultwidgetid     = 410,
        workresulttypeid       = 701,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 704
      and workresultwidgetid is null;

--String
    update workresult
    set workresultwidgetid     = 412,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 771
      and workresultwidgetid is null;

-- entity
    update workresult
    set workresultwidgetid     = 415,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 848
      and workresultwidgetid is null;

-- date
    update workresult
    set workresultwidgetid     = 419,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 868
      and workresultwidgetid is null;

-- Geolocation
--    update workresult
--    set workresultwidgetid     = 463,
--        workresulttypeid       = 771,
--        workresultmodifieddate = clock_timestamp()
--    where workresulttypeid = 890
--      and workresultwidgetid is null;

-- Add in customerconfigs

    select uuid
    into RTLS_config_template_uuid
    from public.crud_customer_config_templates_list(20)
    where category = 'Applications'
      and type = 'RTLS';

    -- get uuids
    call public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := RTLS_config_template_uuid,
                                            config_value := 'true', modified_by := null,
                                            config_id := RTLS_config_uuid);

END IF;

-- Add in worktemplates for the site id and location types
-- Check In/Out will be of the Activity WorkType
-- Check In/Out will be On Demand

IF (SELECT EXISTS(select id from view_worktemplate
		where worktemplatename = 'RTLS - Check In/Out'
		and worktemplatecustomerid = tempcustomerid)) THEN
    RAISE NOTICE 'RTLS Check In/Out template exists, skipping.';
ELSE
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'RTLS - Check In/Out',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

    INSERT INTO public.worktemplate(worktemplatecustomerid,
                                    worktemplatesiteid,
                                    worktemplatenameid,
                                    worktemplateneedstranslation,
                                    worktemplateallowondemand,
                                    worktemplateworkfrequencyid,
                                    worktemplatemodifiedby,
                                    worktemplatelocationtypeid)
    values (tempcustomerid,
            tempsiteid,
            templanguagemasterid,
            FALSE,
            TRUE,
            1, -- this is placeholder for the frequencyid we are about to create
            create_modifiedby,
            tempcustagsitetypeid)
    Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

    RAISE NOTICE 'inserted part through template';

-- Add in the workfrequency for the template

    INSERT INTO public.workfrequency(workfrequencyworktemplateid,
                                     workfrequencycustomerid,
                                     workfrequencytypeid,
                                     workfrequencyvalue,
                                     workfrequencystartdate,
                                     workfrequencymodifiedby)
    values (tempworktemplateid,
            tempcustomerid,
            740,
            1,
            clock_timestamp(),
            create_modifiedby)
    Returning workfrequencyid into tempworkfrequencyid;

    RAISE NOTICE 'inserted frequency';

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- Location Type in custag
                                        worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',  -- this is 'Location'
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
    values (tempworktemplateid,
            tempworktemplateid,
            tempcustomerid,
            TRUE,
            707,
            tempsiteid,
            811,
            create_modifiedby);

-- set tiny tendies types

    insert into worktemplatetype as w
    (worktemplatetypeworktemplateuuid,
     worktemplatetypesystaguuid,
     worktemplatetypeworktemplateid,
     worktemplatetypesystagid,
     worktemplatetypecustomerid,
     worktemplatetypecustomeruuid)
    values (tempworktemplateuuid,
            'systag_0da3103c-adc6-4ec2-ac8d-7966a03ad9f6',  -- Activity
            tempworktemplateid,
            968,
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
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            tempsiteid,
            TRUE,
            FALSE,
            737,
            4367,
            0,
            FALSE,
            create_modifiedby,
			413);

-- Primary Location

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Location',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
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
            create_modifiedby,
			415)
    Returning workresultid into tempworkresultid;

--"Primary Worker"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Worker',
            create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

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
                                  workresultmodifiedby,
								  workresultwidgetid)
    values (tempworktemplateid,
            tempcustomerid,
            848,
            false,
            clock_timestamp(),
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
            create_modifiedby,
			415)
    returning workresultid into tempworkresultidforworker;

-- Add in ondemand instances

    INSERT INTO public.workinstance(workinstancecustomerid,
                                    workinstanceworktemplateid,
                                    workinstancesiteid,
                                    workinstancetypeid,
                                    workinstancestatusid,
                                    workinstancetargetstartdate,
                                    workinstancetimezone,
                                    workinstancerefid, -- put location here to start
                                    workinstancemodifiedby)
    values (tempcustomerid,
            tempworktemplateid,
            tempsiteid,
            811, -- this is the work type for task.
            706, -- this is the status for Open.
            clock_timestamp(),
            create_timezone,
            tempsiteid,
            create_modifiedby)
    Returning workinstanceid into tempworkinstanceid;

    update workinstance
    set workinstanceoriginatorworkinstanceid = workinstanceid
    where workinstancecustomerid = tempcustomerid
      and workinstanceoriginatorworkinstanceid isNull;

-- Insert result instances
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue,
                                          workresultinstancetimezone)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid,
            create_timezone);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue,
                                          workresultinstancetimezone)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null,
            create_timezone);

    RAISE NOTICE 'inserted work instances';
END IF;

commit;
*/
End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_rtls_create_customer_test(text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

END;

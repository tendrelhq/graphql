
-- Type: PROCEDURE ; Name: crud_timesheet_create_customer_v2(text,text,text,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_timesheet_create_customer_v2(IN create_customeruuid text, IN create_siteuuid text, OUT create_adminuuid text, IN create_timezone text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Customer temp values
    tempcustomerid                 bigint := (select customerid from customer where customeruuid = create_customeruuid);
    tempcustomeruuid               text;
-- Site/Location temp values
    tempcustagsitetypeid           bigint;
    tempcustagsitetypeuuid         text;
    tempsiteid                     bigint := (select locationid from location where locationuuid = create_siteuuid);
    tempsiteuuid                   text;
    tempsitename                   text := (select distinct(locationlookupname) from view_location where locationuuid = create_siteuuid);
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
-- timeclock
    timeclock_config_template_uuid text;
    timeclock_config_uuid          text;



Begin

    RAISE NOTICE 'Start of procedure';

    -- Add in worktemplates for the site id and location types
-- Add in Clock In/Out with entry location type

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Clock In/Out',
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

    RAISE NOTICE 'inserted part thru template';

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

select custagid, custaguuid
    into tempcustagsitetypeid, tempcustagsitetypeuuid
    from custag
             inner join customer
                        on custagcustomerid = customerid
    where custagtype = tempsitename
      and (create_customeruuid = custagcustomeruuid
        or tempcustomerid = custagcustomerid);

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
            'b2af4084-1f19-4e25-9890-db003ba7a4c3',
            tempworktemplateid,
            883,
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

--"Worker"
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
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Start Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Location',
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
            2,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"End Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Location',
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
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"Start Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Override',
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
            868,
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
            null,
            FALSE,
            create_modifiedby);

--"End Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Override',
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
            868,
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
            null,
            FALSE,
            create_modifiedby);

--"Override By"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Override By',
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
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Location"
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

--"Worker"
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

    -- Add in instances
-- timesheet only has ondemand

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

-- Insert for tasks
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null);

-- Add in Break In/Out with entry location type

    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Break In/Out',
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

    RAISE NOTICE 'inserted break in/out template';

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

    update worktemplate w
    set worktemplateworkfrequencyid = tempworkfrequencyid
    where worktemplateid = tempworktemplateid;

-- add the contraints

    INSERT INTO worktemplateconstraint (worktemplateconstraintcustomerid,
                                        worktemplateconstraintcustomeruuid,
                                        worktemplateconstrainttemplateid,
                                        worktemplateconstraintconstraintid, -- 'Row'
                                        worktemplateconstraintconstrainedtypeid, -- Location
                                        worktemplateconstraintmodifiedby)
    values (tempcustomerid,
            create_customeruuid,
            tempworktemplateuuid,
            tempcustagsitetypeuuid,
            'd8dfd8de-ffdc-4472-8d38-171351668e9d',
            create_modifiedby);
    RAISE NOTICE 'added second constraint';
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
            'b6efaf15-2818-4e1d-bcc9-26d171496d8d',
            tempworktemplateid,
            884,
            tempcustomerid,
            create_customeruuid);

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

--"Worker"
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
            1,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Start Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Location',
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
            2,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"End Location"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Location',
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
            3,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            852,
            FALSE,
            create_modifiedby);

--"Start Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Start Override',
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
            868,
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
            null,
            FALSE,
            create_modifiedby);

--"End Override"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'End Override',
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
            868,
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
            null,
            FALSE,
            create_modifiedby);

--"Override By"
    insert into public.languagemaster
    (languagemastercustomerid,
     languagemastercustomersiteid,
     languagemastersourcelanguagetypeid,
     languagemastersource,
     languagemastermodifiedby)
    values (tempcustomerid,
            tempsiteid,
            20,
            'Override By',
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
            6,
            FALSE,
            TRUE,
            TRUE,
            FALSE,
            TRUE,
            850,
            FALSE,
            create_modifiedby);

--"Location"
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

--"Worker"
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

    RAISE NOTICE 'inserted results';
    -- Add in instances
-- timesheet only has ondemand

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

-- Insert for tasks
    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultid,
            create_modifiedby,
            tempsiteid);

    INSERT INTO public.workresultinstance(workresultinstanceworkinstanceid,
                                          workresultinstancecustomerid,
                                          workresultinstanceworkresultid,
                                          workresultinstancemodifiedby,
                                          workresultinstancevalue)
    values (tempworkinstanceid,
            tempcustomerid,
            tempworkresultidforworker,
            create_modifiedby,
            null);

    RAISE NOTICE 'inserted work instances';
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
    update workresult
    set workresultwidgetid     = 463,
        workresulttypeid       = 771,
        workresultmodifieddate = clock_timestamp()
    where workresulttypeid = 890
      and workresultwidgetid is null;

-- Add in customerconfigs
    select uuid
    into timeclock_config_template_uuid
    from public.crud_customer_config_templates_list(20)
    where category = 'Applications'
      and type = 'Timeclock';

    -- get uuids
    call public.crud_customer_config_create(customer_uuid := create_customeruuid, site_uuid := tempsiteuuid,
                                            config_template_uuid := timeclock_config_template_uuid,
                                            config_value := 'true', modified_by := create_adminuuid,
                                            config_id := timeclock_config_uuid);

    commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_timesheet_create_customer_v2(text,text,text,bigint) TO bombadil WITH GRANT OPTION;

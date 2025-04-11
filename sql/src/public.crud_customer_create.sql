
-- Type: PROCEDURE ; Name: crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_customer_create(IN create_customername text, IN create_sitename text, OUT create_customeruuid text, IN create_customerbillingid text, IN create_customerbillingsystemid text, INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid text, OUT create_adminuuid text, OUT create_siteuuid text, IN create_timezone text, IN create_languagetypeuuids text[], IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Customer temp values
    tempcustomerid                 bigint;
    tempcustomeruuid               text;
    tempbillingsystemid            bigint;
-- Worker Temp Values
    tempidentitysystemid           text;
    tempworkeridentitysystemid     bigint;
    tempusername                   text;
    tempworkeruuid                 text;
-- Site/Location temp valules
    tempcustagsitetypeid           bigint;
    tempcustagsitetypeuuid         text;
    tempsiteid                     bigint;
    tempsiteuuid                   text;
    tempsitename                   text;
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
    templocationtimezone           text;
    templanguagetypeuuid           text;
    templanguagetypeidid           bigint;
    loop_languagetypeuuid          text;
    loop_languagetypeid            bigint;

Begin

    RAISE NOTICE 'Start of procedure';


-- Need to check for admin check early as well

    if (create_adminemailaddress isNull and create_adminphonenumber isNull)
    then
        return;
    End if;

    if (create_adminidentityid isNull)
    then
        return;
    End if;

    -- coalesce to 'My Site' if no site name is provided
    if (create_sitename isNull)
    then
        tempsitename = 'My Site';
    else
        tempsitename = create_sitename;
    end if;

    tempbillingsystemid = (select systagid
                           from systag
                           where systaguuid = create_customerbillingsystemid);

    templanguagetypeuuid = create_languagetypeuuids[1];


    templanguagetypeidid = (select systagid
                            from systag
                            where systaguuid = templanguagetypeuuid);

-- Insert the customer and get back the customeruuid.

    INSERT INTO public.customer(customername,
                                customerstartdate,
                                customerlanguagetypeid,
                                customerlanguagetypeuuid,
                                customernamelanguagemasterid,
                                customerexternalid,
                                customerexternalsystemid,
                                customerexternalsystemuuid,
                                customermodifiedby)
    VALUES (create_customername,
            clock_timestamp(),
            templanguagetypeidid,
            templanguagetypeuuid,
            4367,
            create_customerbillingid,
            tempbillingsystemid,
            create_customerbillingsystemid,
            create_modifiedby)
    Returning customeruuid,customerid into create_customeruuid,tempcustomerid;

-- add customer name into languagemaster

    INSERT INTO public.languagemaster(languagemastercustomerid,
                                      languagemastersourcelanguagetypeid,
                                      languagemastersource,
                                      languagemastermodifiedby)
    VALUES (tempcustomerid,
    templanguagetypeidid,
    create_customername,
    create_modifiedby)
    Returning languagemasterid into templanguagemasterid;

-- Fix the Language Master iDs

    update public.customer
        set customernamelanguagemasterid = templanguagemasterid,
        customerlanguagetypeid = templanguagetypeidid
        where customerid = tempcustomerid;

-- Add the languagetype to customer reqeusted languages

    FOREACH loop_languagetypeuuid IN ARRAY create_languagetypeuuids
    LOOP
        loop_languagetypeid = (select systagid
                                    from systag
                                    where systaguuid = loop_languagetypeuuid);
        insert into customerrequestedlanguage (customerrequestedlanguagecustomerid,
                                               customerrequestedlanguagelanguageid,
                                               customerrequestedlanguagemodifiedby)
        values (tempcustomerid, loop_languagetypeid, create_modifiedby);
    END LOOP;

    -- Add dummy values for admin if necessary

    if create_adminfirstname isNull
    then
        create_adminfirstname = 'Unknown';
    End if;

    if create_adminfirstname isNull
    then
        create_adminlastname = 'Unknown';
    End if;

    if create_adminemailaddress isNull
    then
        tempusername = create_adminphonenumber;
        create_adminemailaddress = 'Unknown';
    Else
        tempusername = create_adminemailaddress;
    End if;



-- insert the worker

    tempworkeridentitysystemid = (select systagid
                                  from systag
                                  where systaguuid = create_adminidentitysystemuuid);

    tempworkeruuid = (select workeruuid
                      from worker
                      where workeridentityid = create_adminidentityid
                        and workeridentitysystemuuid = create_adminidentitysystemuuid);


    if tempworkeruuid isNull
    then
        INSERT INTO public.worker(workerlastname,
                                  workerfirstname,
                                  workeremail,
                                  workerstartdate,
                                  workerfullname,
                                  workerlanguageid,
                                  workerusername, -- this is email or phone number
                                  workeridentityid,
                                  workeridentitysystemid,
                                  workeridentitysystemuuid,
                                  workermodifiedby)
        values (create_adminlastname,
                create_adminfirstname,
                create_adminemailaddress,
                clock_timestamp(),
                create_adminfirstname || ' ' || create_adminlastname,
                templanguagetypeidid,
                tempusername,
                create_adminidentityid,
                tempworkeridentitysystemid,
                create_adminidentitysystemuuid,
                create_modifiedby)
        Returning workeruuid into tempworkeruuid;
    end if;


-- insert the worker instance

    INSERT INTO public.workerinstance(workerinstanceworkerid,
                                      workerinstanceworkeruuid,
                                      workerinstancecustomerid,
                                      workerinstancecustomeruuid,
                                      workerinstancestartdate,
                                      workerinstancelanguageid,
                                      workerinstancelanguageuuid,
                                      workerinstancescanid,
                                      workerinstanceuserroleid,
                                      workerinstanceuserroleuuid,
                                      workerinstancemodifiedby)
    select workerid,
           workeruuid,
           tempcustomerid,
           create_customeruuid,
           clock_timestamp(),
           templanguagetypeidid,
           templanguagetypeuuid,
           workerusername,
           systagid,
           systaguuid,
           create_modifiedby
    from worker
             inner join systag
                        on systaguuid = '1d8c3097-23f5-4cac-a4c5-ad0a75a181e4'
    where workeruuid = tempworkeruuid
    returning workerinstanceuuid into create_adminuuid;

    RAISE NOTICE 'inserted worker';


    -- create the site. Could be migrate to the crud code.  I am just hardcoding for now.
-- insert the custag
-- Check if it exists first
    select custagid, custaguuid
    into tempcustagsitetypeid, tempcustagsitetypeuuid
    from custag
             inner join customer
                        on custagcustomerid = customerid
    where custagtype = tempsitename
      and (create_customeruuid = custagcustomeruuid
        or tempcustomerid = custagcustomerid);


    if tempcustagsitetypeid isNull
    then
        INSERT INTO public.languagemaster(languagemastercustomerid,
                                          languagemastersourcelanguagetypeid,
                                          languagemastersource,
                                          languagemastermodifiedby)
        VALUES (tempcustomerid, 20, tempsitename, create_modifiedby)
        Returning languagemasterid into templanguagemasterid;

        INSERT INTO public.custag(custagcustomerid,
                                  custagcustomeruuid,
                                  custagsystagid,
                                  custagsystaguuid,
                                  custagnameid,
                                  custagtype,
                                  custagstartdate,
                                  custagmodifiedby)
        VALUES (tempcustomerid,
                create_customeruuid,
                713,
                '9e5d9651-f928-4fcd-a1b7-e4027ea774ce',
                templanguagemasterid,
                tempsitename,
                clock_timestamp(),
                create_modifiedby)
        Returning custagid, custaguuid into tempcustagsitetypeid, tempcustagsitetypeuuid;

    end if;

-- see if the site exists already
    select locationid, locationuuid
    into tempsiteid, tempsiteuuid
    from view_location
    where locationcustomerid = tempcustomerid
      and locationcategoryid = tempcustagsitetypeid
      and locationistop = true
      and locationfullname = create_sitename
      and languagetranslationtypeid = templanguagetypeidid;

    if create_timezone isNull
    then
        templocationtimezone = 'UTC';
    Else
        templocationtimezone = create_timezone;
    End if;

    if tempsiteid isNull
    then
        INSERT INTO public.languagemaster(languagemastercustomerid,
                                          languagemastersourcelanguagetypeid,
                                          languagemastersource,
                                          languagemastermodifiedby)
        VALUES (tempcustomerid, templanguagetypeidid, tempsitename, create_modifiedby)
        Returning languagemasterid into templanguagemasterid;

        INSERT INTO public.location(locationcustomerid,
                                    locationlookupname,
                                    locationistop,
                                    locationiscornerstone,
                                    locationneedstranslation,
                                    locationcategoryid,
                                    locationstartdate,
                                    locationnameid,
                                    locationtimezone,
                                    locationmodifiedby)
        values (tempcustomerid,
                tempsitename,
                TRUE,
                TRUE,
                FALSE,
                tempcustagsitetypeid,
                clock_timestamp(),
                templanguagemasterid,
                templocationtimezone,
                create_modifiedby)
        Returning locationid, locationuuid into tempsiteid, create_siteuuid;

        update location
        set locationsiteid        = locationid,
            locationparentid      = locationid,
            locationcornerstoneid = locationid
        where locationid = tempsiteid;
    end if;

    RAISE NOTICE 'inserted site';

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_customer_create(text,text,text,text,text,text,text,text,text,text,text,text[],bigint) TO bombadil WITH GRANT OPTION;

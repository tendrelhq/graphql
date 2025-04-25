
-- Type: PROCEDURE ; Name: entity.crud_admin_create(text,text,text,text,text,uuid,uuid,uuid[],bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE entity.crud_admin_create(INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid uuid, OUT create_adminid bigint, OUT create_adminuuid text, IN create_customerentityuuid uuid, IN create_languagetypeuuids uuid[], IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare

-- Customer temp values
    tempcustomerid                 bigint;
	tempcustomeruuid				text;
	tempcustomerentityuuid			uuid;
    tempbillingsystemid            bigint;
-- Worker Temp Values
    tempidentitysystemid           text;
    tempworkeridentitysystemid     bigint;
    tempusername                   text;
    tempworkeruuid                 text;
-- General temp values
    templanguagemasterid           bigint;
	templanguagemasteruuid 			text;
    templanguagetypeuuid           text;
    templanguagetypeid           bigint;
	englishuuid uuid;
	tempcustomerdeleted boolean;
	tempcustomerdraft boolean;
	tempworkeridentitysystemuuid text;

Begin

englishuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';

-- setup language
	if create_languagetypeuuids isNull
		then templanguagetypeid = 20;
		Else select systagid, systaguuid
				into templanguagetypeid, templanguagetypeuuid
				from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,englishuuid)
				where systagentityuuid = create_languagetypeuuids[1]	
			; 
	end if;

    templanguagetypeuuid = (select systaguuid
                            from systag
                            where systagid = templanguagetypeid);

-- setup customer info
if create_customerentityuuid isNull
	then return;
	else tempcustomerentityuuid = create_customerentityuuid;
end if;

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,tempcustomerentityuuid,null,false,null,null,null, null);

-- probably return an error if the entity is not set to a customer.  Need to sort this out.  
if tempcustomerid isNull
	then return;
end if;

    -- Add dummy values for admin if necessary

    if create_adminfirstname isNull
    then
        create_adminfirstname = 'Unknown';
    End if;

    if create_adminlastname isNull
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

	select systagid, systaguuid
	into tempworkeridentitysystemid, tempworkeridentitysystemuuid
	from entity.crud_systag_read_min(null,null,null, null, true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9') as lang
	where systagentityuuid = create_adminidentitysystemuuid;	
									
    tempworkeruuid = (select workeruuid
                      from worker
                      where workeridentityid = create_adminidentityid
                        and workeridentitysystemuuid = tempworkeridentitysystemuuid);

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
                templanguagetypeid,
                tempusername,
                create_adminidentityid,
                tempworkeridentitysystemid,
                tempworkeridentitysystemuuid,
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
           tempcustomeruuid,
           clock_timestamp(),
           templanguagetypeid,
           templanguagetypeuuid,
           workerusername,
           systagid,
           systaguuid,
           create_modifiedby
    from worker
             inner join systag
                        on systaguuid = '1d8c3097-23f5-4cac-a4c5-ad0a75a181e4'
    where workeruuid = tempworkeruuid
    returning workerinstanceuuid,workerinstanceid  into create_adminuuid,create_adminid;

    RAISE NOTICE 'inserted worker';

End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.crud_admin_create(text,text,text,text,text,uuid,uuid,uuid[],bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_admin_create(text,text,text,text,text,uuid,uuid,uuid[],bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.crud_admin_create(text,text,text,text,text,uuid,uuid,uuid[],bigint) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON PROCEDURE entity.crud_admin_create(text,text,text,text,text,uuid,uuid,uuid[],bigint) TO graphql;

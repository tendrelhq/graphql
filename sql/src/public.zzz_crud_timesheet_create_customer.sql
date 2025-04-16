
-- Type: PROCEDURE ; Name: zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint); Owner: tendreladmin

CREATE OR REPLACE PROCEDURE public.zzz_crud_timesheet_create_customer(IN create_customername text, OUT create_customeruuid text, IN create_customerbillingid text, IN create_customerbillingsystemid text, INOUT create_adminfirstname text, INOUT create_adminlastname text, IN create_adminemailaddress text, IN create_adminphonenumber text, IN create_adminidentityid text, IN create_adminidentitysystemuuid text, OUT create_adminuuid text, OUT create_sitename text, IN create_timezone text, IN create_languagetypeuuid text, IN create_modifiedby bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
-- Custoemr temp values
	tempcustomerid bigint;
	tempbillingsystemid bigint;
-- Worker Temp Values
	tempidentitysystemid text;
	tempworkeridentitysystemid bigint; 
	tempusername text;
	tempworkeruuid text;
-- Site/Location temp valules
	tempcustagsitetypeid bigint;
	tempsiteid bigint;
	tempsitelanguagemasterid bigint; 
	tempcustagentrytypeid bigint;
	tempcustagentrytypeuuid text;
	tempentryid bigint;
	tempcustagbreaktypeid bigint;
	tempcustagbreaktypeuuid text;
	tempbreakid bigint;
-- template, instance and result
	tempworktemplateid bigint;
	tempworktemplateuuid text;
	tempworkfrequencyid bigint;
	tempworkresultid bigint;
	tempworkinstanceid bigint;
-- General temp values
	templanguagemasterid bigint;
	templocationtimezone text;
	templanguagetypeidid  bigint;

Begin

-- create the initial customer
-- ideally this can be CRUD for customer, but here I am just hardcoding it

create_customeruuid = ( select customeruuid 
						from view_customer cust
						where cust.customername = create_customername
							and cust.languagetranslationtypeid = 20);

-- If the customer already exists we return.  Should we send an error?  At this point we will just return.  

if create_customeruuid notNull
	then
		return;
End if;

-- Need to check for admin check early as well

if (create_adminemailaddress isNull and create_adminphonenumber isNull)
	then
		return;
End if;

if (create_adminidentityid isNull)
	then
		return;
End if;

tempbillingsystemid = (select systagid 
					  from systag
					  where systaguuid = create_customerbillingsystemid);

templanguagetypeidid = (select systagid 
					  from systag
					  where systaguuid = create_languagetypeuuid);

-- Insert the customer and get back the customeruuid.  

INSERT INTO public.customer(
	customername,
	customerstartdate,
	customerlanguagetypeid,
	customerlanguagetypeuuid,
	customernamelanguagemasterid,
	customerexternalid,	
	customerexternalsystemid,
	customerexternalsystemuuid,
	customermodifiedby
)
VALUES ( create_customername, 
		clock_timestamp(), 
		templanguagetypeidid, 
		create_languagetypeuuid,
		4367,	
		create_customerbillingid, 
		tempbillingsystemid, 
		create_customerbillingsystemid,
		create_modifiedby)
Returning customeruuid,customerid into create_customeruuid,tempcustomerid;   
-- Not sure if the above is allowed.  2 variables into 2 valiables

-- add customer name into languagemaster

INSERT INTO public.languagemaster(
	languagemastercustomerid, 
	languagemastersourcelanguagetypeid, 
	languagemastersource, 
	languagemastermodifiedby)
	VALUES (tempcustomerid,templanguagetypeidid,create_customername,create_modifiedby)
	Returning languagemasterid into templanguagemasterid;

-- Fix the Language Master iDs

update public.customer
set customernamelanguagemasterid = templanguagemasterid
where customerid = tempcustomerid;

-- Add the languagetype to customer reqeusted languages

insert into customerrequestedlanguage (
	customerrequestedlanguagecustomerid, 
	customerrequestedlanguagelanguageid,
	customerrequestedlanguagemodifiedby)  
values (tempcustomerid,templanguagetypeidid,create_modifiedby); 

-- Massage the Admin data for insert

if 	create_adminfirstname isNull
	then
		create_adminfirstname = 'Unkown';
End if;		
		
if 	create_adminfirstname isNull
	then
		create_adminlastname = 'Unkown';
End if;		
				
if create_adminemailaddress isNull 
	then
		tempusername = create_adminphonenumber;
		create_adminemailaddress = 'Unknown';		
	Else 
		tempusername = create_adminemailaddress;
End if;

-- insert the worker  
-- exand this to see if the worker exists?
-- i am assuming you can't get to here if the admin already existed

tempworkeridentitysystemid = (select systagid 
					  		from systag
					  		where systaguuid = create_adminidentitysystemuuid);

tempworkeruuid = (select workeruuid
				 	from worker 
				 	where workeridentityid = create_adminidentityid
				  		and workeridentitysystemuuid = create_adminidentitysystemuuid);
						

if tempworkeruuid isNull
	then
		INSERT INTO public.worker(
			workerlastname, 
			workerfirstname, 
			workeremail, 
			workerstartdate, 
			workerfullname, 
			workerlanguageid, 
			workerusername, -- this is email or phone number
			workerpassword,  -- We probably should dump this, but it is required right now. 
			workeridentityid,
			workeridentitysystemid,
			workeridentitysystemuuid,
			workermodifiedby)
		values( 
			create_adminlastname,
			create_adminfirstname,  
			create_adminemailaddress,
			clock_timestamp(),
			create_adminfirstname||' '||create_adminlastname, 
			templanguagetypeidid,
			tempusername,
			tempusername,  -- We probably should dump this, but it is required right now.  
			create_adminidentityid,  
			tempworkeridentitysystemid,
			create_adminidentitysystemuuid, 
			create_modifiedby)	
		Returning workeruuid into tempworkeruuid;
end if;

-- insert the worker instance

INSERT INTO public.workerinstance(
	workerinstanceworkerid, 
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
select 
	workerid,
	workeruuid,
	tempcustomerid,
	create_customeruuid,
	clock_timestamp(),
	templanguagetypeidid,
	create_languagetypeuuid,
	workerusername,  
	systagid,
	systaguuid,
	create_modifiedby
from worker
	inner join systag
		on systaguuid = '1d8c3097-23f5-4cac-a4c5-ad0a75a181e4'
where workeruuid = tempworkeruuid
returning  workerinstanceuuid into create_adminuuid;

-- create the site. Could be migrate to the crud code.  I am just hardcoding for now. 
-- insert the custag 
-- Check if it exists first

tempcustagsitetypeid = (select custagid 
						from custag 
							inner join customer
								on custagcustomerid = customerid
						where custagtype = 'site'
							and (create_customeruuid = custagcustomeruuid
								or tempcustomerid = custagcustomerid));

if tempcustagsitetypeid isNull
	then 
		INSERT INTO public.languagemaster(
			languagemastercustomerid, 
			languagemastersourcelanguagetypeid, 
			languagemastersource, 
			languagemastermodifiedby)
			VALUES (tempcustomerid,20,'site',create_modifiedby)
			Returning languagemasterid into templanguagemasterid;
	
		INSERT INTO public.custag(
			custagcustomerid,
			custagcustomeruuid, 
			custagsystagid,
			custagsystaguuid,
			custagnameid, 			
			custagtype, 
			custagstartdate, 
			custagmodifiedby
			)
			VALUES (
				tempcustomerid,
				create_customeruuid, 
				713,
				'9e5d9651-f928-4fcd-a1b7-e4027ea774ce',
				templanguagemasterid,
				'site',
				clock_timestamp(),
				create_modifiedby)
		Returning custagid into tempcustagsitetypeid;
		
end if;

-- see if the site exists already

tempsiteid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagsitetypeid
			 	and locationistop = true
			 	and locationfullname = create_sitename
			 	and languagetranslationtypeid = templanguagetypeidid);

if create_timezone isNull
	then 
		templocationtimezone = 'UTC';
	Else 
		templocationtimezone = create_timezone;
End if;

if tempsiteid isNull
	then
		INSERT INTO public.languagemaster(
			languagemastercustomerid, 
			languagemastersourcelanguagetypeid, 
			languagemastersource, 
			languagemastermodifiedby)
		VALUES (tempcustomerid,templanguagetypeidid,'site',create_modifiedby)
		Returning languagemasterid into templanguagemasterid;
		
		INSERT INTO public.location(
			locationcustomerid,
			locationlookupname,
			locationistop,
			locationiscornerstone,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationmodifiedby)
		values(	
			tempcustomerid,
			'site',
			TRUE,
			FALSE,
			FALSE,
			tempcustagsitetypeid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   
			create_modifiedby)
		Returning locationid into tempsiteid;

		update location 
		set locationsiteid = locationid,
			locationparentid = locationid
		where locationid = tempsiteid;
end if;

				
-- create the entry. Could be migrate to the crud code.  I am just hardcoding for now. 
-- insert the custag 
-- Check if it exists first

tempcustagentrytypeid = (select custagid 
						from custag 
							inner join customer
								on custagcustomerid = customerid
						where custagtype = 'entry'
							and (create_customeruuid = custagcustomeruuid
								or tempcustomerid = custagcustomerid));

if tempcustagentrytypeid isNull
	then 
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			   tempsiteid,
			20, 	
			'entry',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid,
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				create_customeruuid,
				713,  -- Systagid for Location Category
				'9e5d9651-f928-4fcd-a1b7-e4027ea774ce', -- Systaguuid for Location Category
				templanguagemasterid, 
				'entry',
				clock_timestamp(),
				create_modifiedby)
		Returning custagid,custaguuid into tempcustagentrytypeid,tempcustagentrytypeuuid;

				
end if;

-- see if the entry exists already

tempentryid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagentrytypeid
			  	and locationparentid = tempsiteid
			 	and locationistop = false
			 	and locationfullname = 'entry'
			 	and languagetranslationtypeid = 20);

if tempentryid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			tempsiteid,
			20,
			'entry',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationsiteid,
			locationparentid,
			locationlookupname,
			locationscanid,
			locationistop,
			locationiscornerstone,
			locationcornerstoneorder,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationmodifiedby)
		values(	
			tempcustomerid,
			tempsiteid,
			tempsiteid,
			'entry',
			'ENT01',
			FALSE,
			TRUE,
			1,			
			FALSE,
			tempcustagentrytypeid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   
			create_modifiedby)
		Returning locationid into tempentryid;
						 
		update location
		set locationcornerstoneid = tempentryid
		where locationid = tempentryid;

end if;

-- create the break. Could be migrate to the crud code.  I am just hardcoding for now. 
-- insert the custag 
-- Check if it exists first

tempcustagbreaktypeid = (select custagid 
						from custag 
							inner join customer
								on custagcustomerid = customerid
						where custagtype = 'break'
							and (create_customeruuid = custagcustomeruuid
								or tempcustomerid = custagcustomerid));

if tempcustagbreaktypeid isNull
	then 
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			   tempsiteid,
			20, 	
			'break',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.custag(
				custagcustomerid, 
				custagcustomeruuid,
				custagsystagid,
				custagsystaguuid,
				custagnameid, 
				custagtype,
				custagstartdate,
				custagmodifiedby
				)
		values (tempcustomerid,
				create_customeruuid,
				713,  -- Systagid for Location Category
				'9e5d9651-f928-4fcd-a1b7-e4027ea774ce', -- Systaguuid for Location Category
				templanguagemasterid, 
				'break',
				clock_timestamp(),
				create_modifiedby)
		Returning custagid,custaguuid into tempcustagbreaktypeid,tempcustagbreaktypeuuid;
				
end if;

-- see if the break exists already

tempbreakid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagbreaktypeid
			  	and locationparentid = tempsiteid
			 	and locationistop = false
			 	and locationfullname = 'break'
			 	and languagetranslationtypeid = 20);

if tempbreakid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			 languagemastercustomersiteid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			tempsiteid,
			20,
			'break',
			create_modifiedby)
		Returning languagemasterid into templanguagemasterid;

		INSERT INTO public.location(
			locationcustomerid,
			locationsiteid,
			locationparentid,
			locationlookupname,
			locationscanid,
			locationistop,
			locationiscornerstone,
			locationcornerstoneorder,
			locationneedstranslation,
			locationcategoryid,
			locationstartdate,
			locationnameid,
			locationtimezone,
			locationmodifiedby)
		values(	
			tempcustomerid,
			tempsiteid,
			tempsiteid,
			'break',
			'BRE01',
			FALSE,
			TRUE,
			1,			
			FALSE,
			tempcustagbreaktypeid,
			clock_timestamp(),  
			templanguagemasterid,
			templocationtimezone,   
			create_modifiedby)
		Returning locationid into tempbreakid;
						 
		update location
		set locationcornerstoneid = tempbreakid
		where locationid = tempbreakid;

end if;

-- Add in worktemplates for the site id and location types
-- Add in Clock IN/OUT with entry location type

insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Clock IN/OUT',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.worktemplate(
	worktemplatecustomerid,
	worktemplatesiteid,
	worktemplatenameid,
	worktemplateneedstranslation,
	worktemplateallowondemand,
	worktemplateworkfrequencyid,
	worktemplatemodifiedby)
values
	(tempcustomerid,
	tempsiteid,
	templanguagemasterid,
	FALSE,
	TRUE,
	1, -- this is placeholder for the frequencyid we are about to create
	create_modifiedby
	)
Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

-- Add in the workfrequency for the template

INSERT INTO public.workfrequency(
	workfrequencyworktemplateid,
	workfrequencycustomerid,
	workfrequencytypeid,
	workfrequencyvalue,
	workfrequencystartdate,
	workfrequencymodifiedby)
values 
	(tempworktemplateid,
	tempcustomerid,
	740,
	1,
	clock_timestamp(),
	create_modifiedby
	)
Returning workfrequencyid into tempworkfrequencyid;

update worktemplate w
set worktemplateworkfrequencyid = tempworkfrequencyid
where worktemplateid = tempworktemplateid;

-- add the contraints

INSERT INTO worktemplateconstraint (
    worktemplateconstraintcustomerid,
	worktemplateconstraintcustomeruuid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintconstraintid,     -- Location Type in custag
    worktemplateconstraintconstrainedtypeid, -- Constraint type in systag
    worktemplateconstraintmodifiedby
)
values (tempcustomerid,
		create_customeruuid,
		tempworktemplateuuid,
		tempcustagbreaktypeuuid,
		'd8dfd8de-ffdc-4472-8d38-171351668e9d',
		create_modifiedby
		);
		
-- Next template for in progress

INSERT INTO public.worktemplatenexttemplate(
  worktemplatenexttemplateprevioustemplateid,
  worktemplatenexttemplatenexttemplateid,
  worktemplatenexttemplatecustomerid,
  worktemplatenexttemplateviastatuschange,
  worktemplatenexttemplateviastatuschangeid,
  worktemplatenexttemplatesiteid,
  worktemplatenexttemplatetypeid,
	worktemplatenexttemplatemodifiedby
)
values(tempworktemplateid,
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

-- Add in workresults here
--"Time At Task"

INSERT INTO public.workresult(
  workresultworktemplateid,
  workresultcustomerid,
  workresultsiteid,
  workresultfortask,
  workresultforaudit,
  workresulttypeid,
  workresultlanguagemasterid,
  workresultorder,
  workresultisvisible,
	workresultmodifiedby
 )
values(
	tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Override By',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
	create_modifiedby);

-- Add in instances 
-- timesheet only has ondemand

INSERT INTO public.workinstance(
	workinstancecustomerid,
	workinstanceworktemplateid,
	workinstancesiteid,
	workinstancetypeid,
	workinstancestatusid,
	workinstancetargetstartdate,
	workinstancetimezone,
	workinstancerefid, -- put location here to start
	workinstancemodifiedby)
values(
	tempcustomerid,
	tempworktemplateid,
	tempsiteid,
	811,  -- this is the work type for task.
	706,  -- this is the status for Open.
	clock_timestamp(),
	templocationtimezone,
	tempentryid,
	create_modifiedby)
Returning workinstanceid into tempworkinstanceid;

update workinstance
set workinstanceoriginatorworkinstanceid = workinstanceid
where  workinstancecustomerid = tempcustomerid
	and workinstanceoriginatorworkinstanceid isNull;
	
-- Insert for tasks
INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstanceworkresultid,
	workresultinstancevalue,
	workresultinstancemodifiedby
)
values (
	tempworkinstanceid,
	tempcustomerid,
	tempworkresultid,
	tempentryid,
	create_modifiedby);

-- Add in Break IN/OUT with entry location type

insert into public.languagemaster
	(languagemastercustomerid,
	 languagemastercustomersiteid,
	languagemastersourcelanguagetypeid,
	languagemastersource,
	languagemastermodifiedby)
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Break IN/OUT',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.worktemplate(
	worktemplatecustomerid,
	worktemplatesiteid,
	worktemplatenameid,
	worktemplateneedstranslation,
	worktemplateallowondemand,
	worktemplateworkfrequencyid,
	worktemplatemodifiedby)
values
	(tempcustomerid,
	tempsiteid,
	templanguagemasterid,
	FALSE,
	TRUE,
	1, -- this is placeholder for the frequencyid we are about to create
	create_modifiedby
	)
Returning worktemplateid,id into tempworktemplateid, tempworktemplateuuid;

-- Add in the workfrequency for the template

INSERT INTO public.workfrequency(
	workfrequencyworktemplateid,
	workfrequencycustomerid,
	workfrequencytypeid,
	workfrequencyvalue,
	workfrequencystartdate,
	workfrequencymodifiedby)
values 
	(tempworktemplateid,
	tempcustomerid,
	740,
	1,
	clock_timestamp(),
	create_modifiedby
	)
Returning workfrequencyid into tempworkfrequencyid;

update worktemplate w
set worktemplateworkfrequencyid = tempworkfrequencyid
where worktemplateid = tempworktemplateid;

-- add the contraints

INSERT INTO worktemplateconstraint (
    worktemplateconstraintcustomerid,
	worktemplateconstraintcustomeruuid,
    worktemplateconstrainttemplateid,
    worktemplateconstraintconstraintid,     -- 'Row'
    worktemplateconstraintconstrainedtypeid, -- Location
    worktemplateconstraintmodifiedby
)
values (tempcustomerid,
		create_customeruuid,
		tempworktemplateuuid,
		tempcustagentrytypeuuid,
		'd8dfd8de-ffdc-4472-8d38-171351668e9d',
		create_modifiedby
		);

-- Next template for in progress

INSERT INTO public.worktemplatenexttemplate(
  worktemplatenexttemplateprevioustemplateid,
  worktemplatenexttemplatenexttemplateid,
  worktemplatenexttemplatecustomerid,
  worktemplatenexttemplateviastatuschange,
  worktemplatenexttemplateviastatuschangeid,
  worktemplatenexttemplatesiteid,
  worktemplatenexttemplatetypeid,
	worktemplatenexttemplatemodifiedby
)
values(tempworktemplateid,
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

INSERT INTO public.workresult(
  workresultworktemplateid,
  workresultcustomerid,
  workresultsiteid,
  workresultfortask,
  workresultforaudit,
  workresulttypeid,
  workresultlanguagemasterid,
  workresultorder,
  workresultisvisible,
	workresultmodifiedby
 )
values(
	tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Start Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'End Override',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Override By',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Location',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
values(
	tempcustomerid,
	tempsiteid,
	20,
	'Worker',
	create_modifiedby)
Returning languagemasterid into templanguagemasterid;

INSERT INTO public.workresult(
	workresultworktemplateid, 
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
values(
  tempworktemplateid,
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
	create_modifiedby);

-- Add in instances 
-- timesheet only has ondemand

INSERT INTO public.workinstance(
	workinstancecustomerid,
	workinstanceworktemplateid,
	workinstancesiteid,
	workinstancetypeid,
	workinstancestatusid,
	workinstancetargetstartdate,
	workinstancetimezone,
	workinstancerefid, -- put location here to start
	workinstancemodifiedby)
values(
	tempcustomerid,
	tempworktemplateid,
	tempsiteid,
	811,  -- this is the work type for task.
	706,  -- this is the status for Open.
	clock_timestamp(),
	templocationtimezone,
	tempentryid,
	create_modifiedby)
Returning workinstanceid into tempworkinstanceid;
	
update workinstance
set workinstanceoriginatorworkinstanceid = workinstanceid
where  workinstancecustomerid = tempcustomerid
	and workinstanceoriginatorworkinstanceid isNull;
	
-- Insert for tasks
INSERT INTO public.workresultinstance(
	workresultinstanceworkinstanceid,
	workresultinstancecustomerid,
	workresultinstanceworkresultid,
	workresultinstancevalue,
	workresultinstancemodifiedby
)
values (
	tempworkinstanceid,
	tempcustomerid,
	tempworkresultid,
	tempentryid,
	create_modifiedby);

-- Cleanup widget and format
-- Number
update workresult
set workresultwidgetid = 407, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=701 
and workresultwidgetid is null;

-- Clicker
update workresult
set workresultwidgetid = 406,
workresulttypeid = 701, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=700 
and workresultwidgetid is null;

-- boolean
update workresult
set workresultwidgetid = 414, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=754 
and workresultwidgetid is null;

-- tat
update workresult
set workresultwidgetid = 413, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=737 
and workresultwidgetid is null;

--Text
update workresult
set workresultwidgetid = 408, 
workresulttypeid = 771,
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=702 
and workresultwidgetid is null;

--Sentiment
update workresult
set workresultwidgetid = 410, 
workresulttypeid = 701,
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=704 
and workresultwidgetid is null;

--String
update workresult
set workresultwidgetid = 412, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=771 
and workresultwidgetid is null;

-- entity
update workresult
set workresultwidgetid = 415, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=848 
and workresultwidgetid is null;

-- date
update workresult
set workresultwidgetid = 419, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=868 
and workresultwidgetid is null;

-- Geolocation
update workresult
set workresultwidgetid = 463,
workresulttypeid = 771, 
	workresultmodifieddate = clock_timestamp()
where workresulttypeid=890 
and workresultwidgetid is null;

-- Add in customerconfigs

commit;

End;

$procedure$;


REVOKE ALL ON PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE zzz_crud_timesheet_create_customer(text,text,text,text,text,text,text,text,text,text,text,bigint) TO tendreladmin WITH GRANT OPTION;

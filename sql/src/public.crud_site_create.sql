
-- Type: PROCEDURE ; Name: crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint); Owner: bombadil

CREATE OR REPLACE PROCEDURE public.crud_site_create(IN create_customeruuid text, IN create_customerexternalid text, IN create_customerexternalsystemuuid text, IN create_sitename text, IN create_sitetype text, IN create_siteexternaluuid text, IN create_siteexternalsystemuuid text, IN create_locationtimezone text, IN create_languagetypeuuid text, IN create_modifiedbyid bigint, INOUT tempsiteid bigint)
 LANGUAGE plpgsql
AS $procedure$
Declare
   	templanguagemasterid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
	tempcustagid bigint;
	tempcustaguuid text;
	templocationtimezone text;
	templanguagetypeid bigint;
	tempsiteexternalsystemid bigint;
Begin

-- We could harden this by checking for valid data at the beginning of this call.  Will do this as phase 2.  
	-- Must have a valid customerid or customerexternalid
	-- Site Name and Site type can not be null or ''
	-- languagetype id must be a valid languagetypeid
	-- locationtimezone must be a legit timezone
	-- modified by id gets defaulted if it is not passed in (Maybe validate this)
	-- Could check all this and return null if any of these fail

-- You have to create a customer with a dummy languagemasterid

-- Set the customerid if it is null

tempcustomeruuid = (select customeruuid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

tempcustomerid = (select customerid
					from customer
					where (create_customeruuid = customeruuid 
						or (create_customerexternalid = customerexternalid
						and create_customerexternalsystemuuid = customerexternalsystemuuid)));

-- insert the custag 

templanguagetypeid = (select systagid 
					  from systag
					  where systaguuid = create_languagetypeuuid);

tempcustaguuid = (select custaguuid from custag 
					where custagtype = create_sitetype
						and custagcustomeruuid = tempcustomeruuid);

tempcustagid = (select custagid from custag 
					where custagtype = create_sitetype
						and custagcustomeruuid = tempcustomeruuid);

tempsiteexternalsystemid = (select systagid from systag
					where systaguuid = create_siteexternalsystemuuid);

if tempcustaguuid isNull
	then 
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
				tempcustomeruuid,
				713,  -- Systagid for Location Category	
				(select systaguuid from systag where systagid = 713),
				4367, -- dummy variable
				create_sitetype,
				now(),
				create_modifiedbyid)
				Returning custaguuid, custagid into tempcustaguuid,tempcustagid;
				
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(tempcustomerid,
			templanguagetypeid, 	
			create_sitetype,
			create_modifiedbyid)
		Returning languagemasterid into templanguagemasterid;

		-- Set the CustTag table to reference the correct translations

		update public.custag
		set custagnameid= templanguagemasterid
		where custaguuid = tempcustaguuid    
			and custagcustomeruuid = tempcustomeruuid;				
				
end if;

-- see if the site exists already

tempsiteid = (select locationid
			 from view_location
			 where locationcustomerid = tempcustomerid
			  	and locationcategoryid = tempcustagid
			 	and locationistop = true
			 	and locationfullname = create_sitename
			 	and languagetranslationtypeid = templanguagetypeid);

if create_locationtimezone isNull
	then 
		templocationtimezone = 'UTC';
	Else 
		templocationtimezone = create_locationtimezone;
End if;

if tempsiteid isNull
	then
		insert into public.languagemaster
			(languagemastercustomerid,
			languagemastersourcelanguagetypeid,
			languagemastersource,
			languagemastermodifiedby)
		values(
			tempcustomerid,
			templanguagetypeid,
			create_sitename,
			create_modifiedbyid)
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
			locationexternalid,
			locationexternalsystemid,			
			locationmodifiedby)
		values(	
			tempcustomerid,
			create_sitename,
			TRUE,
			FALSE,
			FALSE,
			tempcustagid,
			now(),  --normally timestamp is now()
			templanguagemasterid,
			templocationtimezone,   -- https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
			create_siteexternaluuid,	
			tempsiteexternalsystemid,
			create_modifiedbyid)
		Returning locationid into tempsiteid;

		update location 
		set locationsiteid = locationid,
			locationparentid = locationid
		where locationid = tempsiteid;
	end if;

commit;

-- Add in a tendy event for creation.  Maybe add templateid as a note?  

End;

$procedure$;


REVOKE ALL ON PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint) TO PUBLIC;
GRANT EXECUTE ON PROCEDURE crud_site_create(text,text,text,text,text,text,text,text,text,bigint,bigint) TO bombadil WITH GRANT OPTION;

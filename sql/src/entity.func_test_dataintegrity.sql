
-- Type: FUNCTION ; Name: entity.func_test_dataintegrity(bigint,bigint,boolean,text,text); Owner: bombadil

CREATE OR REPLACE FUNCTION entity.func_test_dataintegrity(test_failedtestcount bigint, test_successtestcount bigint, test_failedtest boolean, test_passedtext text, test_failedtext text)
 RETURNS TABLE(failedtestcount bigint, successtestcount bigint, failedtest boolean, passedtext text, failedtext text)
 LANGUAGE plpgsql
AS $function$
Declare
    fact_end timestamp with time zone;
	next_start timestamp with time zone;
Begin

/*
call entity.import_entity('all time');

select * from entity.func_test_entity();

select * from entity.func_test_dataintegrity(
	0::bigint, 
	0::bigint, 
	false, 
	'', 
	''
	)
*/

fact_end = clock_timestamp();

-- Create Header for testing data integrity 
----------------------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'header','testing data integrity',next_start,true ) as foo;	
		
-- Create Section for entity template validations 
----------------------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'section','entity template validations',next_start,true ) as foo;

-- valid entity template type
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','valid entity template type',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.entitytemplate et left join  (select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) sys on systagentityuuid = entitytemplatetypeentityuuid and systagparententityuuid = ''b07bf96e-0a35-4b01-bcc0-863dc7b3db0c'' where systagentityuuid isNull) < 1',
		next_start, ((select count(*) from entity.entitytemplate et
						left join  (select * from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) sys
							on systagentityuuid = entitytemplatetypeentityuuid
								and systagparententityuuid = 'b07bf96e-0a35-4b01-bcc0-863dc7b3db0c'
							where systagentityuuid isNull) < 1)) as foo;

-- entity template parents not null
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entity template parents not null',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.entitytemplate et where entitytemplateparententityuuid isNull) = 0',
		next_start, ((select count(*) from entity.entitytemplate et where entitytemplateparententityuuid isNull) < 1)) as foo;

-- template external system valid
	-- Not done yet
-- Need to come back to this.  How do we validate extrnal system?
	-- Not done yet
		
-- Create Section for entity field validations 
----------------------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'section','entity field validations',next_start,true ) as foo;

-- entity field parents not null
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entity field parents not null',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.entityfield et where entityfieldparententityuuid isNull) = 0',
		next_start, ((select count(*) from entity.entityfield et where entityfieldparententityuuid isNull) < 1)) as foo;


/*

-- make sure it is a customer?
    CONSTRAINT entityfieldcustomerentityuuid_enitityinstance_fk FOREIGN KEY (entityfieldownerentityuuid)
        REFERENCES entity.entityinstance (entityinstanceuuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

-- tempalte or field
    CONSTRAINT entityfieldentityparenttypeentityuuid_entityinstance_fk FOREIGN KEY (entityfieldentityparenttypeentityuuid)
        REFERENCES entity.entityinstance (entityinstanceuuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

-- valid type and not null
    CONSTRAINT entityfieldentitytypeentityuuid_entityinstance_fk FOREIGN KEY (entityfieldentitytypeentityuuid)
        REFERENCES entity.entityinstance (entityinstanceuuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

-- valid system???		
    CONSTRAINT entityfieldexternalsystementityuuid_entityinstance_fk FOREIGN KEY (entityfieldexternalsystementityuuid)
        REFERENCES entity.entityinstance (entityinstanceuuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

-- valid format		
    CONSTRAINT entityfieldformatentityuuid_entityinstance_fk FOREIGN KEY (entityfieldformatentityuuid)
        REFERENCES entity.entityinstance (entityinstanceuuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,

-- valid widget - not null
    CONSTRAINT entityfieldwidgetentityuuid_entityinstance_fk FOREIGN KEY (entityfieldwidgetentityuuid)
        REFERENCES entity.entityinstance (entityinstanceuuid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID

-- entity tag

	
    entitytagownerentityuuid uuid NOT NULL,
		-- FK

    entitytagentityinstanceentityuuid uuid,
		-- FK
		
    entitytagentitytemplateentityuuid uuid,
		-- FK
		
    entitytagcustagentityuuid uuid NOT NULL,
		-- FK
		
*/

-- entity instance

-- entity field instance

-- customer

-- location

-- systag

-- custag

    next_start = clock_timestamp();

-- Create Section for min and full equaling each other 
----------------------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'section','entity min and full read functions equal each other',next_start,true ) as foo;

-- custag min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','custag min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) = (select count(*) from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''))',
		next_start, (select count(*) from entity.crud_custag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = (select count(*) from entity.crud_custag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo;

-- customer min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','customer min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_customer_read_full(null,null, null, true,null,null, null, null)) = (select count(*) from entity.crud_customer_read_min(null,null, null, true,null,null, null, null))',
		next_start, (select count(*) from entity.crud_customer_read_full(null,null, null, true,null,null, null, null)) = (select count(*) from entity.crud_customer_read_min(null,null, null, true,null,null, null, null))) as foo;

-- entitydescription min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entitydescription min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entitydescription_read_min(null, null, null,null, null, null,null,null)) = (select count(*) from entity.crud_entitydescription_read_full(null, null, null,null, null, null,null,null))',
		next_start, (select count(*) from entity.crud_entitydescription_read_min(null, null, null,null, null, null,null,null)) = (select count(*) from entity.crud_entitydescription_read_full(null, null, null,null, null, null,null,null))) as foo;

-- entityfield min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entityfield min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entityfield_read_full(null, null, null,null, null, null,null)) = (select count(*) from entity.crud_entityfield_read_min(null, null, null,null, null, null,null))',
		next_start, (select count(*) from entity.crud_entityfield_read_full(null, null, null,null, null, null,null)) = (select count(*) from entity.crud_entityfield_read_min(null, null, null,null, null, null,null))) as foo;

-- entityfieldinstance min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entityfieldinstance min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entityfieldinstance_read_full(null,null,null,true,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) = (select count(*) from entity.crud_entityfieldinstance_read_min(null,null,null,true,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''))',
		next_start, (select count(*) from entity.crud_entityfieldinstance_read_full(null,null,null,true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = (select count(*) from entity.crud_entityfieldinstance_read_min(null,null,null,true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo;

-- entityfileinstance min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entityfileinstance min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entityfileinstance_read_full(null, null, null,null, null, null,null,null)) = (select count(*) from entity.crud_entityfileinstance_read_min(null, null, null,null, null, null,null,null))',
		next_start, (select count(*) from entity.crud_entityfileinstance_read_full(null, null, null,null, null, null,null,null)) = (select count(*) from entity.crud_entityfileinstance_read_min(null, null, null,null, null, null,null,null))) as foo;

-- entityinstance  min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entityinstance min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entityinstance_read_full(null,null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) = (select count(*) from entity.crud_entityinstance_read_min(null,null,null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''))',
		next_start, (select count(*) from entity.crud_entityinstance_read_full(null,null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = (select count(*) from entity.crud_entityinstance_read_min(null,null,null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo;

-- entitytag  min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entitytag min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entitytag_read_full(null, null,null,null, null, true, null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) = (select count(*) from entity.crud_entitytag_read_min(null, null,null,null, null, true, null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''))',
		next_start, (select count(*) from entity.crud_entitytag_read_full(null, null,null,null, null, true, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = (select count(*) from entity.crud_entitytag_read_min(null, null,null,null, null, true, null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo;

-- entitytemplate  min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','entitytemplate min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_entitytemplate_read_full(null, null, null, null, null,null)) = (select count(*) from entity.crud_entitytemplate_read_min(null, null, null, null, null,null))',
		next_start, (select count(*) from entity.crud_entitytemplate_read_full(null, null, null, null, null,null)) = (select count(*) from entity.crud_entitytemplate_read_full(null, null, null, null, null,null))) as foo;

-- location min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','location min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) = (select count(*) from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''))',
		next_start, (select count(*) from entity.crud_location_read_full(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = (select count(*) from entity.crud_location_read_min(null,null,null,null,true,null,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo;

-- systag min and full equal
--------------------------------
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'test','systag min and full reads equal',next_start,true  ) as foo;
-- min = full test
SELECT foo.failedtestcount, foo.successtestcount, foo.failedtest, foo.passedtext, foo.failedtext, foo.next_start
	into test_failedtestcount, test_successtestcount, failedtest, test_passedtext, test_failedtext, next_start
FROM entity.util_test_createlog(test_failedtestcount,test_successtestcount,test_failedtest,test_passedtext,test_failedtext,
		'sql','(select count(*) from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')) = (select count(*) from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''))',
		next_start, (select count(*) from entity.crud_systag_read_full(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = (select count(*) from entity.crud_systag_read_min(null,null,null, null, true,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo;

return query
	select test_failedtestcount, test_successtestcount,test_failedtest, test_passedtext, test_failedtext;

End;

$function$;


REVOKE ALL ON FUNCTION entity.func_test_dataintegrity(bigint,bigint,boolean,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_dataintegrity(bigint,bigint,boolean,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.func_test_dataintegrity(bigint,bigint,boolean,text,text) TO bombadil WITH GRANT OPTION;


-- Type: PROCEDURE ; Name: entity.test_entity(); Owner: bombadil

CREATE OR REPLACE PROCEDURE entity.test_entity()
 LANGUAGE plpgsql
AS $procedure$
Declare
    fact_start timestamp with time zone;
    fact_end timestamp with time zone;	
	failedtest boolean;
Begin

 -- Start the timer on this function
    fact_start = clock_timestamp();
	failedtest = false;
-- Need to add full versions
-- call entity.test_entity()

-- entity templates
RAISE NOTICE  E'testing entity templates\n-------\n';

RAISE NOTICE  E'testing all customers all templates\n-------';

if (select count(*) from entity.func_entitytemplate_read_min(null, null, null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entitytemplate_read_min(null, null, null)> 0  Time: %', (clock_timestamp()-fact_start)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entitytemplate_read_min(null, null, null)> 0  Time: %', (clock_timestamp()-fact_start)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_read_full(null, null, null)) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_read_full(null, null, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_read_full(null, null, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customer all templates\n-------';

if (select count(*) from entity.func_entitytemplate_read_min(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_read_full(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null)) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customer specific entity template\n-------';

if (select count(*) from entity.func_entitytemplate_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null)) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null)= 1  Time: %', (clock_timestamp()-fact_end)::text;
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entitytemplate_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null)= 1  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','957df2f9-051f-4af5-95ee-ea3760fbb83b',	null)) = 1
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null)= 1  Time: %\n', (clock_timestamp()-fact_end)::text;
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null)= 1  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'negative test - empty or wrong cutomer returns no templates\n-------';

if (select count(*) from entity.func_entitytemplate_read_min(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',	null)) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entitytemplate_read_min(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',	null)= 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entitytemplate_read_min(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',	null)= 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_read_full(null,'957df2f9-051f-4af5-95ee-ea3760fbb83b',	null)) = 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_read_full(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null)= 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_read_full(null,''957df2f9-051f-4af5-95ee-ea3760fbb83b'',null)= 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

-- Entity Fields
RAISE NOTICE  E'testing entity fields\n-------\n';

RAISE NOTICE  E'testing all customers all template all fields\n-------';

if (select count(*) from entity.func_entityfield_read_min(null, null, null,null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_min(null, null, null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*)from entity.func_entityfield_read_min(null, null, null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_full(null, null, null,null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_full(null, null, null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*)from entity.func_entityfield_read_full(null, null, null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_field_read_full(null, null, null,null)) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_field_read_full(null, null, null,null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*)from entity.func_entitytemplate_field_read_full(null, null, null,null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing all customers all template all fields\n-------';

-- specific customer no entity template no field
if (select count(*) from entity.func_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null, null)) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null, null, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customers specific template all fields\n-------';

-- specific entity template
if (select count(*) from entity.func_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null)) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)> 0  Time: %\n\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customers specific template specific fields\n-------';

if (select count(*) from entity.func_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null)) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 1  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 1  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null)) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 1  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 1  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_field_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null)) = 1
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 1  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_field_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 1  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'negative tests - empty or wrong cutomer returns nothing\n-------';

if (select count(*) from entity.func_entityfield_read_min(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null)) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_min(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)= 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_min(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)= 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_min(null,null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null)) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_min(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_min(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_full(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null)) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)= 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)= 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entityfield_read_full(null,null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null)) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entityfield_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entityfield_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_field_read_full(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,null)) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entitytemplate_field_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)= 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entitytemplate_field_read_full(null,''b124da10-be8a-4d32-9f68-7f4e6e8b24e9'',null,null)= 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_entitytemplate_field_read_full(null,null,'d15bb9c2-0601-4e4f-9009-c791a40be191',null)) = 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_entitytemplate_field_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_entitytemplate_field_read_full(null,null,''d15bb9c2-0601-4e4f-9009-c791a40be191'',null)= 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

-- Systags
RAISE NOTICE  E'testing systags\n-------\n';

RAISE NOTICE  E'testing all customers all systags\n-------';

if (select count(*) from entity.func_systag_read_min(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_systag_read_min(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_systag_read_min(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'')> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_systag_read_full(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_systag_read_full(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_systag_read_full(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customer all systags\n-------';

if (select count(*) from entity.func_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing all systags for a parent\n-------';

if (select count(*) from entity.func_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_systag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_systag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_systag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing systag fail scenario for parent\n-------';

if (select count(*) from entity.func_systag_read_min(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_systag_read_min(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_systag_read_min(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_systag_read_full(null,null,null, '86be74b7-40df-4c20-9467-d35fae610c52', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_systag_read_full(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_systag_read_full(null,null,null, ''86be74b7-40df-4c20-9467-d35fae610c52'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific systags\n-------';

if (select count(*) from entity.func_systag_read_min(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_systag_read_min(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''=1)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_systag_read_min(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''=1)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_systag_read_full(null, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_systag_read_full(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'' = 1)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_systag_read_full(null, null, ''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'' = 1)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'\ntesting customer\n-------\n';

RAISE NOTICE  E'testing specific customer\n-------';

if (select count(*) from entity.func_customer_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',false, null)) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_customer_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',false, null)= 1  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_customer_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',false, null)= 1  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_customer_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',false, null)) = 1
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_customer_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',false, null)=1  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_customer_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',false, null)=1  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing all customers\n-------';

if (select count(*) from entity.func_customer_read_min(null,true, null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_customer_read_min(null,true, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_customer_read_min(null,true, null)> 0  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_customer_read_full(null,true, null)) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_customer_read_full(null,true, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_customer_read_full(null,true, null)> 0  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing location\n-------\n';

RAISE NOTICE  E'testing all customers all locations all tags\n-------';
if (select count(*) from entity.func_location_read_min(null,null,true,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_location_read_min(null,null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_location_read_min(null,null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_location_read_full(null,null,true,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_location_read_full(null,null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_location_read_full(null,null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customer all locations all tags\n-------';
if (select count(*) from entity.func_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,true,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_location_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,true,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customer all locations specific tags\n-------';
if (select count(*) from entity.func_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,true,'c557ca4c-184a-4958-a49a-260ca6f6ee07','bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,''c557ca4c-184a-4958-a49a-260ca6f6ee07'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,''c557ca4c-184a-4958-a49a-260ca6f6ee07'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_location_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,true,'c557ca4c-184a-4958-a49a-260ca6f6ee07','bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,''c557ca4c-184a-4958-a49a-260ca6f6ee07'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,true,''c557ca4c-184a-4958-a49a-260ca6f6ee07'',''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific locations specific tags\n-------';
if (select count(*) from entity.func_location_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','af4dc39d-7d4a-46a4-9ad0-980c23bff933',false,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',false,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_location_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',false,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_location_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61','af4dc39d-7d4a-46a4-9ad0-980c23bff933',false,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',false,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_location_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',''af4dc39d-7d4a-46a4-9ad0-980c23bff933'',false,null,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

-- custags  
RAISE NOTICE  E'testing custags\n-------\n';

RAISE NOTICE  E'testing all customers all custags \n-------';
if (select count(*) from entity.func_custag_read_min(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_custag_read_min(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_custag_read_min(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_custag_read_full(null,null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_custag_read_full(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_custag_read_full(null,null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific customers all custags \n-------';
if (select count(*) from entity.func_custag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, null, true,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, null, true,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing all custags for a parent\n-------';
if (select count(*) from entity.func_custag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) > 0 
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'',null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''> 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing fail scenario for parent\n-------';
if (select count(*) from entity.func_custag_read_min(null,null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_custag_read_min(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_custag_read_min(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_custag_read_full(null,null,null, 'cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba', false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_custag_read_full(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_custag_read_full(null,null,null, ''cb3dfd1a-e2f6-4d69-9483-ef6b79cf2eba'', false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing specific custags\n-------';
if (select count(*) from entity.func_custag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_custag_read_min(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_custag_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61', null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 1
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_custag_read_full(''f90d618d-5de7-4126-8c65-0afb700c6c61'', null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 1)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

RAISE NOTICE  E'testing fail for custags\n-------';
if (select count(*) from entity.func_custag_read_min(null, null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_custag_read_min(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_custag_read_min(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();
if (select count(*) from entity.func_custag_read_full(null, null, '444d946c-1180-4eb2-ae52-a429d096b9f1', null, false,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) = 0
	Then RAISE NOTICE E'Pass:  select count(*) from entity.func_custag_read_full(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %\n', (clock_timestamp()-fact_end)::text;	
	Else RAISE NOTICE E'Fail:  select count(*) from entity.func_custag_read_full(null, null, ''444d946c-1180-4eb2-ae52-a429d096b9f1'', null, false,''bcbe750d-1b3b-4e2b-82ec-448bb8b116f9''= 0)  Time: %\n', (clock_timestamp()-fact_end)::text;
		failedtest = true;
End If;
fact_end = clock_timestamp();

if failedtest = true
	then RAISE NOTICE E'Fail:  At least one test failed  Time: %\n', (clock_timestamp()-fact_start)::text;
	else RAISE NOTICE E'Pass:  All tests passed  Time: %\n', (clock_timestamp()-fact_start)::text;
end if;

/*

if (select count(*) from entity.func_entitytemplate_read_min(null, null, null)) > 0
	Then RAISE NOTICE 'Pass:  select count(*) from entity.func_entitytemplate_read_min(null, null, null)';	
	Else RAISE NOTICE 'Fail:  select count(*) from entity.func_entitytemplate_read_min(null, null, null)';
		failedtest = true;
End If;

-- Insert into the tendy tracker

    if (select dwlogginglevel2 from datawarehouse.dw_logginglevels) = false
    Then
        Return;
    end if;

    if intervaltype = '5 minute'
    Then
        call datawarehouse.insert_tendy_tracker(0, 2517, 12496, 980, 844, 20770, 18068, 20771, 20769, fact_start);
        Return;
    end if;

    if intervaltype = '1 hour'
    Then
        call datawarehouse.insert_tendy_tracker(0, 2518, 12496, 980, 844, 20774, 18068, 20775, 20773, fact_start);
        Return;
    end if;

    call datawarehouse.insert_tendy_tracker(0, 2519, 12496, 980, 844, 20778, 18068, 20779, 20777, fact_start);

    commit;
*/
End;

$procedure$;


REVOKE ALL ON PROCEDURE entity.test_entity() FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.test_entity() TO PUBLIC;
GRANT EXECUTE ON PROCEDURE entity.test_entity() TO bombadil WITH GRANT OPTION;

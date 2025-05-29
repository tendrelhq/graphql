BEGIN;

/*
DROP FUNCTION entity.crud_entityfieldinstance_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid);
*/


-- Type: FUNCTION ; Name: entity.crud_entityfieldinstance_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityfieldinstance_read_full(read_entityfieldinstanceownerentityuuid uuid, read_entityfieldinstanceentityinstanceentityuuid uuid, read_entityfieldinstanceentityuuid uuid, read_allentityfieldinstances boolean, read_entityfieldinstancesenddeleted boolean, read_entityfieldinstancesenddrafts boolean, read_entityfieldinstancesendinactive boolean, read_languagetranslationtypeentityuuid uuid)
 RETURNS TABLE(languagetranslationtypeentityuuid uuid, entityfieldinstanceuuid uuid, entityfieldinstanceentityinstanceentityuuid uuid, entityfieldinstanceentityinstanceentityname text, entityfieldinstanceownerentityuuid uuid, entityfieldinstanceownerentityname text, entityfieldinstancevalue text, entityfieldinstancevaluelanguagemasteruuid text, entityfieldinstancecreateddate timestamp with time zone, entityfieldinstancemodifieddate timestamp with time zone, entityfieldinstancestartdate timestamp with time zone, entityfieldinstanceenddate timestamp with time zone, entityfieldinstanceentityfieldentityuuid uuid, entityfieldinstancemodifiedbyuuid text, entityfieldinstancerefid bigint, entityfieldinstancerefuuid text, entityfieldinstanceentityfieldname text, entityfieldinstancevaluelanguagetypeentityuuid uuid, entityfieldinstancedeleted boolean, entityfieldinstancedraft boolean, entityfieldinstanceinactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allcustomers boolean; 
	tempentityfieldinstancesenddeleted boolean[];
	tempentityfieldinstancesenddrafts boolean[];
	tempentityfieldinstancesendinactive boolean[];
	templanguagetranslationtypeid bigint;
BEGIN

-- Curently ignores language translation.  We should change this in the future for location. 
-- Might want to add a parameter to send in active as a boolean
-- probably should move this to use arrays for in parameters

/*  examples

-- call entity.test_entity()

-- all customers all entities all tags
select * from entity.crud_entityfieldinstance_read_full(null,null,null,true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific customer all entities all tags
select * from entity.crud_entityfieldinstance_read_full('f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,true,null,null,null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
limit 100

-- specific entity instance

select * from entity.crud_entityfieldinstance_read_full(
	'f90d618d-5de7-4126-8c65-0afb700c6c61', --read_entityfieldinstanceownerentityuuid uuid,
	'b6b8b170-954d-47cf-8d84-d925babd0987', --read_entityfieldinstanceentityinstanceentityuuid uuid,
	null, --read_entityfieldinstanceentityuuid uuid,
	false, --read_allentityfieldinstances boolean,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null,
	null )

-- specific field instance

select * from entity.crud_entityfieldinstance_read_full(
	'f90d618d-5de7-4126-8c65-0afb700c6c61', --read_entityfieldinstanceownerentityuuid uuid,
	'b6b8b170-954d-47cf-8d84-d925babd0987', --read_entityfieldinstanceentityinstanceentityuuid uuid,
	'28e66975-b0d8-4420-ad44-8a4173e4e64f', --read_entityfieldinstanceentityuuid uuid,
	false, --read_allentityfieldinstances boolean,
	null, --read_entityinstancesenddeleted boolean,
	null, --read_entityinstancesenddrafts boolean,
	null,
	null )

select * from entity.entityfieldinstance limit 10

*/

if read_entityfieldinstanceownerentityuuid isNull
	then allcustomers = true;
	else allcustomers = false;
end if;

if read_languagetranslationtypeentityuuid isNull
	then read_languagetranslationtypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'; 
end if;

if read_entityfieldinstancesenddeleted isNull and read_entityfieldinstancesenddeleted = false
	then tempentityfieldinstancesenddeleted = Array[false];
	else tempentityfieldinstancesenddeleted = Array[true,false];
end if;

if read_entityfieldinstancesenddrafts isNull and read_entityfieldinstancesenddrafts = false
	then tempentityfieldinstancesenddrafts = Array[false];
	else tempentityfieldinstancesenddrafts = Array[true,false];
end if;

if read_entityfieldinstancesendinactive isNull and read_entityfieldinstancesendinactive = false
	then tempentityfieldinstancesendinactive = Array[true];
	else tempentityfieldinstancesendinactive = Array[true,false];
end if;

templanguagetranslationtypeid =  (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, read_languagetranslationtypeentityuuid, null, false,read_entityfieldinstancesenddeleted,read_entityfieldinstancesenddrafts, read_entityfieldinstancesendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'));

-- all entities

if allcustomers = true and read_allentityfieldinstances = true 
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			efi.entityfieldinstanceuuid, 
			efi.entityfieldinstanceentityinstanceentityuuid, 
			COALESCE(lt.languagetranslationvalue,lm.languagemastersource),			
			efi.entityfieldinstanceownerentityuuid,
			COALESCE(ltowner.languagetranslationvalue,lmowner.languagemastersource),		
			efi.entityfieldinstancevalue, 
			efi.entityfieldinstancevaluelanguagemasteruuid,
			efi.entityfieldinstancecreateddate, 
			efi.entityfieldinstancemodifieddate, 
			efi.entityfieldinstancestartdate, 
			efi.entityfieldinstanceenddate, 
			efi.entityfieldinstanceentityfieldentityuuid, 
			efi.entityfieldinstancemodifiedbyuuid, 
			efi.entityfieldinstancerefid, 
			efi.entityfieldinstancerefuuid, 
			efi.entityfieldinstanceentityfieldname, 
			efi.entityfieldinstancevaluelanguagetypeentityuuid, 
			efi.entityfieldinstancedeleted, 
			efi.entityfieldinstancedraft,
	case when efi.entityfieldinstancedeleted then false
			when efi.entityfieldinstancedraft then false
			when efi.entityfieldinstanceenddate::Date > now()::date 
				and efi.entityfieldinstancestartdate < now() then false
			else true
	end as entityfieldinstanceactive
		from entity.entityfieldinstance efi
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityfieldinstanceownerentityuuid,null,null,allcustomers,read_entityfieldinstancesenddeleted,read_entityfieldinstancesenddrafts,read_entityfieldinstancesendinactive, null)) as cust
				on cust.customerentityuuid = efi.entityfieldinstanceownerentityuuid
					and efi.entityfieldinstancedeleted = ANY (tempentityfieldinstancesenddeleted)
				 	and efi.entityfieldinstancedraft = ANY (tempentityfieldinstancesenddrafts)
			join  entity.entityinstance ei  
				on efi.entityfieldinstanceentityinstanceentityuuid = ei.entityinstanceuuid
			join languagemaster lm
				on ei.entityinstancenameuuid = lm.languagemasteruuid
			left join public.languagetranslations lt
				on lt.languagetranslationmasterid  = lm.languagemasterid
					and lt.languagetranslationtypeid = templanguagetranslationtypeid 					 
			join  entity.entityinstance eiowner
				on efi.entityfieldinstanceownerentityuuid= eiowner.entityinstanceuuid
			join languagemaster lmowner
				on eiowner.entityinstancenameuuid = lmowner.languagemasteruuid
			left join public.languagetranslations ltowner
				on ltowner.languagetranslationmasterid  = lmowner.languagemasterid
					and ltowner.languagetranslationtypeid = templanguagetranslationtypeid) as foo
		where foo.entityfieldinstanceactive = Any (tempentityfieldinstancesendinactive) ; 		
		return;
end if;

-- all instances for a customer

if allcustomers = false and read_allentityfieldinstances = true 
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			efi.entityfieldinstanceuuid, 
			efi.entityfieldinstanceentityinstanceentityuuid, 
			COALESCE(lt.languagetranslationvalue,lm.languagemastersource),			
			efi.entityfieldinstanceownerentityuuid,
			COALESCE(ltowner.languagetranslationvalue,lmowner.languagemastersource),		
			efi.entityfieldinstancevalue, 
			efi.entityfieldinstancevaluelanguagemasteruuid,
			efi.entityfieldinstancecreateddate, 
			efi.entityfieldinstancemodifieddate, 
			efi.entityfieldinstancestartdate, 
			efi.entityfieldinstanceenddate, 
			efi.entityfieldinstanceentityfieldentityuuid, 
			efi.entityfieldinstancemodifiedbyuuid, 
			efi.entityfieldinstancerefid, 
			efi.entityfieldinstancerefuuid, 
			efi.entityfieldinstanceentityfieldname, 
			efi.entityfieldinstancevaluelanguagetypeentityuuid, 
			efi.entityfieldinstancedeleted, 
			efi.entityfieldinstancedraft,
	case when efi.entityfieldinstancedeleted then false
			when efi.entityfieldinstancedraft then false
			when efi.entityfieldinstanceenddate::Date > now()::date 
				and efi.entityfieldinstancestartdate < now() then false
			else true
	end as entityfieldinstanceactive
		from entity.entityfieldinstance efi
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityfieldinstanceownerentityuuid,null,null,allcustomers,read_entityfieldinstancesenddeleted,read_entityfieldinstancesenddrafts,read_entityfieldinstancesendinactive, null)) as cust
				on cust.customerentityuuid = efi.entityfieldinstanceownerentityuuid
					and efi.entityfieldinstanceownerentityuuid = read_entityfieldinstanceownerentityuuid
					and efi.entityfieldinstancedeleted = ANY (tempentityfieldinstancesenddeleted)
				 	and efi.entityfieldinstancedraft = ANY (tempentityfieldinstancesenddrafts)
			join  entity.entityinstance ei  
				on efi.entityfieldinstanceentityinstanceentityuuid = ei.entityinstanceuuid
			join languagemaster lm
				on ei.entityinstancenameuuid = lm.languagemasteruuid
			left join public.languagetranslations lt
				on lt.languagetranslationmasterid  = lm.languagemasterid
					and lt.languagetranslationtypeid = templanguagetranslationtypeid 					 
			join  entity.entityinstance eiowner
				on efi.entityfieldinstanceownerentityuuid= eiowner.entityinstanceuuid
			join languagemaster lmowner
				on eiowner.entityinstancenameuuid = lmowner.languagemasteruuid
			left join public.languagetranslations ltowner
				on ltowner.languagetranslationmasterid  = lmowner.languagemasterid
					and ltowner.languagetranslationtypeid = templanguagetranslationtypeid) as foo
		where foo.entityfieldinstanceactive = Any (tempentityfieldinstancesendinactive) ; 	
		return;
end if;

-- all fields for an instance

if read_entityfieldinstanceentityinstanceentityuuid notNull 
	and read_entityfieldinstanceentityuuid isnull
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			efi.entityfieldinstanceuuid, 
			efi.entityfieldinstanceentityinstanceentityuuid, 
			COALESCE(lt.languagetranslationvalue,lm.languagemastersource),			
			efi.entityfieldinstanceownerentityuuid,
			COALESCE(ltowner.languagetranslationvalue,lmowner.languagemastersource),		
			efi.entityfieldinstancevalue, 
			efi.entityfieldinstancevaluelanguagemasteruuid,
			efi.entityfieldinstancecreateddate, 
			efi.entityfieldinstancemodifieddate, 
			efi.entityfieldinstancestartdate, 
			efi.entityfieldinstanceenddate, 
			efi.entityfieldinstanceentityfieldentityuuid, 
			efi.entityfieldinstancemodifiedbyuuid, 
			efi.entityfieldinstancerefid, 
			efi.entityfieldinstancerefuuid, 
			efi.entityfieldinstanceentityfieldname, 
			efi.entityfieldinstancevaluelanguagetypeentityuuid, 
			efi.entityfieldinstancedeleted, 
			efi.entityfieldinstancedraft,
	case when efi.entityfieldinstancedeleted then false
			when efi.entityfieldinstancedraft then false
			when efi.entityfieldinstanceenddate::Date > now()::date 
				and efi.entityfieldinstancestartdate < now() then false
			else true
	end as entityfieldinstanceactive
		from entity.entityfieldinstance efi
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityfieldinstanceownerentityuuid,null,null,allcustomers, read_entityfieldinstancesenddeleted,read_entityfieldinstancesenddrafts,read_entityfieldinstancesendinactive,null)) as cust
				on cust.customerentityuuid = efi.entityfieldinstanceownerentityuuid
					and efi.entityfieldinstanceownerentityuuid = read_entityfieldinstanceownerentityuuid
					and efi.entityfieldinstanceentityinstanceentityuuid = read_entityfieldinstanceentityinstanceentityuuid
					and efi.entityfieldinstancedeleted = ANY (tempentityfieldinstancesenddeleted)
				 	and efi.entityfieldinstancedraft = ANY (tempentityfieldinstancesenddrafts)
			join  entity.entityinstance ei  
				on efi.entityfieldinstanceentityinstanceentityuuid = ei.entityinstanceuuid
			join languagemaster lm
				on ei.entityinstancenameuuid = lm.languagemasteruuid
			left join public.languagetranslations lt
				on lt.languagetranslationmasterid  = lm.languagemasterid
					and lt.languagetranslationtypeid = templanguagetranslationtypeid 					 
			join  entity.entityinstance eiowner
				on efi.entityfieldinstanceownerentityuuid= eiowner.entityinstanceuuid
			join languagemaster lmowner
				on eiowner.entityinstancenameuuid = lmowner.languagemasteruuid
			left join public.languagetranslations ltowner
				on ltowner.languagetranslationmasterid  = lmowner.languagemasterid
					and ltowner.languagetranslationtypeid = templanguagetranslationtypeid) as foo
		where foo.entityfieldinstanceactive = Any (tempentityfieldinstancesendinactive) ; 		
			return;
end if;

	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeentityuuid,
			efi.entityfieldinstanceuuid, 
			efi.entityfieldinstanceentityinstanceentityuuid, 
			COALESCE(lt.languagetranslationvalue,lm.languagemastersource),			
			efi.entityfieldinstanceownerentityuuid,
			COALESCE(ltowner.languagetranslationvalue,lmowner.languagemastersource),		
			efi.entityfieldinstancevalue, 
			efi.entityfieldinstancevaluelanguagemasteruuid,
			efi.entityfieldinstancecreateddate, 
			efi.entityfieldinstancemodifieddate, 
			efi.entityfieldinstancestartdate, 
			efi.entityfieldinstanceenddate, 
			efi.entityfieldinstanceentityfieldentityuuid, 
			efi.entityfieldinstancemodifiedbyuuid, 
			efi.entityfieldinstancerefid, 
			efi.entityfieldinstancerefuuid, 
			efi.entityfieldinstanceentityfieldname, 
			efi.entityfieldinstancevaluelanguagetypeentityuuid, 
			efi.entityfieldinstancedeleted, 
			efi.entityfieldinstancedraft,
	case when efi.entityfieldinstancedeleted then false
			when efi.entityfieldinstancedraft then false
			when efi.entityfieldinstanceenddate::Date > now()::date 
				and efi.entityfieldinstancestartdate < now() then false
			else true
	end as entityfieldinstanceactive
		from entity.entityfieldinstance efi
			Join (select customerid,customeruuid, customerentityuuid  
					from entity.crud_customer_read_min(read_entityfieldinstanceownerentityuuid,null,null,allcustomers, read_entityfieldinstancesenddeleted,read_entityfieldinstancesenddrafts,read_entityfieldinstancesendinactive,null)) as cust
				on cust.customerentityuuid = efi.entityfieldinstanceownerentityuuid
					and efi.entityfieldinstanceownerentityuuid = read_entityfieldinstanceownerentityuuid
					and efi.entityfieldinstanceentityinstanceentityuuid = read_entityfieldinstanceentityinstanceentityuuid
					and efi.entityfieldinstanceuuid  = read_entityfieldinstanceentityuuid 
					and efi.entityfieldinstancedeleted = ANY (tempentityfieldinstancesenddeleted)
				 	and efi.entityfieldinstancedraft = ANY (tempentityfieldinstancesenddrafts)
			join  entity.entityinstance ei  
				on efi.entityfieldinstanceentityinstanceentityuuid = ei.entityinstanceuuid
			join languagemaster lm
				on ei.entityinstancenameuuid = lm.languagemasteruuid
			left join public.languagetranslations lt
				on lt.languagetranslationmasterid  = lm.languagemasterid
					and lt.languagetranslationtypeid = templanguagetranslationtypeid 					 
			join  entity.entityinstance eiowner
				on efi.entityfieldinstanceownerentityuuid= eiowner.entityinstanceuuid
			join languagemaster lmowner
				on eiowner.entityinstancenameuuid = lmowner.languagemasteruuid
			left join public.languagetranslations ltowner
				on ltowner.languagetranslationmasterid  = lmowner.languagemasterid
					and ltowner.languagetranslationtypeid = templanguagetranslationtypeid) as foo
		where foo.entityfieldinstanceactive = Any (tempentityfieldinstancesendinactive) ; 		
		return;
End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityfieldinstance_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfieldinstance_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfieldinstance_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entityfieldinstance_read_full(uuid,uuid,uuid,boolean,boolean,boolean,boolean,uuid) TO graphql;

END;

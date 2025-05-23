
-- Type: FUNCTION ; Name: entity.crud_entitydescription_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entitydescription_read_full(read_ownerentityuuid uuid, read_entitydescriptionentityuuid uuid, read_entitytemplateentityuuid uuid, read_entityfieldentityuuid uuid, read_entitydescriptionsenddeleted boolean, read_entitydescriptionsenddrafts boolean, read_entitydescriptionsendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entitydescriptionuuid uuid, entitydescriptionownerentityuuid uuid, entitydescriptionownerentityname text, entitydescriptionentitytemplateentityuuid uuid, entitydescriptionentitytemplateentityname text, entitydescriptionentityfieldentityduuid uuid, entitydescriptionentityfieldentitydname text, entitydescriptionname text, entitydescriptionlanguagemasteruuid text, entitydescriptionsoplink text, entitydescriptionfile text, entitydescriptionicon text, entitydescriptiontranslatedname text, entitydescriptioncreateddate timestamp with time zone, entitydescriptionmodifieddate timestamp with time zone, entitydescriptionstartdate timestamp with time zone, entitydescriptionenddate timestamp with time zone, entitydescriptionmodifiedby text, entitydescriptionexternalid text, entitydescriptionexternalsystementityuuid uuid, entitydescriptionrefid bigint, entitydescriptionrefuuid text, entitydescriptiondraft boolean, entitydescriptiondeleted boolean, entitydescriptionactive boolean, entitydescriptionmimetypeuuid uuid, entitydescriptionmimetypename text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentitydescriptionsenddeleted boolean[]; 
	tempentitydescriptionsenddrafts  boolean[];  
	tempentitydescriptionsendinactive boolean[];
	tendreluuid uuid;
BEGIN

/*  Examples

-- all descriptions
select * from entity.crud_entitydescription_read_full(null, null, null,null, null, null,null,null)

-- all descriptions for an owner
select * from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,null, null, null,null,null)

-- descriptions for an entity
select * from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', 'f42f8873-37a0-450e-97c8-c223955b2f02', null,null, null, null,null,null)

-- all descriptions for a template
select * from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, '2de8bf04-15bd-4df9-b5bc-4eb7fbb8e37e',null, null, null,null,null)

-- all descriptions for a field
select * from entity.crud_entitydescription_read_full('e69fbc64-df87-4c0b-9cbf-bc87774947c7', null, null,'3b477e48-82d7-43fa-a8a4-757d4d5ad457', null, null,null,null)

*/

tendreluuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min(	tendreluuid, null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entitydescriptionsenddeleted, read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entitydescriptionsenddeleted isNull and read_entitydescriptionsenddeleted = false
	then tempentitydescriptionsenddeleted = Array[false];
	else tempentitydescriptionsenddeleted = Array[true,false];
end if;

if read_entitydescriptionsenddrafts isNull and read_entitydescriptionsenddrafts = false
	then tempentitydescriptionsenddrafts = Array[false];
	else tempentitydescriptionsenddrafts = Array[true,false];
end if;

if read_entitydescriptionsendinactive isNull and read_entitydescriptionsendinactive = false
	then tempentitydescriptionsendinactive = Array[true];
	else tempentitydescriptionsendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entitydescriptionentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitydescriptionuuid, 
				et.entitydescriptionownerentityuuid, 
				cust.customername,
				et.entitydescriptionentitytemplateentityuuid, 
				etemplate.entitytemplatename,
				et.entitydescriptionentityfieldentityduuid, 
				efield.entityfieldname,
				et.entitydescriptionname, 
				et.entitydescriptionlanguagemasteruuid,				
				et.entitydescriptionsoplink, 
				et.entitydescriptionfile, 
				et.entitydescriptionicon, 
				entlt.languagetranslationvalue as entitydescriptiontranslatedname,			
				et.entitydescriptioncreateddate, 
				et.entitydescriptionmodifieddate, 
				et.entitydescriptionstartdate, 
				et.entitydescriptionenddate, 
				et.entitydescriptionmodifiedby, 
				et.entitydescriptionexternalid, 
				et.entitydescriptionexternalsystementityuuid, 
				et.entitydescriptionrefid, 
				et.entitydescriptionrefuuid, 
				et.entitydescriptiondraft, 
				et.entitydescriptiondeleted,
			case when et.entitydescriptiondeleted then false
			when et.entitydescriptiondraft then false
			when et.entitydescriptionstartdate::Date > now()::date 
				and et.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et.entitydescriptionmimetypeuuid,
				mime.systagtype
			FROM entity.entitydescription et
				inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitydescriptionsenddeleted,read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive, null)) as cust
					on cust.customerentityuuid = et.entitydescriptionownerentityuuid
						and et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
					 	and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)
				left join (select * 
							from entity.crud_entitytemplate_read_full(read_ownerentityuuid,read_entitytemplateentityuuid,null,null, null,null)) etemplate
					on etemplate.entitytemplateuuid = et.entitydescriptionentitytemplateentityuuid
				left join (select * 
							from entity.crud_entityfield_read_full(read_ownerentityuuid,null,read_entityfieldentityuuid,	null, null, null,null)) efield
					on efield.entityfielduuid = et.entitydescriptionentityfieldentityduuid	
				left join (select * from entity.crud_systag_read_full(read_ownerentityuuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = et.entitydescriptionmimetypeuuid
				inner join languagemaster entlm
					on et.entitydescriptionlanguagemasteruuid= entlm.languagemasteruuid
				left join public.languagetranslations entlt
					on entlt.languagetranslationmasterid  = entlm.languagemasterid
						and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitydescriptionsenddeleted  , read_entitydescriptionsenddrafts  ,read_entitydescriptionsendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) 
			where et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
				 and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive
		) ;
		return;
end if;

if allowners = false and read_entitydescriptionentityuuid notNull  
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitydescriptionuuid, 
				et.entitydescriptionownerentityuuid, 
				cust.customername,
				et.entitydescriptionentitytemplateentityuuid, 
				etemplate.entitytemplatename,
				et.entitydescriptionentityfieldentityduuid, 
				efield.entityfieldname,
				et.entitydescriptionname, 
				et.entitydescriptionlanguagemasteruuid,
				et.entitydescriptionsoplink, 
				et.entitydescriptionfile, 
				et.entitydescriptionicon, 
				entlt.languagetranslationvalue as entitydescriptiontranslatedname,			
				et.entitydescriptioncreateddate, 
				et.entitydescriptionmodifieddate, 
				et.entitydescriptionstartdate, 
				et.entitydescriptionenddate, 
				et.entitydescriptionmodifiedby, 
				et.entitydescriptionexternalid, 
				et.entitydescriptionexternalsystementityuuid, 
				et.entitydescriptionrefid, 
				et.entitydescriptionrefuuid, 
				et.entitydescriptiondraft, 
				et.entitydescriptiondeleted,
			case when et.entitydescriptiondeleted then false
			when et.entitydescriptiondraft then false
			when et.entitydescriptionstartdate::Date > now()::date 
				and et.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et.entitydescriptionmimetypeuuid,
				mime.systagtype
		FROM entity.entitydescription et
			inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitydescriptionsenddeleted,read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive, null)) as cust
				on cust.customerentityuuid = et.entitydescriptionownerentityuuid
					and (et.entitydescriptionownerentityuuid = read_ownerentityuuid
						or et.entitydescriptionownerentityuuid = tendreluuid) 
					and et.entitydescriptionuuid = read_entitydescriptionentityuuid	
					and et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
					and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)
				left join (select * 
							from entity.crud_entitytemplate_read_full(read_ownerentityuuid,read_entitytemplateentityuuid,null,null, null,null)) etemplate
					on etemplate.entitytemplateuuid = et.entitydescriptionentitytemplateentityuuid
				left join (select * 
							from entity.crud_entityfield_read_full(read_ownerentityuuid,null,read_entityfieldentityuuid,	null, null, null,null)) efield
					on efield.entityfielduuid = et.entitydescriptionentityfieldentityduuid					
				left join (select * from entity.crud_systag_read_full(read_ownerentityuuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = et.entitydescriptionmimetypeuuid
				inner join languagemaster entlm
					on et.entitydescriptionlanguagemasteruuid= entlm.languagemasteruuid
				left join public.languagetranslations entlt
					on entlt.languagetranslationmasterid  = entlm.languagemasterid
						and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitydescriptionsenddeleted  , read_entitydescriptionsenddrafts  ,read_entitydescriptionsendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive
		) ;
		return;
end if;

if allowners = false and read_entityfieldentityuuid notNull
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitydescriptionuuid, 
				et.entitydescriptionownerentityuuid, 
				cust.customername,
				et.entitydescriptionentitytemplateentityuuid, 
				etemplate.entitytemplatename,
				et.entitydescriptionentityfieldentityduuid, 
				efield.entityfieldname,
				et.entitydescriptionname, 
				et.entitydescriptionlanguagemasteruuid,
				et.entitydescriptionsoplink, 
				et.entitydescriptionfile, 
				et.entitydescriptionicon, 
				entlt.languagetranslationvalue as entitydescriptiontranslatedname,			
				et.entitydescriptioncreateddate, 
				et.entitydescriptionmodifieddate, 
				et.entitydescriptionstartdate, 
				et.entitydescriptionenddate, 
				et.entitydescriptionmodifiedby, 
				et.entitydescriptionexternalid, 
				et.entitydescriptionexternalsystementityuuid, 
				et.entitydescriptionrefid, 
				et.entitydescriptionrefuuid, 
				et.entitydescriptiondraft, 
				et.entitydescriptiondeleted,
			case when et.entitydescriptiondeleted then false
			when et.entitydescriptiondraft then false
			when et.entitydescriptionstartdate::Date > now()::date 
				and et.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et.entitydescriptionmimetypeuuid,
				mime.systagtype
		FROM entity.entitydescription et
			inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitydescriptionsenddeleted,read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive, null)) as cust
				on cust.customerentityuuid = et.entitydescriptionownerentityuuid
					and (et.entitydescriptionownerentityuuid = read_ownerentityuuid
						or et.entitydescriptionownerentityuuid = tendreluuid) 
					and et.entitydescriptionentityfieldentityduuid = read_entityfieldentityuuid
					and et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
					and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)
				left join (select * 
							from entity.crud_entitytemplate_read_full(read_ownerentityuuid,read_entitytemplateentityuuid,null,null, null,null)) etemplate
					on etemplate.entitytemplateuuid = et.entitydescriptionentitytemplateentityuuid
				left join (select * 
							from entity.crud_entityfield_read_full(read_ownerentityuuid,null,read_entityfieldentityuuid,	null, null, null,null)) efield
					on efield.entityfielduuid = et.entitydescriptionentityfieldentityduuid					
				left join (select * from entity.crud_systag_read_full(read_ownerentityuuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = et.entitydescriptionmimetypeuuid				
				inner join languagemaster entlm
					on et.entitydescriptionlanguagemasteruuid= entlm.languagemasteruuid
				left join public.languagetranslations entlt
					on entlt.languagetranslationmasterid  = entlm.languagemasterid
						and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitydescriptionsenddeleted  , read_entitydescriptionsenddrafts  ,read_entitydescriptionsendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')) ) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive) ;
end if;

if allowners = false and read_entitytemplateentityuuid notNull
	then
		return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitydescriptionuuid, 
				et.entitydescriptionownerentityuuid, 
				cust.customername,
				et.entitydescriptionentitytemplateentityuuid, 
				etemplate.entitytemplatename,
				et.entitydescriptionentityfieldentityduuid, 
				efield.entityfieldname,
				et.entitydescriptionname, 
				et.entitydescriptionlanguagemasteruuid,
				et.entitydescriptionsoplink, 
				et.entitydescriptionfile, 
				et.entitydescriptionicon, 
				entlt.languagetranslationvalue as entitydescriptiontranslatedname,			
				et.entitydescriptioncreateddate, 
				et.entitydescriptionmodifieddate, 
				et.entitydescriptionstartdate, 
				et.entitydescriptionenddate, 
				et.entitydescriptionmodifiedby, 
				et.entitydescriptionexternalid, 
				et.entitydescriptionexternalsystementityuuid, 
				et.entitydescriptionrefid, 
				et.entitydescriptionrefuuid, 
				et.entitydescriptiondraft, 
				et.entitydescriptiondeleted,
			case when et.entitydescriptiondeleted then false
			when et.entitydescriptiondraft then false
			when et.entitydescriptionstartdate::Date > now()::date 
				and et.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et.entitydescriptionmimetypeuuid,
				mime.systagtype
		FROM entity.entitydescription et
			inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitydescriptionsenddeleted,read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive, null)) as cust
				on cust.customerentityuuid = et.entitydescriptionownerentityuuid
					and (et.entitydescriptionownerentityuuid = read_ownerentityuuid
						or et.entitydescriptionownerentityuuid = tendreluuid) 
					and et.entitydescriptionentitytemplateentityuuid = read_entitytemplateentityuuid
					and et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
					and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)
				left join (select * 
							from entity.crud_entitytemplate_read_full(read_ownerentityuuid,read_entitytemplateentityuuid,null,null, null,null)) etemplate
					on etemplate.entitytemplateuuid = et.entitydescriptionentitytemplateentityuuid
				left join (select * 
							from entity.crud_entityfield_read_full(read_ownerentityuuid,null,read_entityfieldentityuuid,	null, null, null,null)) efield
					on efield.entityfielduuid = et.entitydescriptionentityfieldentityduuid					
				left join (select * from entity.crud_systag_read_full(read_ownerentityuuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = et.entitydescriptionmimetypeuuid				
				inner join languagemaster entlm
					on et.entitydescriptionlanguagemasteruuid= entlm.languagemasteruuid
				left join public.languagetranslations entlt
					on entlt.languagetranslationmasterid  = entlm.languagemasterid
						and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitydescriptionsenddeleted  , read_entitydescriptionsenddrafts  ,read_entitydescriptionsendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive) ;
end if;

if allowners = false and read_entitytemplateentityuuid isNull 
	and read_entityfieldentityuuid isNull and read_entitydescriptionentityuuid isNull  
	then
	return query 
		select *
		from (SELECT 
				read_languagetranslationtypeuuid,
				et.entitydescriptionuuid, 
				et.entitydescriptionownerentityuuid, 
				cust.customername,
				et.entitydescriptionentitytemplateentityuuid, 
				etemplate.entitytemplatename,
				et.entitydescriptionentityfieldentityduuid, 
				efield.entityfieldname,
				et.entitydescriptionname, 
				et.entitydescriptionlanguagemasteruuid,
				et.entitydescriptionsoplink, 
				et.entitydescriptionfile, 
				et.entitydescriptionicon, 
				entlt.languagetranslationvalue as entitydescriptiontranslatedname,			
				et.entitydescriptioncreateddate, 
				et.entitydescriptionmodifieddate, 
				et.entitydescriptionstartdate, 
				et.entitydescriptionenddate, 
				et.entitydescriptionmodifiedby, 
				et.entitydescriptionexternalid, 
				et.entitydescriptionexternalsystementityuuid, 
				et.entitydescriptionrefid, 
				et.entitydescriptionrefuuid, 
				et.entitydescriptiondraft, 
				et.entitydescriptiondeleted,
			case when et.entitydescriptiondeleted then false
			when et.entitydescriptiondraft then false
			when et.entitydescriptionstartdate::Date > now()::date 
				and et.entitydescriptionenddate < now() then false
			else true
	end as entitydescriptionactive,
				et.entitydescriptionmimetypeuuid,
				mime.systagtype
		FROM entity.entitydescription et
			inner join (select * from entity.crud_customer_read_full(null,null, null,true,read_entitydescriptionsenddeleted,read_entitydescriptionsenddrafts,read_entitydescriptionsendinactive, null)) as cust
				on cust.customerentityuuid = et.entitydescriptionownerentityuuid
					and (et.entitydescriptionownerentityuuid = read_ownerentityuuid
						or et.entitydescriptionownerentityuuid = tendreluuid) 
					and et.entitydescriptiondeleted = ANY (tempentitydescriptionsenddeleted)
					and et.entitydescriptiondraft = ANY (tempentitydescriptionsenddrafts)
				left join (select * 
							from entity.crud_entitytemplate_read_full(read_ownerentityuuid,read_entitytemplateentityuuid,null,null, null,null)) etemplate
					on etemplate.entitytemplateuuid = et.entitydescriptionentitytemplateentityuuid
				left join (select * 
							from entity.crud_entityfield_read_full(read_ownerentityuuid,null,read_entityfieldentityuuid,	null, null, null,null)) efield
					on efield.entityfielduuid = et.entitydescriptionentityfieldentityduuid					
				left join (select * from entity.crud_systag_read_full(read_ownerentityuuid,null,null, 'e5d15a8c-ea2e-4def-b214-6eb7f6b1e70a', false,null,null, null,read_languagetranslationtypeuuid)) as mime
					on mime.systagentityuuid = et.entitydescriptionmimetypeuuid				
				inner join languagemaster entlm
					on et.entitydescriptionlanguagemasteruuid= entlm.languagemasteruuid
				left join public.languagetranslations entlt
					on entlt.languagetranslationmasterid  = entlm.languagemasterid
						and entlt.languagetranslationtypeid = (select systagid from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null,read_languagetranslationtypeuuid, null, false,read_entitydescriptionsenddeleted  , read_entitydescriptionsenddrafts  ,read_entitydescriptionsendinactive  ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9'))) as foo
		where foo.entitydescriptionactive = Any (tempentitydescriptionsendinactive
		) ;
		return;
end if;
End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entitydescription_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitydescription_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entitydescription_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION entity.crud_entitydescription_read_full(uuid,uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO graphql;

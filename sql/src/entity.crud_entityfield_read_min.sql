
-- Type: FUNCTION ; Name: entity.crud_entityfield_read_min(uuid,uuid,uuid,boolean,boolean,boolean,uuid); Owner: tendreladmin

CREATE OR REPLACE FUNCTION entity.crud_entityfield_read_min(read_ownerentityuuid uuid, read_entitytemplateentityuuid uuid, read_entityfieldentityuuid uuid, read_entityfieldsenddeleted boolean, read_entityfieldsenddrafts boolean, read_entityfieldsendinactive boolean, read_languagetranslationtypeuuid uuid)
 RETURNS TABLE(languagetranslationtypeuuid uuid, entityfielduuid uuid, entityfieldentitytemplateentityuuid uuid, entityfieldcreateddate timestamp with time zone, entityfieldmodifieddate timestamp with time zone, entityfieldstartdate timestamp with time zone, entityfieldenddate timestamp with time zone, entityfieldlanguagemasteruuid text, entityfieldorder bigint, entityfielddefaultvalue text, entityfieldiscalculated boolean, entityfieldiseditable boolean, entityfieldisvisible boolean, entityfieldisrequired boolean, entityfieldformatentityuuid uuid, entityfieldwidgetentityuuid uuid, entityfieldexternalid text, entityfieldexternalsystementityuuid uuid, entityfieldmodifiedbyuuid text, entityfieldrefid bigint, entityfieldrefuuid text, entityfieldisprimary boolean, entityfieldtranslate boolean, entityfieldname text, entityfieldownerentityuuid uuid, entityfieldtypeentityuuid uuid, entityfieldparententityuuid uuid, entityfieldentitytypeentityuuid uuid, entityfieldentityparenttypeentityuuid uuid, entityfieldeleted boolean, entityfielddraft boolean, entityfieldactive boolean)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	allowners boolean; 
	templanguagetranslationtypeid bigint;
	tempentityfieldsenddeleted boolean[]; 
	tempentityfieldsenddrafts  boolean[];  
	tempentityfieldsendinactive boolean[];
BEGIN

/*  Examples

-- all customers no entity template no field
select * from entity.crud_entityfield_read_min(null, null, null,null, null, null,null)

-- specific customer no entity template no field
select * from entity.crud_entityfield_read_min(	'f90d618d-5de7-4126-8c65-0afb700c6c61',null, null,null, null, null, null)

-- specific entity template
select * 
from entity.crud_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61','b124da10-be8a-4d32-9f68-7f4e6e8b24e9',null,	null, null, null,null)

-- specific entity field
select * 
from entity.crud_entityfield_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61',null,'d15bb9c2-0601-4e4f-9009-c791a40be191',	null, null, null,null)

-- negative tests - empty or wrong cutomer returns nothing
select * 
from entity.crud_entityfield_read_min(null,'b124da10-be8a-4d32-9f68-7f4e6e8b24e9',	null,null, null, null,null)

select * 
from entity.crud_entityfield_read_min(null,null,	'd15bb9c2-0601-4e4f-9009-c791a40be191',null, null, null,null)

*/

if read_languagetranslationtypeuuid isNull
	then read_languagetranslationtypeuuid = (
		select systagentityuuid 
		from entity.crud_systag_read_min('f90d618d-5de7-4126-8c65-0afb700c6c61', null, 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9', null, false,read_entityfieldsenddeleted , read_entityfieldsenddrafts , read_entityfieldsendinactive ,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9')
		); 
end if;

if read_ownerentityuuid isNull
	then allowners = true;
	else allowners = false;
end if;

if read_entityfieldsenddeleted isNull and read_entityfieldsenddeleted = false
	then tempentityfieldsenddeleted = Array[false];
	else tempentityfieldsenddeleted = Array[true,false];
end if;

if read_entityfieldsenddrafts isNull and read_entityfieldsenddrafts = false
	then tempentityfieldsenddrafts = Array[false];
	else tempentityfieldsenddrafts = Array[true,false];
end if;

if read_entityfieldsendinactive isNull and read_entityfieldsendinactive = false
	then tempentityfieldsendinactive = Array[true];
	else tempentityfieldsendinactive = Array[true,false];
end if;

-- probably can do this cealner with less sql

if allowners = true and (read_entitytemplateentityuuid isNull) and (read_entityfieldentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef.entityfielduuid, 
			ef.entityfieldentitytemplateentityuuid, 
			ef.entityfieldcreateddate, 
			ef.entityfieldmodifieddate, 
			ef.entityfieldstartdate, 
			ef.entityfieldenddate, 
			ef.entityfieldlanguagemasteruuid, 
			ef.entityfieldorder, 
			ef.entityfielddefaultvalue, 
			ef.entityfieldiscalculated, 
			ef.entityfieldiseditable, 
			ef.entityfieldisvisible, 
			ef.entityfieldisrequired, 
			ef.entityfieldformatentityuuid, 
			ef.entityfieldwidgetentityuuid, -- replace this with the entity instance when it is ready
			ef.entityfieldexternalid,
			ef.entityfieldexternalsystementityuuid, 
			ef.entityfieldmodifiedbyuuid, 
			ef.entityfieldrefid, 
			ef.entityfieldrefuuid,
			ef.entityfieldisprimary, 
			ef.entityfieldtranslate, 
			ef.entityfieldname, 
			ef.entityfieldownerentityuuid, 
			ef.entityfieldtypeentityuuid, 
			ef.entityfieldparententityuuid, 
			ef.entityfieldentitytypeentityuuid, 
			ef.entityfieldentityparenttypeentityuuid,
				ef.entityfielddeleted,
				ef.entityfielddraft,
				case when ef.entityfieldenddate notnull and ef.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		FROM entity.entityfield ef
		where ef.entityfielddeleted = ANY (tempentityfieldsenddeleted)
			and ef.entityfielddraft = ANY (tempentityfieldsenddrafts)) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid isNull) and (read_entityfieldentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef2.entityfielduuid, 
			ef2.entityfieldentitytemplateentityuuid, 
			ef2.entityfieldcreateddate, 
			ef2.entityfieldmodifieddate, 
			ef2.entityfieldstartdate, 
			ef2.entityfieldenddate, 
			ef2.entityfieldlanguagemasteruuid, 
			ef2.entityfieldorder, 
			ef2.entityfielddefaultvalue, 
			ef2.entityfieldiscalculated, 
			ef2.entityfieldiseditable, 
			ef2.entityfieldisvisible, 
			ef2.entityfieldisrequired, 
			ef2.entityfieldformatentityuuid, 
			ef2.entityfieldwidgetentityuuid, -- replace this with the entity instance when it is ready
			ef2.entityfieldexternalid,
			ef2.entityfieldexternalsystementityuuid, 
			ef2.entityfieldmodifiedbyuuid, 
			ef2.entityfieldrefid, 
			ef2.entityfieldrefuuid,
			ef2.entityfieldisprimary, 
			ef2.entityfieldtranslate, 
			ef2.entityfieldname, 
			ef2.entityfieldownerentityuuid, 
			ef2.entityfieldtypeentityuuid, 
			ef2.entityfieldparententityuuid, 
			ef2.entityfieldentitytypeentityuuid, 
			ef2.entityfieldentityparenttypeentityuuid,
				ef2.entityfielddeleted,
				ef2.entityfielddraft,
				case when ef2.entityfieldenddate notnull and ef2.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		FROM entity.entityfield ef2
		where ef2.entityfieldownerentityuuid = read_ownerentityuuid
			and ef2.entityfielddeleted = ANY (tempentityfieldsenddeleted)
			and ef2.entityfielddraft = ANY (tempentityfieldsenddrafts)) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);
		return;
end if;

if allowners = false and (read_entitytemplateentityuuid notNull) and (read_entityfieldentityuuid isNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef3.entityfielduuid, 
			ef3.entityfieldentitytemplateentityuuid, 
			ef3.entityfieldcreateddate, 
			ef3.entityfieldmodifieddate, 
			ef3.entityfieldstartdate, 
			ef3.entityfieldenddate, 
			ef3.entityfieldlanguagemasteruuid, 
			ef3.entityfieldorder, 
			ef3.entityfielddefaultvalue, 
			ef3.entityfieldiscalculated, 
			ef3.entityfieldiseditable, 
			ef3.entityfieldisvisible, 
			ef3.entityfieldisrequired, 
			ef3.entityfieldformatentityuuid, 
			ef3.entityfieldwidgetentityuuid, -- replace this with the entity instance when it is ready
			ef3.entityfieldexternalid,
			ef3.entityfieldexternalsystementityuuid, 
			ef3.entityfieldmodifiedbyuuid, 
			ef3.entityfieldrefid, 
			ef3.entityfieldrefuuid,
			ef3.entityfieldisprimary, 
			ef3.entityfieldtranslate, 
			ef3.entityfieldname, 
			ef3.entityfieldownerentityuuid, 
			ef3.entityfieldtypeentityuuid, 
			ef3.entityfieldparententityuuid, 
			ef3.entityfieldentitytypeentityuuid, 
			ef3.entityfieldentityparenttypeentityuuid,
				ef3.entityfielddeleted,
				ef3.entityfielddraft,
				case when ef3.entityfieldenddate notnull and ef3.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		FROM entity.entityfield ef3
		where ef3.entityfieldownerentityuuid = read_ownerentityuuid
			and ef3.entityfieldentitytemplateentityuuid = read_entitytemplateentityuuid
			and ef3.entityfielddeleted = ANY (tempentityfieldsenddeleted)
			and ef3.entityfielddraft = ANY (tempentityfieldsenddrafts)) as foo
			where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);
		return;

end if;

if allowners = false and (read_entityfieldentityuuid notNull)
	then
	return query 
		select *
		from (SELECT 
			read_languagetranslationtypeuuid,
			ef4.entityfielduuid, 
			ef4.entityfieldentitytemplateentityuuid, 
			ef4.entityfieldcreateddate, 
			ef4.entityfieldmodifieddate, 
			ef4.entityfieldstartdate, 
			ef4.entityfieldenddate, 
			ef4.entityfieldlanguagemasteruuid, 
			ef4.entityfieldorder, 
			ef4.entityfielddefaultvalue, 
			ef4.entityfieldiscalculated, 
			ef4.entityfieldiseditable, 
			ef4.entityfieldisvisible, 
			ef4.entityfieldisrequired, 
			ef4.entityfieldformatentityuuid, 
			ef4.entityfieldwidgetentityuuid, -- replace this with the entity instance when it is ready
			ef4.entityfieldexternalid,
			ef4.entityfieldexternalsystementityuuid, 
			ef4.entityfieldmodifiedbyuuid, 
			ef4.entityfieldrefid, 
			ef4.entityfieldrefuuid,
			ef4.entityfieldisprimary, 
			ef4.entityfieldtranslate, 
			ef4.entityfieldname, 
			ef4.entityfieldownerentityuuid, 
			ef4.entityfieldtypeentityuuid, 
			ef4.entityfieldparententityuuid, 
			ef4.entityfieldentitytypeentityuuid, 
			ef4.entityfieldentityparenttypeentityuuid,
				ef4.entityfielddeleted,
				ef4.entityfielddraft,
				case when ef4.entityfieldenddate notnull and ef4.entityfieldenddate::Date < now()::date
					then false
					else true
				end as entityfieldsendinactive
		FROM entity.entityfield ef4
		where ef4.entityfieldownerentityuuid = read_ownerentityuuid
				and ef4.entityfielduuid = read_entityfieldentityuuid
				and ef4.entityfielddeleted = ANY (tempentityfieldsenddeleted)
				and ef4.entityfielddraft = ANY (tempentityfieldsenddrafts)) as foo
		where  foo.entityfieldsendinactive = Any (tempentityfieldsendinactive);
		return;
end if;

End;	

$function$;


REVOKE ALL ON FUNCTION entity.crud_entityfield_read_min(uuid,uuid,uuid,boolean,boolean,boolean,uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfield_read_min(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO PUBLIC;
GRANT EXECUTE ON FUNCTION entity.crud_entityfield_read_min(uuid,uuid,uuid,boolean,boolean,boolean,uuid) TO tendreladmin WITH GRANT OPTION;

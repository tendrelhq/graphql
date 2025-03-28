CREATE OR REPLACE PROCEDURE entity.crud_entityfield_create(
  IN create_entityfieldownerentityuuid uuid,
  IN create_entityfieldparententityuuid uuid,
  IN create_entityfieldtemplateentityuuid uuid,
  IN create_entityfieldcornerstoneorder integer,
  IN create_entityfieldname text,
  IN create_entityfieldtypeentityuuid uuid,
  IN create_entityfieldentityparenttypeentityuuid uuid,
  IN create_entityfieldentitytypeentityuuid uuid,
  IN create_entityfielddefaultvalue text,
  IN create_entityfieldformatentityuuid uuid,
  IN create_entityfieldformatentityname text,
  IN create_entityfieldwidgetentityuuid uuid,
  IN create_entityfieldwidgetentityname text,
  IN create_entityfieldiscalculated boolean,
  IN create_entityfieldiseditable boolean,
  IN create_entityfieldisvisible boolean,
  IN create_entityfieldisrequired boolean,
  IN create_entityfieldisprimary boolean,
  IN create_entityfieldtranslate boolean,
  IN create_entityfieldexternalid text,
  IN create_entityfieldexternalsystemuuid uuid,
  IN create_languagetypeuuid uuid,
  IN create_entityfielddeleted boolean,
  IN create_entityfielddraft boolean,
  OUT create_entityfieldentityuuid uuid,
  IN create_modifiedbyid bigint
)
 LANGUAGE plpgsql
AS $procedure$
Declare
	templanguagetypeentityuuid uuid;	
	tempcustomerid bigint;
	tempentityfieldparententityuuid uuid;
	tempcustagid bigint;
	tempcustaguuid text;
	templanguagetypeid bigint;
	templanguagetypeuuid text;
	tempcornerstoneorder integer; 
	templanguagemasteruuid text;
	tempentityfieldentitytypeentityuuid uuid;
	tempentityfieldtypeentityuuid uuid;
	tempentityfieldentityparenttypeentityuuid uuid;
	tempentityfieldformatentityuuid uuid;
	tempentityfieldwidgetentityuuid uuid;
	temptendrelentityuuid uuid;
	tempentitytemplateownerentityuuid uuid;
	tempentityfieldname text;
	tempentityfieldtemplateentityuuid uuid;
	tempentityfielddeleted boolean;
	tempentityfielddraft boolean;  
		
Begin

/*
---------------------------------------------
HOW TO HANDLE ENTIY TYPE
Currently we control this and it is used for drop downs
-- Do we allow for systags that are not system controlled?  Going to start with allowing customers to create system tags for entities. 
-- Do we have a joined custag/systag version?  Not yet, so using systags.
-- Currently allowing duplicate types (Might want to stop this via a constraint on owner and type)
-- Will create a Type for that customer in systag with Systag "Entity Types" as the parent.

OTHER THINGS
-- This does not handle duplicate template names.  Maybe via a constraint. No duplicates for owner/template 
-- We could do inheritance from a parent template.  Right now parent does nothing.  

 select entitytemplatename,* from entity.crud_entitytemplate_read_full(null, null, null,null, null, null)

-- tests needed
	-- no template name
		call entity.crud_entityfield_create(
			null, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			null, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			null, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)		

	-- no template
		call entity.crud_entityfield_create(
			null, -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			null, -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)		
	
	-- invalid customer valid template
		call entity.crud_entityfield_create(
			'7bbaa455-1965-4171-95f1-ee9f22a98f10', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)		
			
	-- valid customer valid template invalid combo
		call entity.crud_entityfield_create(
			'3d388b1e-a9e6-4d31-a5a4-e7e454282d30', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			null, -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)	
			
	-- invalid result type
		call entity.crud_entityfield_create(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'b07bf96e-0a35-4b01-bcc0-863dc7b3db0c', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)	

	-- invalid entity type
		call entity.crud_entityfield_create(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'2de2bbde-6319-4886-a58d-bf9d369fc677', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			'7bbaa455-1965-4171-95f1-ee9f22a98f10', -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)
	
	-- invalid entity parent type has value and entity type does not
		call entity.crud_entityfield_create(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'2de2bbde-6319-4886-a58d-bf9d369fc677', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			'67af22cb-3183-4e6e-8542-7968f744965a', -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)

	-- invalid format type

		call entity.crud_entityfield_create(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'2de2bbde-6319-4886-a58d-bf9d369fc677', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)

	-- invalid widget type

		call entity.crud_entityfield_create(
			'f90d618d-5de7-4126-8c65-0afb700c6c61', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'0b9f3142-e7ed-4f78-8504-ccd2eb505075', -- IN create_entityfieldtemplateentityuuid uuid,
			null, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'2de2bbde-6319-4886-a58d-bf9d369fc677', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			null, -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			'4f13599f-8766-4589-b80f-77ff00819380', -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)

	-- valid insert-- existing widget.  
	
		call entity.crud_entityfield_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'cad6913c-071e-4822-9cf6-58cd2d5ff3fd', -- IN create_entityfieldtemplateentityuuid uuid,
			5, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'2de2bbde-6319-4886-a58d-bf9d369fc677', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			'Test', -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			null, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			'0bf3e80c-ff85-4f5a-9586-56519dca4d2e', -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			null, -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)

	-- valid insert-- new format/widget.  

		call entity.crud_entityfield_create(
			'70f200bd-1c92-481d-9f5c-e6cf6cd92cd0', -- IN create_entityfieldownerentityuuid uuid,    
			null, -- IN create_entityfieldparententityuuid uuid, -- is self if null.  Otherwise it should be another entity field.  
			'cad6913c-071e-4822-9cf6-58cd2d5ff3fd', -- IN create_entityfieldtemplateentityuuid uuid,
			5, -- IN create_entityfieldcornerstoneorder integer,
			'fieldname'||now()::text, -- IN create_entityfieldname text,
			'2de2bbde-6319-4886-a58d-bf9d369fc677', -- IN create_entityfieldtypeentityuuid uuid,  -- this is the field type like result.  Uses result.     
			null, -- IN create_entityfieldentityparenttypeentityuuid uuid, -- this is for sys/cus tag.  A way to get greater filtering. 
			null, -- IN create_entityfieldentitytypeentityuuid uuid,  -- this is the entity type
			'Test', -- IN create_entityfielddefaultvalue uuid, 
			null, -- IN create_entityfieldformatentityuuid uuid, 
			'format'||now()::text, -- IN create_entityfieldformatentityname text, 	-- not handled yet
			null, -- IN create_entityfieldwidgetentityuuid uuid,  	-- not handled yet
			'widget'||now()::text,  -- IN create_entityfieldwidgetentityname text, 
			null, -- IN create_entityfieldiscalculated boolean,  -- default is false
			null, -- IN create_entityfieldiseditable boolean,  -- default is true
			null, -- IN create_entityfieldisvisible boolean,  -- default is true
			null, -- IN create_entityfieldisrequired boolean,  -- default is false
			null, -- IN create_entityfieldisprimary boolean,  -- default is false
			null, -- IN create_entityfieldtranslate boolean, -- default is true
			null, -- IN create_entityfieldexternalid text,
			null, -- IN create_entityfieldexternalsystemuuid uuid,
			null, -- IN create_languagetypeuuid uuid,	
			null,-- create_entityfielddeleted boolean,
			null,-- create_entityfielddraft boolean,
			null, -- OUT create_entityfieldentityuuid uuid,
			337::bigint)

*/

-- setup the tendrel uuid that we use for many function calls
temptendrelentityuuid = 'f90d618d-5de7-4126-8c65-0afb700c6c61';

-- check for a field name
-- should we also check for empty string?  if yes, add it here.  

if create_entityfieldname  isNull
	then 
		return;   -- need an error code here
	else tempentityfieldname = create_entityfieldname;
end if;

-- check for null template

if create_entityfieldtemplateentityuuid isNull
	then return;   -- need an error code here
	else tempentityfieldtemplateentityuuid = create_entityfieldtemplateentityuuid;
end if;

-- set up customer/owner  
-- Assumes customer until custag is cutover to entity 100%
-- Owner will always be taken from the entity template.  We may want to change this in the future
-- Note this checks for a valid template and valid customer
select entitytemplateownerentityuuid into tempentitytemplateownerentityuuid
	from entity.crud_entitytemplate_read_min(create_entityfieldownerentityuuid ,tempentityfieldtemplateentityuuid ,null,null,null,null);

-- select entitytemplateownerentityuuid from entity.crud_entitytemplate_read_min('7bbaa455-1965-4171-95f1-ee9f22a98f10' ,null ,null);

-- select customerid from entity.crud_customer_read_min(null,null,null,false,null,null,null, null);

select customerid into tempcustomerid
	from entity.crud_customer_read_min(null,tempentitytemplateownerentityuuid,null,false, null,null,null,null);
	
-- probably return an error if the entity is not set to a customer.  
-- This also covers invalid entity template
if tempcustomerid isNull
	then return;   -- need an error code here
end if;

-- check for valid result type - uuid =  '7bbaa455-1965-4171-95f1-ee9f22a98f10'
if create_entityfieldtypeentityuuid in 
		(select systagentityuuid
		from entity.crud_systag_read_min(temptendrelentityuuid,null,null, '7bbaa455-1965-4171-95f1-ee9f22a98f10', false,null,null, null,create_languagetypeuuid))
	then tempentityfieldtypeentityuuid = create_entityfieldtypeentityuuid;
	else return;  -- need an error code here
end if;

-- check for valid entity type 'b07bf96e-0a35-4b01-bcc0-863dc7b3db0c'

If create_entityfieldentitytypeentityuuid isNull
	then tempentityfieldentitytypeentityuuid = create_entityfieldentitytypeentityuuid;
	elseif (create_entityfieldtypeentityuuid notNull 
			and create_entityfieldentitytypeentityuuid in (select systagentityuuid 
						from entity.crud_systag_read_min(temptendrelentityuuid,null,null, 'b07bf96e-0a35-4b01-bcc0-863dc7b3db0c', false,null,null, null,create_languagetypeuuid)))
	then tempentityfieldentitytypeentityuuid = create_entityfieldentitytypeentityuuid;
	else return;  -- need an error code here
end if;

-- check for filters on entity type  -- tempentityfieldentitytypeentityuuid is Valid or Null

if create_entityfieldentityparenttypeentityuuid isNull
	then tempentityfieldentityparenttypeentityuuid = create_entityfieldentityparenttypeentityuuid;
	elseif create_entityfieldentityparenttypeentityuuid notNull 
			and tempentityfieldentitytypeentityuuid isNull
		then return; -- need an error code here
	else tempentityfieldentityparenttypeentityuuid = create_entityfieldentityparenttypeentityuuid;
end if;

-- setup the language type

if create_languagetypeuuid isNull
	then templanguagetypeentityuuid = 'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9';
	else templanguagetypeentityuuid = create_languagetypeuuid;
end if;

-- check for a valid format 'ef107a7a-eadd-46dd-be63-d06e8b660852' -- null is ok

if create_entityfieldformatentityuuid isNull 
	then tempentityfieldformatentityuuid = create_entityfieldformatentityuuid;
	elseif create_entityfieldformatentityuuid notNull 
		and create_entityfieldformatentityuuid in 
			(select custagentityuuid
			from entity.custagentityuuid(temptendrelentityuuid,null,null, 'ef107a7a-eadd-46dd-be63-d06e8b660852', false,create_languagetypeuuid)
			union
			select custagentityuuid
			from entity.custagentityuuid(tempentitytemplateownerentityuuid,null,null, 'ef107a7a-eadd-46dd-be63-d06e8b660852', false,create_languagetypeuuid))
	then tempentityfieldformatentityuuid = create_entityfieldformatentityuuid;
	else return;  -- need an error code here
end if;

if tempentityfieldformatentityuuid isNull and create_entityfieldformatentityname notNull
	then 	
		call entity.crud_custag_create(
			tempentitytemplateownerentityuuid, --create_custagownerentityuuid
			'ef107a7a-eadd-46dd-be63-d06e8b660852', --create_custagparententityuuid
			null,   --create_custagcornerstoneentityuuid
			null, --create_custagcornerstoneorder 
			create_entityfieldformatentityname,  -- create_custag
			templanguagetypeentityuuid, -- create_languagetypeuuid  
			null,  -- 	create_custagexternalid text,
			null, -- create_custagexternalsystemuuid
			tempcustagid, -- OUT create_custagid
			tempcustaguuid, -- OUT create_custaguuid text,
			tempentityfieldformatentityuuid, -- OUT create_custagentityuuid uuid
			337::bigint);
end if;

-- check for a valid widget 'd19d9e21-0749-4c2a-96c5-02f648e28826'
if create_entityfieldwidgetentityuuid isNull 
	then tempentityfieldwidgetentityuuid = create_entityfieldwidgetentityuuid;
	elseif create_entityfieldwidgetentityuuid notNull 
		and create_entityfieldwidgetentityuuid in (
				select custagentityuuid 
				from entity.crud_custag_read_min(temptendrelentityuuid,null,null, 'd19d9e21-0749-4c2a-96c5-02f648e28826', false,null,null, null,create_languagetypeuuid)
				union
				select custagentityuuid 
				from entity.crud_custag_read_min(tempentitytemplateownerentityuuid,null,null, 'd19d9e21-0749-4c2a-96c5-02f648e28826', false,null,null, null,create_languagetypeuuid)
					)
	then tempentityfieldwidgetentityuuid = create_entityfieldwidgetentityuuid;
	else return;
end if;

if tempentityfieldwidgetentityuuid isNull and create_entityfieldwidgetentityname notNull
	then 
		call entity.crud_custag_create(
			tempentitytemplateownerentityuuid, --create_custagownerentityuuid
			'd19d9e21-0749-4c2a-96c5-02f648e28826', --create_custagparententityuuid
			null,   --create_custagcornerstoneentityuuid
			null, --create_custagcornerstoneorder 
			create_entityfieldwidgetentityname,  -- create_custag
			templanguagetypeentityuuid, -- create_languagetypeuuid  
			null,  -- 	create_custagexternalid text,
			null, -- create_custagexternalsystemuuid
			tempcustagid, -- OUT create_custagid
			tempcustaguuid, -- OUT create_custaguuid text,
			tempentityfieldwidgetentityuuid, -- OUT create_custagentityuuid uuid
			337::bigint);
end if;

-- check if the parent is an enity field.  
-- This will return null if there is no match and we will use null and fix it later.
select entityfielduuid into tempentityfieldparententityuuid
from entity.crud_entityfield_read_min(create_entityfieldownerentityuuid,null,create_entityfieldparententityuuid ,	null,	null,	null,	null);

select systagid,systaguuid into templanguagetypeid,templanguagetypeuuid
	from entity.crud_systag_read_min(null, null, templanguagetypeentityuuid, null, false,null,null, null,'bcbe750d-1b3b-4e2b-82ec-448bb8b116f9');

-- create cornerstone order

if create_entityfieldcornerstoneorder is Null
	then tempcornerstoneorder = 1::integer;
	else tempcornerstoneorder = create_entityfieldcornerstoneorder::integer;
end if;

If create_entityfielddeleted isNull
	then tempentityfielddeleted = false;
	else tempentityfielddeleted = create_entityfielddeleted;
end if;

If create_entityfielddraft isNull
	then tempentityfielddraft = false;
	else tempentityfielddraft = create_entityfielddraft;
end if;

-- time to insert the base entity template

-- insert name into languagemaster
	insert into public.languagemaster
		(languagemastercustomerid,
		languagemastersourcelanguagetypeid,
		languagemastersource,
		languagemastermodifiedby)
	values(tempcustomerid,
		templanguagetypeid, 	
		tempentityfieldname,    
		create_modifiedbyid)  
	Returning languagemasteruuid into templanguagemasteruuid;

INSERT INTO entity.entityfield(
		entityfieldownerentityuuid, 		
		entityfieldparententityuuid, 		
		entityfieldentitytemplateentityuuid, 
		entityfieldorder, 
		entityfieldname, 
		entityfieldlanguagemasteruuid,   
		entityfieldtypeentityuuid,
		entityfieldentityparenttypeentityuuid, -- not used ATM??  Check
		entityfieldentitytypeentityuuid, 
		entityfielddefaultvalue, 
		entityfieldformatentityuuid, 
		entityfieldwidgetentityuuid, 	
		entityfieldiscalculated, 
		entityfieldiseditable, 
		entityfieldisvisible, 
		entityfieldisrequired,
		entityfieldisprimary, 
		entityfieldtranslate, 
		entityfieldcreateddate, 
		entityfieldmodifieddate, 
		entityfieldstartdate, 
		entityfieldenddate, 
		entityfieldexternalid, 
		entityfieldexternalsystementityuuid,
		entityfieldmodifiedbyuuid,
		entityfielddeleted,
		entityfielddraft
		)
	VALUES (
		tempentitytemplateownerentityuuid, 		
		tempentityfieldparententityuuid, 	-- for nesting  	
		tempentityfieldtemplateentityuuid, 
		tempcornerstoneorder, 
		tempentityfieldname, 
		templanguagemasteruuid,  
		tempentityfieldtypeentityuuid,  -- this is the field type like result.  Uses result.     
		tempentityfieldentityparenttypeentityuuid, -- this is for sys/cus tag.  A way to get greater filtering.  
		tempentityfieldentitytypeentityuuid,  -- this is the entity type
		create_entityfielddefaultvalue,   -- In the future we may want to check for type mismatch.
		tempentityfieldformatentityuuid, 
		tempentityfieldwidgetentityuuid, 	
		case when create_entityfieldiscalculated isNull
			then false
			else create_entityfieldiscalculated
		end,
		case when create_entityfieldiseditable isNull
			then true
			else create_entityfieldiseditable
		end,
		case when create_entityfieldisvisible isNull
			then true
			else create_entityfieldisvisible
		end,
		case when create_entityfieldisrequired isNull
			then false
			else create_entityfieldisrequired
		end,
		case when create_entityfieldisprimary isNull
			then false
			else create_entityfieldisprimary
		end,
		case when create_entityfieldtranslate isNull
			then true
			else create_entityfieldtranslate
		end,
		now(), -- entityfieldcreateddate, 
		now(), -- entityfieldmodifieddate, 
		now(), -- entityfieldstartdate, 
		null, -- entityfieldenddate, 
		create_entityfieldexternalid, 
		create_entityfieldexternalsystemuuid,
		(select workerinstanceuuid from workerinstance where workerinstanceid = create_modifiedbyid),
		tempentityfielddeleted,
		tempentityfielddraft
		)
	returning entityfielduuid into create_entityfieldentityuuid ;

update entity.entityfield
set entityfieldparententityuuid = entityfielduuid
where entityfielduuid = create_entityfieldentityuuid
	and entityfieldparententityuuid isNull;

End;

$procedure$

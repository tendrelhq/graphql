BEGIN;

/*
DROP TRIGGER update_entity_field_tg ON api.entity_field;

DROP FUNCTION api.update_entity_field();
*/


-- Type: FUNCTION ; Name: api.update_entity_field(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_entity_field()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  ins_entity uuid;
  ins_row api.entity_field%rowtype;
  ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
begin

  	if new.owner = 'f90d618d-5de7-4126-8c65-0afb700c6c61' and new._primary = true
  		then new._primary = true;
		else new._primary = false;
	end if;

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_entityfield_update(
			update_entityfielduuid := new.id, 
			update_entityfieldownerentityuuid := new.owner, 
			update_entityfieldparententityuuid := new.parent,
			update_entityfieldtemplateentityuuid := new.template,
			update_entityfieldcornerstoneorder := new._order,
			update_entityfieldname := new.name,
			update_entityfieldtypeentityuuid := new.type,
			update_entityfieldentityparenttypeentityuuid := new.parent_type,
			update_entityfieldentitytypeentityuuid := new.entity_type,
			update_entityfielddefaultvalue := new.default_value,
			update_entityfieldformatentityuuid := new.format,
			update_entityfieldwidgetentityuuid := new.widget,
			update_entityfieldiscalculated := new._calculated,
			update_entityfieldiseditable := new._editable,
			update_entityfieldisvisible := new._visible,
			update_entityfieldisrequired := new._required,
			update_entityfieldisprimary := new._primary,
			update_entityfieldtranslate := new._translate,
			update_entityfieldexternalid := new.external_id,
			update_entityfieldexternalsystemuuid := new.external_system,
			update_entityfielddeleted := new._deleted,
			update_entityfielddraft := new._draft,
			update_entityfieldstartdate := new.activated_at,
			update_entityfieldenddate := new.deactivated_at,
			update_entityfieldmodifiedbyuuid := ins_useruuid,
			update_languagetypeuuid :=  ins_languagetypeentityuuid
		);
	else  
		return null;
end if;

  select * into ins_row
  from api.entity_field
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_entity_field() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_entity_field() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_entity_field() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER update_entity_field_tg INSTEAD OF UPDATE ON api.entity_field FOR EACH ROW EXECUTE FUNCTION api.update_entity_field();


END;

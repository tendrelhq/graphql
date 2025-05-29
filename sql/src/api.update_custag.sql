BEGIN;

/*
DROP TRIGGER update_custag_tg ON api.custag;

DROP FUNCTION api.update_custag();
*/


-- Type: FUNCTION ; Name: api.update_custag(); Owner: tendreladmin

CREATE OR REPLACE FUNCTION api.update_custag()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
	ins_entity uuid;
	ins_row api.custag%rowtype;
  	ins_useruuid text;
	ins_userid bigint;
	ins_languagetypeuuid text;	
	ins_languagetypeentityuuid uuid;
	ins_languagetypeid bigint;
	tempcustomerid bigint;
	tempcustomeruuid text;
begin

select get_workerinstanceid, get_workerinstanceuuid, get_languagetypeid, get_languagetypeuuid, get_languagetypeentityuuid
into ins_userid, ins_useruuid, ins_languagetypeid,ins_languagetypeuuid, ins_languagetypeentityuuid
from _api.util_user_details();

select customerid, customeruuid into tempcustomerid,tempcustomeruuid
	from entity.crud_customer_read_min(null,new.owner,null,false,null,null,null, null);

if (old.id = new.id) 
		and (select old.owner in (select * from _api.util_get_onwership())) 
		and (select new.owner in (select * from _api.util_get_onwership()))
	then 
		call entity.crud_custag_update(
			update_custagentityuuid := new.id,
			update_custagownerentityuuid := new.owner,
			update_custagparententityuuid := new.parent,
			update_custagcornerstoneentityuuid := new.cornerstone,
			update_custagcornerstoneorder := new._order,
			update_custag := new.type,
			update_custag_name := new.name,
			update_custag_displayname := new.displayname,	
			update_languagetypeuuid := ins_languagetypeentityuuid,
			update_custagexternalid := new.external_id,
			update_custagexternalsystemuuid := new.external_system,
			update_custagdeleted := new._deleted,
			update_custagdraft := new._draft,
			update_custagstartdate := new.activated_at,
			update_custagenddate := new.deactivated_at,
			update_custagmodifiedbyuuid := ins_useruuid);

		-- NEED TO UPDATE ALL REASON CODES IN RESULT VALUES.  
		-- MOVE THIS TO A FUNCTION
		-- MIGHT NEED TO MAKE THIS A BATCH IF IT IS A LARGE CHANGE
		-- find the work result values.  3 step modify, translation, source, then value?

		if (old.name <> new.name) 
			then
				update public.languagetranslations
				set languagetranslationvalue = new.name
				from workresultinstance
					inner join view_workresult
						on workresultinstancevalue = old.name				
							and workresultinstanceworkresultid = workresultid
							and workresultcustomerid = tempcustomerid
							and languagetranslationtypeid = 20
							and workresultname = 'Reason Code'
				where languagetranslationmasterid = workresultinstancevaluelanguagemasterid;

				update public.languagemaster
				set languagemastersourcelanguagetypeid = get_languagetypeid,
					languagemastersource = new.name,
					languagemastermodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = ins_useruuid),
					languagemastermodifieddate = now(),
					languagemasterstatus = 'NEEDS_COMPLETE_RETRANSLATION'	
				from workresultinstance
					inner join view_workresult
						on workresultinstancevalue = old.name				
							and workresultinstanceworkresultid = workresultid
							and workresultcustomerid = tempcustomerid
							and languagetranslationtypeid = 20
							and workresultname = 'Reason Code'
				where languagemasterid = workresultinstancevaluelanguagemasterid;
				
				update public.workresultinstance
				set workresultinstancevalue = new.name, 
					workresultinstancemodifieddate = now(),
					workresultinstancemodifiedby = (select workerinstanceid from workerinstance where workerinstanceuuid = ins_useruuid)
				from view_workresult wr
				where workresultinstancevalue = old.name				
					and workresultinstanceworkresultid = workresultid
					and workresultcustomerid = tempcustomerid
					and languagetranslationtypeid = 20
					and workresultname = 'Reason Code';
		end if;
		
	else  
		return null;
end if;

  select * into ins_row
  from api.custag
  where id = old.id;

  if not found then
    return null;
  end if;

  return ins_row;

end 
$function$;


REVOKE ALL ON FUNCTION api.update_custag() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.update_custag() TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION api.update_custag() TO authenticated;

-- DEPENDANTS

CREATE TRIGGER update_custag_tg INSTEAD OF UPDATE ON api.custag FOR EACH ROW EXECUTE FUNCTION api.update_custag();


END;

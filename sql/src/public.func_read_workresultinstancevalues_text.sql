
-- Type: FUNCTION ; Name: func_read_workresultinstancevalues_text(text[],text,text,text,boolean); Owner: tendreladmin

CREATE OR REPLACE FUNCTION public.func_read_workresultinstancevalues_text(func_workinstanceuuidarray text[], func_workresultuuid text, func_workresultname text, func_workresultinstancevaluelanguagetypeuuid text, func_primaryaccuracy boolean)
 RETURNS TABLE(workresultinstancecustomerid bigint, workresultinstanceworkinstanceid bigint, workresultinstancevalue text, workresultinstancevaluelanguagemasterid bigint, workresultinstancevaluelanguagetypeuuid text)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	templanguagetypeid bigint;
	tempworkresultid bigint[];
BEGIN

/*

-- send in the result name
select * from public.func_read_workresultinstancevalues_text(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	null,'RTLS - Online Status',	'7ebd10ee-5018-4e11-9525-80ab5c6aebee',false)

-- send in the resultuuid

select * from public.func_read_workresultinstancevalues_text(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	'work-result_c3483075-d2b5-4324-990d-edf728d72f12',null,	'7ebd10ee-5018-4e11-9525-80ab5c6aebee',false)

*/

-- handle languagetype for value

if (func_workresultinstancevaluelanguagetypeuuid isNull)
	then templanguagetypeid = 20;
	else  templanguagetypeid = (select systagid from systag where systaguuid = func_workresultinstancevaluelanguagetypeuuid);
End if;

-- figure out the workresultid

if func_workresultuuid notNull
	then tempworkresultid = ARRAY(select workresultid from workresult
								where id = func_workresultuuid);
	else tempworkresultid = ARRAY(select workresultid from view_workresult
								where workresultname = func_workresultname
									and workresultworktemplateid in (select distinct workinstanceworktemplateid
																		from workinstance wi
																		where wi.id = any  (func_workinstanceuuidarray))
									and workresultisprimary = func_primaryaccuracy
									and languagetranslationtypeid = 20);
end if;


if (select distinct workresulttranslate from workresult where workresultid = any (tempworkresultid)) = false
	then
		return query
		select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lm.languagemastersource, lm.languagemasterid, func_workresultinstancevaluelanguagetypeuuid
		from workinstance wi
			inner join workresultinstance wri
				on wi.id = any (func_workinstanceuuidarray)
					and wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = any (tempworkresultid)
			inner join languagemaster lm
				on lm.languagemasterid = wri.workresultinstancevaluelanguagemasterid
		group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lm.languagemastersource, lm.languagemasterid;
	else
		return query
		select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lt.languagetranslationvalue, lt.languagetranslationmasterid as languagemasterid, func_workresultinstancevaluelanguagetypeuuid
		from workinstance wi
			inner join workresultinstance wri
				on wi.id = any (func_workinstanceuuidarray)
					and wri.workresultinstanceworkinstanceid = wi.workinstanceid
					and wri.workresultinstanceworkresultid = any (tempworkresultid)
			inner join languagetranslations lt
				on lt.languagetranslationmasterid = wri.workresultinstancevaluelanguagemasterid
					and lt.languagetranslationtypeid = templanguagetypeid
		group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, lt.languagetranslationvalue,lt.languagetranslationmasterid;
end if;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_text(text[],text,text,text,boolean) TO tendreladmin WITH GRANT OPTION;

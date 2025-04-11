
-- Type: FUNCTION ; Name: func_read_workresultinstancevalues_numeric(text[],text,text,boolean); Owner: bombadil

CREATE OR REPLACE FUNCTION public.func_read_workresultinstancevalues_numeric(func_workinstanceuuidarray text[], func_workresultuuid text, func_workresultname text, func_primaryaccuracy boolean)
 RETURNS TABLE(workresultinstancecustomerid bigint, workresultinstanceworkinstanceid bigint, workresultinstancevalue numeric)
 LANGUAGE plpgsql
 ROWS 1e+07
AS $function$

Declare
	tempworkresultid bigint[];
BEGIN

/*

-- send in the result name
select * from public.func_read_workresultinstancevalues_bigint(
	ARRAY['work-instance_6b4b1a13-bf8a-420d-b957-bd18327adcec','work-instance_6b8db70b-8ccb-4de5-adda-d36ea7caafa8','work-instance_f6e68a28-13f4-4ca6-b9a4-417b4286068b'],
	null,'Location', true)

*/

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


create temp table tempwri
as
select wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue
from workinstance wi
	inner join workresultinstance wri
		on wi.id = any (func_workinstanceuuidarray)
			and wri.workresultinstanceworkinstanceid = wi.workinstanceid
			and wri.workresultinstanceworkresultid = any (tempworkresultid)
group by wri.workresultinstancecustomerid, wri.workresultinstanceworkinstanceid, wri.workresultinstancevalue;

return query
	select pl.workresultinstancecustomerid, pl.workresultinstanceworkinstanceid, pl.workresultinstancevalue::numeric
			from tempwri pl;

drop table tempwri;

End;

$function$;


REVOKE ALL ON FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean) TO PUBLIC;
GRANT EXECUTE ON FUNCTION func_read_workresultinstancevalues_numeric(text[],text,text,boolean) TO bombadil WITH GRANT OPTION;

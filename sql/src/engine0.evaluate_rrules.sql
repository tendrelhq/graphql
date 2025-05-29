BEGIN;

/*
DROP FUNCTION engine0.evaluate_rrules(text,text,text,text);
*/


-- Type: FUNCTION ; Name: engine0.evaluate_rrules(text,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.evaluate_rrules(task_id text, task_parent_id text, task_prev_id text DEFAULT NULL::text, task_root_id text DEFAULT NULL::text)
 RETURNS TABLE(target_start_time timestamp with time zone)
 LANGUAGE plpgsql
 STABLE
AS $function$
begin
  return query
    select coalesce(
        engine0.compute_rrule_next_occurrence(
            freq := freq.systagtype,
            interval_v := rr.workfrequencyvalue,
            dtstart := prev.workinstancecompleteddate
        ),
        now()
    ) as target_start_time
    from public.worktemplate as t
    left join public.workinstance as prev on prev.id = task_prev_id
    left join public.workfrequency as rr
        on  rr.workfrequencyworktemplateid = t.worktemplateid
        and (
            rr.workfrequencyenddate is null
            or rr.workfrequencyenddate > now()
        )
    left join public.systag as freq
        on  rr.workfrequencytypeid = freq.systagid
        and freq.systagtype != 'one time'
    where t.id = task_id
  ;

  if not found then
    return query select now() as target_start_time;
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine0.evaluate_rrules(text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_rrules(text,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.evaluate_rrules(text,text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.evaluate_rrules(text,text,text,text) TO graphql;

END;


-- Type: FUNCTION ; Name: legacy0.create_rrule(text,text,numeric,bigint); Owner: tendreladmin

CREATE OR REPLACE FUNCTION legacy0.create_rrule(task_id text, frequency_type text, frequency_interval numeric, modified_by bigint)
 RETURNS TABLE(_id bigint)
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with
        task as (
            select *
            from public.worktemplate
            where id = task_id
        ),

        type as (
            select *
            from public.systag
            where systagparentid = 738 and systagtype = frequency_type
        ),

        ins_freq as (
            insert into public.workfrequency (
                workfrequencycustomerid,
                workfrequencyworktemplateid,
                workfrequencytypeid,
                workfrequencyvalue,
                workfrequencymodifiedby
            )
            select
                task.worktemplatecustomerid,
                task.worktemplateid,
                type.systagid,
                frequency_interval,
                modified_by
            from task, type
            where not exists (
                select 1
                from public.workfrequency as wf
                inner join task on wf.workfrequencyworktemplateid = task.worktemplateid
                inner join type on wf.workfrequencytypeid = type.systagid
                where wf.workfrequencyvalue = frequency_interval
            )
            returning workfrequencyid
        )

    select workfrequencyid as _id
    from ins_freq
    union all
    select wf.workfrequencyid as _id
    from task, type, public.workfrequency as wf
    where
        wf.workfrequencyworktemplateid = task.worktemplateid
        and wf.workfrequencytypeid = type.systagid
        and wf.workfrequencyvalue = frequency_interval
  ;
  --
  if not found then
    raise exception 'failed to create recurrence rule';
  end if;

  return;
end $function$;


REVOKE ALL ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) TO PUBLIC;
GRANT EXECUTE ON FUNCTION legacy0.create_rrule(text,text,numeric,bigint) TO tendreladmin WITH GRANT OPTION;

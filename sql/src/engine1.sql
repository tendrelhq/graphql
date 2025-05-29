BEGIN;

/*
DROP TYPE engine1.result;
DROP FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text);
DROP FUNCTION engine1.set_worktemplateisauditable(jsonb);
DROP FUNCTION engine1.set_worktemplatedraft(jsonb);
DROP FUNCTION engine1.publish_workresult(jsonb);
DROP FUNCTION engine1.instantiate_worktemplate(jsonb);
DROP FUNCTION engine1.instantiate_workresult(jsonb);
DROP FUNCTION engine1.instantiate(jsonb);
DROP FUNCTION engine1.execute(engine1.closure);
DROP FUNCTION engine1.delete_worktemplate(jsonb);
DROP FUNCTION engine1.delete_workresultinstance(jsonb);
DROP FUNCTION engine1.delete_workresult(jsonb);
DROP FUNCTION engine1.delete_workinstance(jsonb);
DROP FUNCTION engine1.delete_node(text,text);
DROP FUNCTION engine1.chain(engine1.closure);
DROP FUNCTION engine1.id(jsonb);
DROP FUNCTION engine1.base64_encode(bytea);
DROP FUNCTION engine1.base64_decode(text);
DROP TYPE engine1.result;
DROP TYPE engine1.node;
DROP TYPE engine1.closure;

DROP SCHEMA engine1;
*/

CREATE SCHEMA engine1;

GRANT USAGE ON SCHEMA engine1 TO graphql;

-- DEPENDANTS


-- Type: TYPE ; Name: closure; Owner: tendreladmin

CREATE TYPE engine1.closure AS (
    f regproc,
    ctx jsonb
);



-- Type: TYPE ; Name: node; Owner: tendreladmin

CREATE TYPE engine1.node AS (
    kind text,
    id text
);



-- Type: TYPE ; Name: result; Owner: tendreladmin

CREATE TYPE engine1.result AS (
    ok boolean,
    created engine1.node[],
    deleted text[],
    updated engine1.node[],
    errors text[]
);



-- Type: FUNCTION ; Name: engine1.base64_decode(text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.base64_decode(data text)
 RETURNS bytea
 LANGUAGE sql
 IMMUTABLE
AS $function$
  with
    t as (select translate(data, '-_', '+/') as trans),
    rem as (select length(t.trans) % 4 as remainder from t) -- compute padding size
  select decode(
      t.trans ||
        case when rem.remainder > 0 then repeat('=', (4 - rem.remainder)) else '' end,
      'base64'
  ) from t, rem;
$function$;


REVOKE ALL ON FUNCTION engine1.base64_decode(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_decode(text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_decode(text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.base64_decode(text) TO graphql;

-- Type: FUNCTION ; Name: engine1.base64_encode(bytea); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.base64_encode(data bytea)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select translate(encode(data, 'base64'), E'+/e\n', '-_');
$function$;


REVOKE ALL ON FUNCTION engine1.base64_encode(bytea) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_encode(bytea) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.base64_encode(bytea) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.base64_encode(bytea) TO graphql;

-- Type: FUNCTION ; Name: engine1.id(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.id(jsonb)
 RETURNS SETOF jsonb
 LANGUAGE sql
 IMMUTABLE
AS $function$select $1$function$;


REVOKE ALL ON FUNCTION engine1.id(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.id(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.id(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.id(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.chain(engine1.closure); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.chain(engine1.closure)
 RETURNS SETOF engine1.closure
 LANGUAGE plpgsql
AS $function$
begin
  if $1.f != 'engine1.id'::regproc then
    return query execute format('select * from %s($1)', $1.f) using $1.ctx;
  end if;
  return;
end $function$;


REVOKE ALL ON FUNCTION engine1.chain(engine1.closure) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.chain(engine1.closure) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.chain(engine1.closure) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.chain(engine1.closure) TO graphql;

-- Type: FUNCTION ; Name: engine1.delete_node(text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_node(kind text, id text)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with op (kind, id) as (values (kind, id))
  select
      'engine1.delete_workresult'::regproc,
      jsonb_agg(workresult.id)
  from op, public.workresult
  where op.kind = 'workresult' and op.id = workresult.id
  union all
  select
      'engine1.delete_worktemplate'::regproc,
      jsonb_agg(worktemplate.id)
  from op, public.worktemplate
  where op.kind = 'worktemplate' and op.id = worktemplate.id
  union all
  select
      'engine1.delete_workresultinstance'::regproc,
      jsonb_agg(wri.workresultinstanceuuid)
  from op, public.workresultinstance as wri
  where op.kind = 'workresultinstance' and op.id = wri.workresultinstanceuuid
  union all
  select
      'engine1.delete_workinstance'::regproc,
      jsonb_agg(workinstance.id)
  from op, public.workinstance
  where op.kind = 'workinstance' and op.id = workinstance.id;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_node(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_node(text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_node(text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.delete_node(text,text) TO graphql;

-- Type: FUNCTION ; Name: engine1.delete_workinstance(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_workinstance(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.workinstance
    set workinstancestatusid = 711,
        workinstancetrustreasoncodeid = 765,
        workinstancemodifieddate = now(),
        workinstancemodifiedby = 895
    where workinstance.id in (select value from jsonb_array_elements_text(ctx))
        and workinstance.workinstancestatusid != 711
        and workinstance.workinstancetrustreasoncodeid != 765
    returning workinstance.id
  )
  select
      'engine1.id'::regproc as f,
      jsonb_build_object(
          'ok', true,
          'deleted', array[cte.id]
      )
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_workinstance(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workinstance(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workinstance(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.delete_workinstance(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.delete_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.workresult
    set workresultdeleted = true,
        workresultmodifieddate = now(),
        workresultmodifiedby = 895
    where workresult.id in (select value from jsonb_array_elements_text(ctx))
        and workresultdeleted = false
    returning workresult.id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'deleted', array[cte.id]
    )
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresult(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresult(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.delete_workresult(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.delete_workresultinstance(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_workresultinstance(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select
      'engine1.id'::regproc,
      jsonb_build_object(
          'ok', true,
          'deleted', array_agg(distinct nodes.value)
      )
  from jsonb_array_elements_text(ctx) as nodes
$function$;


REVOKE ALL ON FUNCTION engine1.delete_workresultinstance(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresultinstance(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_workresultinstance(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.delete_workresultinstance(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.delete_worktemplate(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.delete_worktemplate(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.worktemplate
    set worktemplatedeleted = true,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = 895
    where worktemplate.id in (select value from jsonb_array_elements_text(ctx))
        and worktemplate.worktemplatedeleted = false
    returning worktemplate.id, worktemplate.worktemplateid as _id
  )
  select
      'engine1.id'::regproc,
      jsonb_build_object(
          'ok', true,
          'deleted', array[cte.id]
      )
  from cte
  union all
  select
      'engine1.delete_workinstance'::regproc,
      to_jsonb(array_agg(workinstance.id))
  from cte, public.workinstance
  where cte._id = workinstance.workinstanceworktemplateid
      and workinstance.workinstancestatusid in (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
  ;
$function$;


REVOKE ALL ON FUNCTION engine1.delete_worktemplate(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_worktemplate(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.delete_worktemplate(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.delete_worktemplate(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.execute(engine1.closure); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.execute(engine1.closure)
 RETURNS SETOF engine1.closure
 LANGUAGE plpgsql
 STRICT
AS $function$
begin
  return query
    with recursive cte as (
        select $1.f, $1.ctx
        union all
        select r.*
        from cte, engine1.chain(cte.*) as r
    )
    select cte.f, jsonb_agg(cte.ctx)
    from cte
    where cte.f = 'engine1.id'::regproc -- we only care about the results
    group by cte.f
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine1.execute(engine1.closure) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.execute(engine1.closure) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.execute(engine1.closure) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.execute(engine1.closure) TO graphql;

-- Type: FUNCTION ; Name: engine1.instantiate(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
      select t.instance as node
      from
        jsonb_to_recordset(ctx) as x(
            template_id text,
            location_id text,
            target_state text,
            target_type text,
            chain_root_id text,
            chain_prev_id text
        ),
        engine0.instantiate(
            template_id := x.template_id,
            location_id := x.location_id,
            target_state := x.target_state,
            target_type := x.target_type,
            chain_root_id := x.chain_root_id,
            chain_prev_id := x.chain_prev_id,
            modified_by := 895
        ) as t
      group by t.instance
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'created', jsonb_agg(jsonb_build_object('node', cte.node))
    )
  from cte
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.instantiate(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.instantiate_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    insert into public.workresultinstance (
        workresultinstancecustomerid,
        workresultinstanceworkinstanceid,
        workresultinstanceworkresultid,
        workresultinstancestartdate,
        workresultinstancecompleteddate,
        workresultinstancevalue,
        workresultinstancetimezone,
        workresultinstancemodifiedby
    )
    select
      workinstance.workinstancecustomerid,
      workinstance.workinstanceid,
      workresult.workresultid,
      workinstance.workinstancestartdate,
      workinstance.workinstancecompleteddate,
      workresult.workresultdefaultvalue,
      workinstance.workinstancetimezone,
      auth.current_identity(
          parent := workresult.workresultcustomerid,
          identity := current_setting('user.id')
      ) as modified_by
    from public.workresult
    inner join public.workinstance
        on workresultworktemplateid = workinstanceworktemplateid
    where
      workresult.id in (select value from jsonb_array_elements_text(ctx))
      and workresult.workresultdeleted = false
      and workresult.workresultdraft = false
      and (
          workresult.workresultenddate is null
          or workresult.workresultenddate > now()
      )
      and workinstance.workinstancestatusid = (
          select systagid
          from public.systag
          where systagparentid = 705 and systagtype = 'Open'
      )
    on conflict do nothing
    returning workresultinstanceuuid as id
  )

  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', count(*) > 0,
        'count', count(*),
        'created', coalesce(
          jsonb_agg(jsonb_build_object('node', cte.id)),
          '[]'::jsonb
        )
    )
  from cte
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_workresult(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_workresult(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.instantiate_workresult(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.instantiate_worktemplate(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.instantiate_worktemplate(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
 STABLE
AS $function$
  select
    'engine1.instantiate'::regproc,
    jsonb_agg(
      jsonb_build_object(
          'template_id', worktemplate.id,
          'location_id', location.locationuuid,
          'target_state', 'Open',
          'target_type', 'On Demand'
          -- 'chain_root_id', null,
          -- 'chain_prev_id', null
      )
    )
  from public.worktemplate
  inner join public.worktemplateconstraint
    on worktemplate.id = worktemplateconstrainttemplateid
    and worktemplateconstraintconstrainedtypeid = (
        select systaguuid
        from public.systag
        where systagparentid = 849 and systagtype = 'Location'
    )
  inner join public.custag on worktemplateconstraintconstraintid = custaguuid
  inner join public.location
    on worktemplatesiteid = locationsiteid
    and custagid = locationcategoryid
  where
    worktemplate.id in (select value from jsonb_array_elements_text(ctx))
    and worktemplatedeleted = false
    and worktemplatedraft = false
    and (worktemplateenddate is null or worktemplateenddate > now())
$function$;


REVOKE ALL ON FUNCTION engine1.instantiate_worktemplate(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_worktemplate(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.instantiate_worktemplate(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.instantiate_worktemplate(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.publish_workresult(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.publish_workresult(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.workresult
    set workresultdraft = false,
        workresultmodifieddate = now(),
        workresultmodifiedby = 895
    where id in (select value from jsonb_array_elements_text(ctx))
      and workresultdraft = true
    returning id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte
  union all
  select
    'engine1.instantiate_workresult'::regproc,
    jsonb_agg(cte.id)
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.publish_workresult(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.publish_workresult(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.publish_workresult(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.publish_workresult(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.set_worktemplatedraft(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.set_worktemplatedraft(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.worktemplate
    set worktemplatedraft = args.enabled,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = 895
    from jsonb_to_recordset(ctx) as args (id text, enabled boolean)
    where worktemplate.id = args.id
      and worktemplatedraft = true
      and worktemplatedraft is distinct from args.enabled
    returning worktemplate.id, worktemplateid as _id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte
  union all
  select
    'engine1.instantiate_worktemplate'::regproc,
    jsonb_agg(cte.id)
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.set_worktemplatedraft(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplatedraft(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplatedraft(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplatedraft(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.set_worktemplateisauditable(jsonb); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.set_worktemplateisauditable(ctx jsonb)
 RETURNS SETOF engine1.closure
 LANGUAGE sql
AS $function$
  with cte as (
    update public.worktemplate
    set worktemplateisauditable = args.enabled,
        worktemplatemodifieddate = now(),
        worktemplatemodifiedby = auth.current_identity(worktemplatecustomerid, current_setting('user.id'))
    from jsonb_to_recordset(ctx) as args (id text, enabled boolean)
    where worktemplate.id = args.id
      and worktemplateisauditable is distinct from args.enabled
    returning worktemplate.id
  )
  select
    'engine1.id'::regproc,
    jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
    )
  from cte;
$function$;


REVOKE ALL ON FUNCTION engine1.set_worktemplateisauditable(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplateisauditable(jsonb) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplateisauditable(jsonb) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.set_worktemplateisauditable(jsonb) TO graphql;

-- Type: FUNCTION ; Name: engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine1.upsert_field_t(customer_id text, language_type text, modified_by bigint, template_id text, field_id text, field_name text, field_order integer, field_type text, field_description text DEFAULT NULL::text, field_is_draft boolean DEFAULT false, field_is_primary boolean DEFAULT false, field_is_required boolean DEFAULT false, field_reference_type text DEFAULT NULL::text, field_value text DEFAULT NULL::text, field_widget text DEFAULT NULL::text)
 RETURNS SETOF engine1.closure
 LANGUAGE plpgsql
AS $function$
declare
  delta bigint := 0;
  field text;
begin
  select id into field
  from public.workresult
  where id = field_id;

  if not found then
    select id into field
    from legacy0.create_field_t(
        customer_id := customer_id,
        language_type := language_type,
        modified_by := modified_by,
        template_id := template_id,
        field_description := field_description,
        field_is_draft := field_is_draft,
        field_is_primary := field_is_primary,
        field_is_required := field_is_required,
        field_name := field_name,
        field_order := field_order,
        field_reference_type := field_reference_type,
        field_type := field_type,
        field_value := field_value,
        field_widget := field_widget
    );

    if field is null then
      raise exception 'failed to create result';
    end if;

    return query
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', 1,
          'created', jsonb_build_array(jsonb_build_object('node', field))
        )
      union all
      select
        'engine1.instantiate_workresult'::regproc,
        jsonb_build_array(field)
      where field_is_draft is distinct from true
    ;

    return;
  end if;

  if field is null then
    raise exception 'failed to find result';
  end if;

  return query
    select
      'engine1.publish_workresult'::regproc,
      jsonb_build_array(workresult.id)
    from public.workresult
    where workresult.id = field
      and workresultdraft is distinct from field_is_draft
  ;

  return query
    with cte as (
      update public.workresult
      set workresultorder = field_order,
          workresultmodifieddate = now(),
          workresultmodifiedby = modified_by
      where workresult.id = field
        and workresultorder is distinct from field_order
      returning workresult.id
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', 1,
        'updated', jsonb_build_array(jsonb_build_object('node', id))
      )
    from cte
  ;

  return query
    with cte as (
      update public.workresult
      set workresultisrequired = field_is_required,
          workresultmodifieddate = now(),
          workresultmodifiedby = modified_by
      where workresult.id = field
        and workresultisrequired is distinct from field_is_required
      returning workresult.id
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', 1,
        'updated', jsonb_build_array(jsonb_build_object('node', id))
      )
    from cte
  ;

  if nullif(field_description, '') is null then
    return query
      with cte as (
        update public.workdescription
        set workdescriptionenddate = now(),
            workdescriptionmodifieddate = now(),
            workdescriptionmodifiedby = modified_by
        from public.workresult
        where workresult.id = field
          and workdescriptionworkresultid = workresultid
          and (
            workdescriptionenddate is null
            or workdescriptionenddate > now()
          )
        returning workdescription.id
      )
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', count(*),
          'updated', jsonb_agg(jsonb_build_object('node', cte.id))

        )
      from cte
      having count(*) > 0
    ;
  else
    return query
      with
        cur_desc as (
          select *
          from public.workdescription
          inner join public.languagemaster
            on workdescriptionlanguagemasterid = languagemasterid
          where
            workdescriptionworkresultid = (
                select workresultid
                from public.workresult
                where id = field
            )
            and (
              workdescriptionenddate is null
              or workdescriptionenddate > now()
            )
        ),
        upd_desc as (
          select t.*
          from
            cur_desc,
            i18n.update_localized_content(
                master_id := cur_desc.languagemasteruuid,
                content := field_description,
                language := language_type
            ) as t
        ),
        ins_desc as (
          select t.*
          from i18n.create_localized_content(
              owner := customer_id,
              content := field_description,
              language := language_type
          )
          where not exists (select 1 from cur_desc)
        )
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', count(*),
          'updated', jsonb_agg(jsonb_build_object('node', upd_desc.id))
        )
      from upd_desc
      having count(*) > 0
      union all
      select
        'engine1.id'::regproc,
        jsonb_build_object(
          'ok', true,
          'count', count(*),
          'created', jsonb_agg(jsonb_build_object('node', ins_desc.id))
        )
      from ins_desc
      having count(*) > 0
    ;
  end if;

  return query
    with cte as (
      select t.*
      from
        public.workresult,
        public.languagemaster,
        i18n.update_localized_content(
          master_id := languagemasteruuid,
          content := field_name,
          language := language_type
        ) as t
      where workresult.id = field
        and workresultlanguagemasterid = languagemasterid
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', count(*),
        'updated', jsonb_agg(jsonb_build_object('node', cte.id))
      )
    from cte
    having count(*) > 0
  ;

  -- TODO: this should probably happen via closure.
  return query
    with cte as (
      update public.workresult
      set workresultdefaultvalue = field_value,
          workresultmodifieddate = now(),
          workresultmodifiedby = modified_by
      where workresult.id = field
        and workresultdefaultvalue is distinct from field_value
      returning workresult.id
    )
    select
      'engine1.id'::regproc,
      jsonb_build_object(
        'ok', true,
        'count', 1,
        'updated', jsonb_build_array(jsonb_build_object('node', id))
      )
    from cte
  ;

  return;
end $function$;


REVOKE ALL ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine1.upsert_field_t(text,text,bigint,text,text,text,integer,text,text,boolean,boolean,boolean,text,text,text) TO graphql;

-- Type: TYPE ; Name: result; Owner: tendreladmin

CREATE TYPE engine1.result AS (
    ok boolean,
    created engine1.node[],
    deleted text[],
    updated engine1.node[],
    errors text[]
);



END;

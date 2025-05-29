BEGIN;

/*
DROP FUNCTION engine0.rebase(text,text);
*/


-- Type: FUNCTION ; Name: engine0.rebase(text,text); Owner: tendreladmin

CREATE OR REPLACE FUNCTION engine0.rebase(base text, node text)
 RETURNS TABLE(id text, updates bigint)
 LANGUAGE sql
AS $function$
  -- `base` is our new originator
  -- `node` is whom we will be updating (along with all of its children)
  with recursive
    base as (
      select *
      from public.workinstance
      where id = base
    ),
    node as (
      select *
      from public.workinstance
      where id = node and workinstanceid = workinstanceoriginatorworkinstanceid
      --                  ^---------------------------------------------------^
      --                               node *must* be a chain root
    ),
    to_update as (
      select child.*
      from node, public.workinstance as child
      where node.workinstanceid = child.workinstancepreviousid
        and node.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
      union
      select child.*
      from to_update, public.workinstance as child
      where to_update.workinstanceid = child.workinstancepreviousid
        and to_update.workinstanceoriginatorworkinstanceid = child.workinstanceoriginatorworkinstanceid
    ),
    updated_children as (
      update public.workinstance as t
      set workinstanceoriginatorworkinstanceid = base.workinstanceid,
          workinstancemodifiedby = auth.current_identity(t.workinstancecustomerid, current_setting('user.id')),
          workinstancemodifieddate = now()
      from base, to_update
      where t.id = to_update.id
      returning t.id
    ),
    updated_node as (
      update public.workinstance as t
      set workinstanceoriginatorworkinstanceid = base.workinstanceid,
          workinstancepreviousid = base.workinstanceid,
          workinstancemodifiedby = auth.current_identity(t.workinstancecustomerid, current_setting('user.id')),
          workinstancemodifieddate = now()
      from base, node
      where t.id = node.id
      returning t.id
    )

  select updated_node.id, count(updated_children.*) as updates
  from updated_node
  left join updated_children on true
  group by updated_node.id;
$function$;


REVOKE ALL ON FUNCTION engine0.rebase(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO tendreladmin WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO graphql;

END;

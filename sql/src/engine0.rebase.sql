
-- Type: FUNCTION ; Name: engine0.rebase(text,text); Owner: tendreladmin

-- Rebase a chain onto another chain.
-- Note that `node` can only be a chain root at the moment.
--
-- For example, given two chains:
--
--   A---B---C
--
--  and
--
--   D---E---F---G
--
-- Rebasing A onto D results in:
--
--    A---B---C
--   /
--   D---E---F---G
--
create or replace function engine0.rebase(base text, node text)
returns table(id text, updates bigint)
as $$
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
$$
language sql;

REVOKE ALL ON FUNCTION engine0.rebase(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO tendrelservice;
GRANT EXECUTE ON FUNCTION engine0.rebase(text,text) TO graphql;

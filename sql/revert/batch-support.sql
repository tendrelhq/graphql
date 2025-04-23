-- Revert graphql:batch-support from pg

BEGIN;

revoke all on function legacy0.create_instantiation_rule_v2 from graphql;
revoke all on function engine0.build_instantiation_plan_v2 from graphql;

drop function if exists legacy0.create_instantiation_rule_v2;
drop function if exists engine0.build_instantiation_plan_v2;

alter table public.worktemplatenexttemplate
  drop column if exists worktemplatenexttemplateprevlocationid,
  drop column if exists worktemplatenexttemplatenextlocationid,
  drop column if exists worktemplatenexttemplateuuid
;

COMMIT;

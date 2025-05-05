import { sql } from "@/datasources/postgres";
import { Task } from "@/schema/system/component/task";
import { fsm } from "@/schema/system/component/task_fsm";
import { assert, assertNonNull, nullish } from "@/util";

export async function mostRecentlyInProgress(t: Task): Promise<Task> {
  assert(t._type === "workinstance");
  const [row] = await sql`
    select id
    from public.workinstance
    where
        workinstanceoriginatorworkinstanceid in (
            select og.workinstanceid
            from public.workinstance as og
            where og.id = ${t._id}
        )
        and workinstancestatusid = 707
    order by workinstanceid desc
    limit 1;
  `;
  assert(!nullish(row), "no in progress instance");
  return Task.fromTypeId("workinstance", row.id);
}

export async function mostRecentInstance(t: Task): Promise<Task> {
  assert(t._type === "worktemplate");
  const [row] = await sql`
    select id
    from public.workinstance
    where
      workinstanceworktemplateid in (
        select worktemplateid
        from public.worktemplate
        where id = ${t._id}
      )
    order by workinstanceid desc
    limit 1;
  `;
  assert(!nullish(row), "no instance");
  return Task.fromTypeId("workinstance", row.id);
}

export async function getLatestFsm(t: Task) {
  assert(t._type === "worktemplate");
  const root = await mostRecentInstance(t);
  const f = await fsm(root);
  return { root, fsm: assertNonNull(f) };
}

export async function newlyInstantiatedChainFrom(
  t: Task,
): Promise<Task | null> {
  assert(t._type === "workinstance");
  const [row] = await sql`
    select id
    from public.workinstance
    where
        workinstancepreviousid = (
            select workinstanceid
            from public.workinstance
            where id = ${t._id}
        )
        and workinstancestatusid = 706
  `;
  if (!row) return null;
  return Task.fromTypeId("workinstance", row.id);
}

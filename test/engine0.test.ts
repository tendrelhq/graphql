import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { assert, map } from "@/util";
import { cleanup, createTestContext, findAndEncode } from "./prelude";
import { Task } from "@/schema/system/component/task";
import { setCurrentIdentity } from "@/auth";
import { decodeGlobalId } from "@/schema/system";

const ctx = await createTestContext();

describe("engine0", () => {
  let CUSTOMER: string;
  let INSTANCE: Task;
  let TEMPLATE: Task;

  test("build", async () => {
    const result = await sql`
      select target, target_type, row_to_json(t.*) as condition, *
      from
          engine0.build_instantiation_plan(task_id := ${INSTANCE._id}) as p,
          unnest(p.ops) as t
    `;
    // IMPORTANT! This is the build phase and so what we get back is the
    // *entire* plan. The check phase actually evaluates the conditions.
    expect(result).toBeArrayOfSize(3);
    // expect(result).toMatchSnapshot();
  });

  test("build + check", async () => {
    const r0 = await sql`
      select pc.*
      from
          engine0.build_instantiation_plan(${INSTANCE._id}) as pb,
          engine0.evaluate_instantiation_plan(
              target := pb.target,
              target_type := pb.target_type,
              conditions := pb.ops
          ) as pc
    `;
    // The instance in question is currently Open. The default rules created as
    // part of the MFT demo consist of only InProgress state conditions.
    expect(r0).toHaveLength(0);

    // Set the instance to InProgress.
    await sql`
      update public.workinstance
      set workinstancestatusid = 707
      where id = ${INSTANCE._id}
    `;
    //
    const r1 = await sql`
      select pc.*
      from
          engine0.build_instantiation_plan(${INSTANCE._id}) as pb,
          engine0.evaluate_instantiation_plan(
              target := pb.target,
              target_type := pb.target_type,
              conditions := pb.ops
          ) as pc
      order by pc.system
    `;
    // Now that the instance is InProgress, we expect our plan to include the
    // two default rules included in the MFT demo (Idle, Downtime) as well as
    // the canonical respawn rule.
    expect(r1).toMatchObject([
      {
        result: true,
        system: "engine0.eval_state_condition",
      },
      {
        result: true,
        system: "engine0.eval_state_condition",
      },
      {
        result: true,
        system: "engine0.eval_state_condition",
      },
    ]);
  });

  test("build + check + execute", async () => {
    await sql.begin(async tx => {
      const result =
        await tx`select * from engine0.execute(${INSTANCE._id}, 895)`;
      // We expect only the respawn rule to result in instantiation.
      expect(result).toHaveLength(1);
      expect(result.some(row => !row.instance)).toBeFalse();
    });
  });

  beforeAll(async () => {
    const logs = await sql<{ op: string; id: string }[]>`
      select *
      from runtime.create_demo(
          customer_name := 'Frozen Tendy Factory',
          admins := (
              select array_agg(workeruuid)
              from public.worker
              where workerfullname = 'Jerry Garcia'
          ),
          modified_by := 895
      )
    `;

    CUSTOMER = findAndEncode("customer", "organization", logs);
    TEMPLATE = map(
      findAndEncode("task", "worktemplate", logs),
      id => new Task({ id }),
    );
    INSTANCE = map(
      findAndEncode("instance", "workinstance", logs),
      id => new Task({ id }),
    );
  });

  afterAll(async () => {
    const { id } = decodeGlobalId(CUSTOMER);
    await cleanup(id);
  });
});

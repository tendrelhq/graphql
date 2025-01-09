import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { assert } from "@/util";

describe("engine0", () => {
  let CUSTOMER: string;
  let INSTANCE: string;

  test("build", async () => {
    const result = await sql`
      select target, target_type, row_to_json(t.*) as condition
      from
          engine0.plan_build(task_id := ${INSTANCE}) as p,
          unnest(p.ops) as t
    `;
    // IMPORTANT! This is the build phase and so what we get back is the
    // *entire* plan. The check phase actually evaluates the conditions.
    expect(result).toBeArrayOfSize(2);
  });

  test("build + check", async () => {
    const r0 = await sql`
      select pc.*
      from
          engine0.plan_build(${INSTANCE}) as pb,
          engine0.plan_check(
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
      where id = ${INSTANCE}
    `;
    //
    const r1 = await sql`
      select pc.*
      from
          engine0.plan_build(${INSTANCE}) as pb,
          engine0.plan_check(
              target := pb.target,
              target_type := pb.target_type,
              conditions := pb.ops
          ) as pc
      order by pc.system
    `;
    // Now that the instance is InProgress, we expect our plan to include the
    // two default rules included in the MFT demo (Idle, Downtime).
    expect(r1).toBeArrayOfSize(2);
    expect(r1).toMatchSnapshot();
  });

  test("build + check + execute", async () => {
    await sql.begin(async tx => {
      const result = await tx`select * from engine0.execute(${INSTANCE})`;
      expect(result.at(0)?.instance).toBeTruthy();
      await tx`rollback and chain`; // to avoid 25P01 error
    });
  });

  beforeAll(async () => {
    const logs = await sql`
      select *
      from mft.create_demo(
          customer_name := 'Frozen Tendy Factory',
          admins := (
              select array_agg(workeruuid)
              from public.worker
              where workerfullname = 'Jerry Garcia'
          )
      )
    `;

    CUSTOMER = logs.find(({ op }) => op.trim() === "+customer")?.id;
    assert(!!CUSTOMER);

    INSTANCE = logs.find(({ op }) => op.trim() === "+instance")?.id;
    assert(!!INSTANCE);

    console.debug("setup:", { CUSTOMER, INSTANCE });
  });

  afterAll(async () => {
    assert(!!CUSTOMER);
    process.stderr.write("Cleaning up... ");
    const [row] = await sql`
      select mft.destroy_demo(${CUSTOMER}) as ok;
    `;
    console.debug(row.ok);
  });
});

// test("fc tutorial", () => {
//   fc.assert(
//     fc.property(fc.array(fc.integer()), data => {
//       const sorted = data.toSorted((a, b) => a - b);
//       for (let i = 1; i < data.length; ++i) {
//         expect(sorted[i - 1]).toBeLessThanOrEqual(sorted[i]);
//       }
//     }),
//     { numRuns: 100_000 },
//   );
// });

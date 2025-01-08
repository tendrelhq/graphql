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
    expect(result).toBeArrayOfSize(2);
  });

  test("build + check", async () => {
    // set the instance to 'in progress'
    await sql`
      update public.workinstance
      set workinstancestatusid = 707
      where id = ${INSTANCE}
    `;

    const result = await sql`
      select pc.*
      from
          engine0.plan_build(${INSTANCE}) as pb,
          engine0.plan_check(
              target := pb.target,
              target_type := pb.target_type,
              conditions := pb.ops
          ) as pc
    `;
    expect(result).toMatchSnapshot();
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

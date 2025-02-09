import {
  afterAll,
  afterEach,
  beforeAll,
  describe,
  expect,
  test,
} from "bun:test";
import { sql } from "@/datasources/postgres";
import { assert } from "@/util";

describe("engine/scheduling", () => {
  let CUSTOMER: string;
  let INSTANCE: string;
  let RRULE: number;

  async function create_rrule(type: string, interval: number): Promise<number> {
    const [row] = await sql<[{ _id: number }]>`
      select rr._id
      from
          public.workinstance as i,
          public.worktemplate as t,
          util.create_rrule(
              task_id := t.id,
              frequency_type := ${type},
              frequency_interval := ${interval},
              modified_by := 895
          ) as rr
      where i.id = ${INSTANCE} and i.workinstanceworktemplateid = t.worktemplateid
    `;
    return row._id;
  }

  test("every 12 hours", async () => {
    RRULE = await create_rrule("day", 2); // "every 12 hours"
    assert(!!RRULE);

    // Set the instance to InProgress.
    // FIXME: also set completeddate which, I know, is stupid AF. This needs to
    // be fixed, i.e. calculating target start when completed is null.
    const u = await sql`
      update public.workinstance
      set workinstancestatusid = 707, workinstancecompleteddate = now()
      where id = ${INSTANCE}
    `;
    assert(u.count === 1);

    const result = await sql.begin(async tx => {
      const rows = await tx<[{ instance: string }?]>`
        select * from engine0.execute(${INSTANCE}, 895)
      `;
      assert(!!rows.at(0)?.instance);
      return await tx<[{ diff: string }?]>`
        select next.workinstancetargetstartdate - prev.workinstancecompleteddate as diff
        from public.workinstance as prev
        inner join public.workinstance as next
            on prev.workinstanceid = next.workinstancepreviousid
        where prev.id = ${INSTANCE} and next.id = ${
          // biome-ignore lint/style/noNonNullAssertion:
          rows[0]!.instance
        }
      `;
    });

    expect(result.at(0)?.diff).toBe("12:00:00"); // "every 12 hours"
  });

  afterEach(async () => {
    assert(!!RRULE);
    const result = await sql`
        delete from public.workfrequency
        where workfrequencyid = ${RRULE}
      `;
    assert(result.count === 1);
  });

  beforeAll(async () => {
    const logs = await sql`
      select *
      from runtime.create_demo(
          customer_name := 'engine0.test.ts',
          admins := (
              select array_agg(workeruuid)
              from public.worker
              where workerfullname = 'Jerry Garcia'
          ),
          modified_by := 895
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
      select runtime.destroy_demo(${CUSTOMER}) as ok;
    `;
    console.debug(row.ok);
  });
});

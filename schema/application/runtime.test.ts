import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { NOW, createTestContext, execute } from "@/test/prelude";
import { assert, nullish } from "@/util";
import { Task } from "../system/component/task";
import {
  TestRuntimeApplyFieldEditsMutationDocument,
  TestRuntimeDetailDocument,
  TestRuntimeEntrypointDocument,
  TestRuntimeTransitionMutationDocument,
} from "./runtime.test.generated";

const ctx = await createTestContext();

describe.skipIf(!!process.env.CI)("runtime demo", () => {
  // See beforeAll for initialization of these variables.
  let ACCOUNT: string; // customer
  let FSM: Task; // instance
  let IDLE_TIME: Task; // template
  let DOWNTIME: Task; // template

  test("entrypoint query", async () => {
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      root: ACCOUNT,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("start run", async () => {
    const h = (await FSM.hash()) as string;
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM.id,
            hash: h,
          },
          task: {
            id: FSM.id,
            hash: h,
            overrides: [
              {
                field: await overrideStartTimeField(FSM),
                value: {
                  timestamp: NOW.toISOString(),
                },
                valueType: "timestamp",
              },
              {
                field: await getFieldByName(FSM, "Comments"),
                // Test null field-level overrides:
                value: undefined,
                // value: {
                //   string:
                //     "We got off to a late start, hence this comment and the overridden start time!",
                // },
                valueType: "string",
              },
            ],
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("stale: start run (should fail)", async () => {
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM.id,
            hash: (await FSM.hash()) as string,
          },
          task: {
            id: FSM.id,
            hash: "alienz r real",
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("production -> idle time", async () => {
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM.id,
            hash: (await FSM.hash()) as string,
          },
          task: {
            id: IDLE_TIME.id,
            hash: "", // doesn't matter
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("stale: production -> idle time (should fail)", async () => {
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM.id,
            hash: "fake it till you make it",
          },
          task: {
            id: IDLE_TIME.id,
            hash: "", // doesn't matter
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end idle time", async () => {
    const t = await mostRecentlyInProgress(FSM);
    await assertTaskIsNamed(t, "Idle Time");
    const h = (await t.hash()) as string;

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM.id,
            hash: (await FSM.hash()) as string,
          },
          task: {
            id: t.id,
            hash: h,
            overrides: [
              {
                field: await getFieldByName(t, "Description"),
                value: {
                  string: "We idled for awhile, twas a no wake zone...",
                },
                valueType: "string",
              },
            ],
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();

    // While we're here, let's test stale completion as well!
    const stale = await execute(schema, TestRuntimeTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: {
          id: FSM.id,
          hash: (await FSM.hash()) as string,
        },
        task: {
          id: t.id,
          hash: h,
        },
      },
    });
    expect(stale.errors).toBeFalsy();
    expect(stale.data).toMatchSnapshot();
  });

  test("detail query", async () => {
    const result = await execute(schema, TestRuntimeDetailDocument, {
      node: FSM.id,
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        chainAgg: [
          {
            group: "Idle Time",
            value: expect.stringMatching(/[\d]+.[\d]+/),
            __typename: "Aggregate",
          },
          {
            group: "Runtime",
            value: null,
            __typename: "Aggregate",
          },
        ],
        chain: {
          edges: [
            {
              node: {
                displayName: {
                  name: {
                    value: "Run",
                    __typename: "DynamicString",
                  },
                  __typename: "DisplayName",
                },
                state: {
                  __typename: "InProgress",
                },
                __typename: "Task",
              },
              __typename: "TaskEdge",
            },
            {
              node: {
                displayName: {
                  name: {
                    value: "Idle Time",
                    __typename: "DynamicString",
                  },
                  __typename: "DisplayName",
                },
                state: {
                  __typename: "Closed",
                },
                __typename: "Task",
              },
              __typename: "TaskEdge",
            },
          ],
          totalCount: 2,
          __typename: "TaskConnection",
        },
        __typename: "Task",
      },
    });
  });

  test("production -> downtime", async () => {
    const t = await mostRecentlyInProgress(FSM);
    expect(t.id).toBe(FSM.id);

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: t.id,
            hash: (await t.hash()) as string,
          },
          task: {
            id: DOWNTIME.id,
            hash: "", // doesn't matter
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end downtime", async () => {
    const t = await mostRecentlyInProgress(FSM);
    assertTaskIsNamed(t, "Downtime");

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM.id,
            hash: (await FSM.hash()) as string,
          },
          task: {
            id: t.id,
            hash: (await t.hash()) as string,
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("another idle run", async () => {
    const t = await mostRecentlyInProgress(FSM);
    expect(t.id).toBe(FSM.id);

    const start = await execute(schema, TestRuntimeTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: {
          id: t.id,
          hash: (await t.hash()) as string,
        },
        task: {
          id: IDLE_TIME.id,
          hash: "", // doesn't matter
        },
      },
    });
    expect(start.errors).toBeFalsy();

    const t0 = await mostRecentlyInProgress(FSM);
    assertTaskIsNamed(t0, "Idle Time");

    const end = await execute(schema, TestRuntimeTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: {
          id: FSM.id,
          hash: (await FSM.hash()) as string,
        },
        task: {
          id: t0.id,
          hash: (await t0.hash()) as string,
        },
      },
    });
    expect(end.errors).toBeFalsy();
    assertNoDiagnostics(end.data?.advance);

    const t1 = await mostRecentlyInProgress(FSM);
    expect(t1.id).toBe(FSM.id);
  });

  test("end run", async () => {
    const t = await mostRecentlyInProgress(FSM);
    expect(t.id).toBe(FSM.id);
    const h = (await t.hash()) as string;

    const result0 = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
        opts: {
          fsm: {
            id: t.id,
            hash: h,
          },
          task: {
            id: t.id,
            hash: h,
          },
        },
      },
    );
    expect(result0.errors).toBeFalsy();
    expect(result0.data).toMatchSnapshot();

    // Concurrency time! This time let's try to end and already closed task.
    // FIXME: currently this will return a no_associated_fsm diagnostic which
    // is sort of a lie. Really what we want here is a hash_mismatch diagnostic
    // because that is the real root cause here.
    const result1 = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
        opts: {
          fsm: {
            id: t.id,
            hash: h,
          },
          task: {
            id: t.id,
            hash: h,
          },
        },
      },
    );
    expect(result1.errors).toBeFalsy();
    expect(result1.data).toMatchSnapshot();
  });

  test("apply field edits retroactively", async () => {
    const result = await execute(
      schema,
      TestRuntimeApplyFieldEditsMutationDocument,
      {
        entity: FSM.id,
        edits: [
          {
            field: await overrideStartTimeField(FSM),
            // Test null field-level overrides:
            value: undefined,
            valueType: "timestamp",
          },
          {
            field: await getFieldByName(FSM, "Comments"),
            value: {
              string: "Don't mind me! Just leaving a comment :)",
            },
            valueType: "string",
          },
        ],
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("history query", async () => {
    const result = await execute(schema, TestRuntimeDetailDocument, {
      node: FSM.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        __typename: "Task",
        chain: {
          __typename: "TaskConnection",
          edges: [
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                displayName: {
                  __typename: "DisplayName",
                  name: {
                    __typename: "DynamicString",
                    value: "Run",
                  },
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                displayName: {
                  __typename: "DisplayName",
                  name: {
                    __typename: "DynamicString",
                    value: "Idle Time",
                  },
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                displayName: {
                  __typename: "DisplayName",
                  name: {
                    __typename: "DynamicString",
                    value: "Downtime",
                  },
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              __typename: "TaskEdge",
              node: {
                __typename: "Task",
                displayName: {
                  __typename: "DisplayName",
                  name: {
                    __typename: "DynamicString",
                    value: "Idle Time",
                  },
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
          ],
          totalCount: 4,
        },
        chainAgg: [
          {
            __typename: "Aggregate",
            group: "Downtime",
            value: expect.any(String),
          },
          {
            __typename: "Aggregate",
            group: "Idle Time",
            value: expect.any(String),
          },
          {
            __typename: "Aggregate",
            group: "Runtime",
            value: expect.any(String),
          },
        ],
        parent: {
          __typename: "Location",
          name: {
            __typename: "Name",
            value: "Mixing Line",
          },
        },
      },
    });
  });

  test("includeInactive", async () => {
    // Deactivate all templates for ACCOUNT.
    const r0 = await sql`
      update public.worktemplate
      set worktemplateenddate = now()
      where worktemplatecustomerid = (
          select customerid
          from public.customer
          where customeruuid = ${decodeGlobalId(ACCOUNT).id}
      )
    `;
    assert(r0.count > 0);

    // Without `includeInactive` we should get nothing back.
    const r1 = await execute(schema, TestRuntimeEntrypointDocument, {
      root: ACCOUNT,
      impl: "Task",
    });
    expect(r1.data?.trackables?.totalCount).toBe(0);

    // With `includeInactive` we should get back exactly what we got in the
    // previous test: "history query". We just assert on the count since we
    // already asserted on the content in the aforementioned test.
    const r2 = await execute(schema, TestRuntimeEntrypointDocument, {
      root: ACCOUNT,
      impl: "Task",
      includeInactive: true,
    });
    expect(r2.data?.trackables?.totalCount).toBe(1);
  });

  test("garbage", async () => {
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: encodeGlobalId({
              type: "workinstance",
              id: "fake it till you make it",
            }),
            hash: "we won't make it here lol",
          },
          task: {
            id: IDLE_TIME.id,
            hash: "", // doesn't matter
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  beforeAll(async () => {
    const logs = await sql<{ op: string; id: string }[]>`
      select *
      from
          runtime.create_demo(
              customer_name := 'Frozen Tendy Factory',
              admins := array[
                  'worker_69d4c075-39d0-4437-a9cc-7b912c7ba049',
                  'worker_a5d1d16f-4264-45e7-97c6-1ef534b8875f'
              ],
              modified_by := 895
          )
      ;
    `;

    function debugLogs() {
      let i = 0;
      for (const l of logs) {
        console.log(`${i++}: ${JSON.stringify(l)}`);
      }
    }

    // we get customer uuid back in the first row
    const row1 = logs.at(1 - 1);
    // but we can check the tag to be sure
    if (row1?.op?.trim() !== "+customer") {
      debugLogs();
      throw "setup failed to find customer";
    }
    ACCOUNT = encodeGlobalId({
      type: "organization", // bleh
      id: row1.id,
    });

    // grab the first instance from the 20th row
    const row20 = logs.at(20 - 1);
    // but we can check the tag to be sure
    if (row20?.op?.trim() !== "+instance") {
      debugLogs();
      throw "setup failed to find 'Run' task instance";
    }
    FSM = makeTask("workinstance", row20.id);

    // we get 'Idle Time' in the 29th row
    const row29 = logs.at(29 - 1);
    // but we can check the tag to be sure
    if (row29?.op?.trim() !== "+next") {
      debugLogs();
      throw "setup failed to find 'Idle Time' task template";
    }
    IDLE_TIME = makeTask("worktemplate", row29.id);

    // we get 'Downtime' in the 39th row
    const row39 = logs.at(39 - 1);
    // but we can check the tag to be sure
    if (row39?.op?.trim() !== "+next") {
      debugLogs();
      throw "setup failed to find 'Downtime' task template";
    }
    DOWNTIME = makeTask("worktemplate", row39.id);
  });

  afterAll(async () => {
    const rows = await sql`
      update public.workinstance
      set workinstancestatusid = 710
      where
          workinstancecustomerid in (
              select customerid
              from public.customer
              where customeruuid = ${decodeGlobalId(ACCOUNT).id}
          )
          and workinstancestatusid = 707
      returning id
      ;
    `;

    if (rows.count) {
      console.warn(
        `
==========
Test suite finished with ${rows.count} in progress instances lingering.
This should be considered a BUG!

Linguine instances:
${rows.map(r => ` - ${r.id}`).join("\n")}
==========
        `,
      );
    }

    const { id } = decodeGlobalId(ACCOUNT);
    // useful for debugging tests:
    if (process.env.SKIP_RUNTIME_CLEANUP) {
      console.log(
        "Skipping clean up... don't forget to cleanup after yourself!",
      );
      console.debug(`select runtime.destroy_demo(${id})`);
      return;
    }

    process.stdout.write("Cleaning up... ");
    const [row] = await sql<[{ ok: string }]>`
      select runtime.destroy_demo(${id}) as ok;
    `;
    console.log(row.ok);
  });
});

/**
 * HACK! Grabs the "most recently in progress" workinstance for this test suite.
 * Temporary utility function while we are in the implementation phase of Runtime.
 */
async function mostRecentlyInProgress(t: Task): Promise<Task> {
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
    order by workinstanceid DESC
    limit 1;
  `;
  assert(!nullish(row), "no in progress instance");
  return makeTask("workinstance", row.id);
}

/**
 * HACK! Grabs the "Override Start Time" field (i.e. workresult) for the given
 * work instance.
 */
async function overrideStartTimeField(t: Task): Promise<string> {
  assert(t._type === "workinstance");
  const [row] = await sql`
    select encode(('workresult:' || wr.id)::bytea, 'base64') as id
    from public.workresult as wr
    where
        wr.workresultorder = 0
        and wr.workresultisprimary = true
        and wr.workresulttypeid in (
            select s.systagid
            from public.systag as s
            where s.systagparentid = 699 and s.systagtype = 'Date'
        )
        and wr.workresultworktemplateid in (
            select wi.workinstanceworktemplateid
            from public.workinstance as wi
            where wi.id = ${t._id}
        )
  `;
  assert(nullish(row) === false, "no override start time field");
  return row.id;
}

async function getFieldByName(t: Task, name: string): Promise<string> {
  assert(t._type === "workinstance");
  const [row] = await sql`
    select encode(('workresult:' || wr.id)::bytea, 'base64') as id
    from public.workresult as wr
    inner join public.languagemaster as lm
        on wr.workresultlanguagemasterid = lm.languagemasterid
    where
        lm.languagemastersource = ${name}
        and wr.workresultisprimary = false
        and wr.workresultworktemplateid in (
            select wi.workinstanceworktemplateid
            from public.workinstance as wi
            where wi.id = ${t._id}
        )
  `;
  assert(nullish(row) === false, `no named field '${name}'`);
  return row.id;
}

function makeTask(type: "worktemplate" | "workinstance", id: string) {
  return new Task({ id: encodeGlobalId({ type, id }) }, ctx);
}

async function assertTaskIsNamed(t: Task, displayName: string) {
  const dn = await t.displayName();
  const n = await dn.name(ctx);
  return n.value === displayName;
}

function assertNoDiagnostics<T, R extends { __typename?: T }>(
  result?: R | null,
) {
  assert(result?.__typename !== "Diagnostic");
}

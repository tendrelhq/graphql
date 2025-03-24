import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { Task } from "@/schema/system/component/task";
import {
  NOW,
  assertNoDiagnostics,
  assertTaskIsNamed,
  cleanup,
  createTestContext,
  execute,
  findAndEncode,
  getFieldByName,
  setup,
} from "@/test/prelude";
import { assert, map, nullish } from "@/util";
import {
  TestRuntimeApplyFieldEditsMutationDocument,
  TestRuntimeDetailDocument,
  TestRuntimeEntrypointDocument,
  TestRuntimeTransitionMutationDocument,
} from "./runtime.test.generated";
import { setCurrentIdentity } from "@/auth";

const ctx = await createTestContext();

const NOW_PLUS_24H = new Date(NOW.valueOf() + 24 * 60 * 60 * 1000);

describe("runtime demo", () => {
  // See beforeAll for initialization of these variables.
  let CUSTOMER: string;
  let FSM_T: Task; // template
  let FSM_I: Task; // instance
  let IDLE_TIME: Task; // template
  let DOWNTIME: Task; // template

  test("entrypoint query", async () => {
    const result = await execute(schema, TestRuntimeEntrypointDocument, {
      root: CUSTOMER,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("start run", async () => {
    const h = (await FSM_I.hash()) as string;
    const ov = await getFieldByName(FSM_I, "Override Start Time");
    const cs = await getFieldByName(FSM_I, "Comments");
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM_I.id,
            hash: h,
          },
          task: {
            id: FSM_I.id,
            hash: h,
            overrides: [
              {
                field: ov.id,
                value: {
                  timestamp: NOW.toISOString(),
                },
                valueType: "timestamp",
              },
              {
                field: cs.id,
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
            id: FSM_I.id,
            hash: (await FSM_I.hash()) as string,
          },
          task: {
            id: FSM_I.id,
            hash: "alienz r real",
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("sanity check: engine sets previous", async () => {
    const newChain = await newlyInstantiatedChainFrom(FSM_I);
    const newChainPrevious = await newChain?.previous();
    expect(newChainPrevious?.id).toBe(FSM_I.id);
  });

  test("production -> idle time", async () => {
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM_I.id,
            hash: (await FSM_I.hash()) as string,
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
            id: FSM_I.id,
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
    const t = await mostRecentlyInProgress(FSM_I);
    await assertTaskIsNamed(t, "Idle Time", ctx);
    const h = (await t.hash()) as string;
    const desc = await getFieldByName(t, "Description");
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM_I.id,
            hash: (await FSM_I.hash()) as string,
          },
          task: {
            id: t.id,
            hash: h,
            overrides: [
              {
                field: desc.id,
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
          id: FSM_I.id,
          hash: (await FSM_I.hash()) as string,
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
      node: FSM_I.id,
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
                name: {
                  value: "Run",
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
                name: {
                  value: "Idle Time",
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
    const t = await mostRecentlyInProgress(FSM_I);
    expect(t.id).toBe(FSM_I.id);

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
    const t = await mostRecentlyInProgress(FSM_I);
    await assertTaskIsNamed(t, "Downtime", ctx);

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: false,
        opts: {
          fsm: {
            id: FSM_I.id,
            hash: (await FSM_I.hash()) as string,
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
    const t = await mostRecentlyInProgress(FSM_I);
    expect(t.id).toBe(FSM_I.id);

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

    const t0 = await mostRecentlyInProgress(FSM_I);
    await assertTaskIsNamed(t0, "Idle Time", ctx);

    const end = await execute(schema, TestRuntimeTransitionMutationDocument, {
      includeChain: false,
      opts: {
        fsm: {
          id: FSM_I.id,
          hash: (await FSM_I.hash()) as string,
        },
        task: {
          id: t0.id,
          hash: (await t0.hash()) as string,
        },
      },
    });
    expect(end.errors).toBeFalsy();
    assertNoDiagnostics(end.data?.advance);

    const t1 = await mostRecentlyInProgress(FSM_I);
    expect(t1.id).toBe(FSM_I.id);
  });

  test("end run", async () => {
    const t = await mostRecentlyInProgress(FSM_I);
    expect(t.id).toBe(FSM_I.id);
    const h = (await t.hash()) as string;
    const ov = await getFieldByName(FSM_I, "Override End Time");

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
            overrides: [
              {
                field: ov.id,
                value: {
                  timestamp: NOW_PLUS_24H.toISOString(),
                },
                valueType: "timestamp",
              },
            ],
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
    const cs = await getFieldByName(FSM_I, "Comments");
    const result = await execute(
      schema,
      TestRuntimeApplyFieldEditsMutationDocument,
      {
        entity: FSM_I.id,
        edits: [
          {
            field: cs.id,
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
      node: FSM_I.id,
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
                name: {
                  __typename: "DisplayName",
                  value: "Run",
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
                name: {
                  __typename: "DisplayName",
                  value: "Idle Time",
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
                name: {
                  __typename: "DisplayName",
                  value: "Downtime",
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
                name: {
                  __typename: "DisplayName",
                  value: "Idle Time",
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
            value: "86400.000000", // overrides are taken into account
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
    // Deactivate all templates for CUSTOMER.
    const r0 = await sql`
      update public.worktemplate
      set worktemplateenddate = now()
      where worktemplatecustomerid = (
          select customerid
          from public.customer
          where customeruuid = ${decodeGlobalId(CUSTOMER).id}
      )
    `;
    assert(r0.count > 0);

    // Without `includeInactive` we should get nothing back.
    const r1 = await execute(schema, TestRuntimeEntrypointDocument, {
      root: CUSTOMER,
      impl: "Task",
    });
    expect(r1.data?.trackables?.totalCount).toBe(0);

    // With `includeInactive` we should get back exactly what we got in the
    // previous test: "history query". We just assert on the count since we
    // already asserted on the content in the aforementioned test.
    const r2 = await execute(schema, TestRuntimeEntrypointDocument, {
      root: CUSTOMER,
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
    const logs = await setup(ctx);
    try {
      CUSTOMER = findAndEncode("customer", "organization", logs);
      FSM_T = map(
        findAndEncode("task", "worktemplate", logs),
        id => new Task({ id }),
      );
      FSM_I = map(
        findAndEncode("instance", "workinstance", logs),
        id => new Task({ id }),
      );
      IDLE_TIME = map(
        findAndEncode("next", "worktemplate", logs),
        id => new Task({ id }),
      );

      // we get 'Downtime' in the 38th row
      const row38 = logs.at(38 - 1);
      // but we can check the tag to be sure
      if (row38?.op?.trim() !== "+next") {
        throw "setup failed to find Downtime";
      }
      DOWNTIME = Task.fromTypeId("worktemplate", row38.id);
    } catch (e) {
      let i = 0;
      for (const l of logs) {
        console.log(`${i++}: ${JSON.stringify(l)}`);
      }
      throw e;
    }

    // We don't currently have a mechanism to specify descriptions during
    // customer create. We'll do it manually for now.
    const d0 = await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      return await sql`
        with content as (
            select *
            from i18n.create_localized_content(
                owner := ${decodeGlobalId(CUSTOMER).id},
                content := 'This is a really important task. Please do your best :)',
                language := 'en'
            )
        )

        insert into public.workdescription (
            workdescriptioncustomerid,
            workdescriptionworktemplateid,
            workdescriptionlanguagemasterid,
            workdescriptionlanguagetypeid
        )
        select
            worktemplate.worktemplatecustomerid,
            worktemplate.worktemplateid,
            content._id,
            20
        from content, public.worktemplate
        where worktemplate.id = ${FSM_T._id}
      `;
    });
    assert(d0.count === 1);

    const f = await FSM_T.field({ byName: "Comments" });
    const d1 = await sql.begin(async sql => {
      await setCurrentIdentity(sql, ctx);
      return await sql`
        with content as (
            select *
            from i18n.create_localized_content(
                owner := ${decodeGlobalId(CUSTOMER).id},
                content := 'If anything goes wrong, this is the place to note it down',
                language := 'en'
            )
        )

        insert into public.workdescription (
            workdescriptioncustomerid,
            workdescriptionworktemplateid,
            workdescriptionworkresultid,
            workdescriptionlanguagemasterid,
            workdescriptionlanguagetypeid
        )
        select
            workresult.workresultcustomerid,
            workresult.workresultworktemplateid,
            workresult.workresultid,
            content._id,
            20
        from content, public.workresult
        where workresult.id = ${decodeGlobalId(f!.id).id}
      `;
    });
    assert(d1.count === 1);
  });

  afterAll(async () => {
    const rows = await sql`
      select id
      from public.workinstance
      where
          workinstancecustomerid in (
              select customerid
              from public.customer
              where customeruuid = ${decodeGlobalId(CUSTOMER).id}
          )
          and workinstancestatusid = 707
      ;
    `;

    if (rows.count) {
      console.warn(
        `
==========
Test suite finished with ${rows.length} in progress instances lingering.
This should be considered a BUG!

Linguine instances:
${rows.map(r => ` - ${r.id}`).join("\n")}
==========
        `,
      );
    }

    await cleanup(CUSTOMER);
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
    order by workinstanceid desc
    limit 1;
  `;
  assert(!nullish(row), "no in progress instance");
  return Task.fromTypeId("workinstance", row.id);
}

async function newlyInstantiatedChainFrom(t: Task): Promise<Task | null> {
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

import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { sql } from "@/datasources/postgres";
import { schema } from "@/schema/final";
import { Task } from "@/schema/system/component/task";
import { fsm } from "@/schema/system/component/task_fsm";
import {
  type Customer,
  NOW,
  assertTaskIsNamed,
  createTestContext,
  execute,
  getFieldByName,
} from "@/test/prelude";
import { assertNonNull } from "@/util";
import { createCustomer } from "./prelude/canonical";
import {
  TestRuntimeApplyFieldEditsMutationDocument,
  TestRuntimeDetailDocument,
  TestRuntimeEntrypointDocument,
  TestRuntimeTransitionMutationDocument,
} from "./runtime.test.generated";

const ctx = await createTestContext();

const NOW_PLUS_24H = new Date(NOW.valueOf() + 24 * 60 * 60 * 1000);

describe("runtime demo", () => {
  let CUSTOMER: Customer; // set in `beforeAll`
  let ROOT: Task; // set in "entrypoint query"

  test(
    "entrypoint query",
    async () => {
      const result = await execute(schema, TestRuntimeEntrypointDocument, {
        parent: CUSTOMER.id,
      });
      expect(result.errors).toBeFalsy();

      expect(result.data?.trackables?.edges?.length).toBe(5);
      expect(result.data?.trackables?.edges).toMatchObject([
        {
          node: {
            name: {
              value: "Mixing Line",
            },
            tracking: {
              edges: [
                {
                  node: {
                    name: {
                      value: "Run",
                    },
                    state: {
                      __typename: "Open",
                    },
                  },
                },
              ],
            },
          },
        },
        {
          node: {
            name: {
              value: "Fill Line",
            },
          },
        },
        {
          node: {
            name: {
              value: "Assembly Line",
            },
          },
        },
        {
          node: {
            name: {
              value: "Cartoning Line",
            },
          },
        },
        {
          node: {
            name: {
              value: "Packaging Line",
            },
          },
        },
      ]);

      const mixingLine = assertNonNull(
        result.data?.trackables?.edges?.find(
          e =>
            e.node?.__typename === "Location" &&
            e.node.name.value === "Mixing Line",
        ),
        "no mixing line?",
      );
      const runInstance = assertNonNull(
        mixingLine?.node?.tracking?.edges
          ?.flatMap(e => {
            if (
              e.node?.__typename === "Task" &&
              e.node.state?.__typename === "Open"
            ) {
              return e.node;
            }
            return [];
          })
          .at(0),
        "no open Run instance?",
      );
      ROOT = new Task({ id: runInstance.id });
    },
    {
      timeout: 10_000,
    },
  );

  test("start run", async () => {
    const sm = assertNonNull(await fsm(ROOT));
    const active = assertNonNull(sm.active);
    expect(active.id).toBe(ROOT.id);

    const h = await active.hash();
    const cs = await getFieldByName(active, "Comments");
    const ov = await getFieldByName(active, "Override Start Time");

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: ROOT.id,
            hash: h,
          },
          task: {
            id: active.id,
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

    expect(result.data?.advance?.root).toMatchObject({
      fsm: {
        active: {
          name: {
            value: "Run",
          },
          parent: {
            name: {
              value: "Mixing Line",
            },
          },
          state: {
            __typename: "InProgress",
          },
        },
      },
    });

    // Should have respawned.
    expect(result.data?.advance?.instantiations).toMatchObject([
      {
        node: {
          chain: {
            totalCount: 1,
          },
          name: {
            value: "Run",
          },
          parent: {
            name: {
              value: "Mixing Line",
            },
          },
          state: {
            __typename: "Open",
          },
        },
      },
    ]);
  });

  test("stale: start run (should fail)", async () => {
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeRoot: false,
        opts: {
          fsm: {
            id: ROOT.id,
            hash: await ROOT.hash(),
          },
          task: {
            id: ROOT.id,
            hash: "alienz r real",
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("start idle", async () => {
    const sm = assertNonNull(await fsm(ROOT));
    const active = assertNonNull(sm.active);
    expect(active.id).toBe(ROOT.id);

    const idle = assertNonNull(
      sm.transitions?.edges.at(1),
      "no idle transition?",
    );

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: ROOT.id,
            hash: await ROOT.hash(),
          },
          task: {
            // Legacy behavior: using `Task.id` as the transition identifier
            // rather than `Transition<Task>.id`.
            id: idle.node.id,
            hash: await idle.node.hash(),
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end idle", async () => {
    const sm = assertNonNull(await fsm(ROOT));
    const active = assertNonNull(sm.active);
    assertTaskIsNamed(active, "Idle Time", ctx);

    const desc = await getFieldByName(active, "Description");
    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: ROOT.id,
            hash: await ROOT.hash(),
          },
          task: {
            id: active.id,
            hash: await active.hash(),
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
  });

  // test("stale: production -> idle time (should fail)", async () => {
  //   const result = await execute(
  //     schema,
  //     TestRuntimeTransitionMutationDocument,
  //     {
  //       opts: {
  //         fsm: {
  //           id: FSM_I.id,
  //           hash: "fake it till you make it",
  //         },
  //         task: {
  //           id: IDLE_TIME.id,
  //           hash: "", // doesn't matter
  //         },
  //       },
  //     },
  //   );
  //   expect(result.errors).toBeFalsy();
  //   expect(result.data).toMatchSnapshot();
  // });

  test("in-progress chain/agg", async () => {
    const result = await execute(schema, TestRuntimeDetailDocument, {
      node: ROOT.id,
    });

    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        chainAgg: [
          {
            group: "Idle Time",
            value: expect.stringMatching(/[\d]+.[\d]+/),
          },
          {
            group: "Runtime",
            value: null,
          },
        ],
        chain: {
          edges: [
            {
              node: {
                name: {
                  value: "Run",
                },
                state: {
                  __typename: "InProgress",
                },
              },
            },
            {
              node: {
                name: {
                  value: "Idle Time",
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
          ],
          totalCount: 2,
        },
      },
    });
  });

  test("start downtime", async () => {
    const sm = assertNonNull(await fsm(ROOT));
    const active = assertNonNull(sm.active);
    expect(active.id).toBe(ROOT.id);

    const down = assertNonNull(
      sm.transitions?.edges.at(0),
      "no down transition?",
    );

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: ROOT.id,
            hash: await ROOT.hash(),
          },
          task: {
            id: down.node.id,
            hash: await down.node.hash(),
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end downtime", async () => {
    const sm = assertNonNull(await fsm(ROOT));
    const active = assertNonNull(sm.active);
    assertTaskIsNamed(active, "Downtime", ctx);

    const result = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        opts: {
          fsm: {
            id: ROOT.id,
            hash: await ROOT.hash(),
          },
          task: {
            id: active.id,
            hash: await active.hash(),
          },
        },
      },
    );
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchSnapshot();
  });

  test("end run", async () => {
    const sm = assertNonNull(await fsm(ROOT));
    const active = assertNonNull(sm.active);
    expect(active.id).toBe(ROOT.id);

    const h = await active.hash();
    const ov = await getFieldByName(active, "Override End Time");
    const result0 = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeChain: true,
        opts: {
          fsm: {
            id: active.id,
            hash: h,
          },
          task: {
            id: active.id,
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

    expect(result0.data?.advance?.instantiations?.length).toBe(0);
    expect(result0.data?.advance?.root?.fsm).toBeNull();
    expect(result0.data?.advance?.root?.state?.__typename).toBe("Closed");
    expect(result0.data?.advance?.root?.chain?.edges).toMatchObject([
      {
        node: {
          name: {
            value: "Run",
          },
          state: {
            __typename: "Closed",
          },
        },
      },
      {
        node: {
          name: {
            value: "Idle Time",
          },
          state: {
            __typename: "Closed",
          },
        },
      },
      {
        node: {
          name: {
            value: "Downtime",
          },
          state: {
            __typename: "Closed",
          },
        },
      },
    ]);

    // Concurrency time! This time let's try to end and already closed task.
    // FIXME: currently this will return a no_associated_fsm diagnostic which
    // is sort of a lie. Really what we want here is a hash_mismatch diagnostic
    // because that is the real root cause here.
    const result1 = await execute(
      schema,
      TestRuntimeTransitionMutationDocument,
      {
        includeRoot: false,
        opts: {
          fsm: {
            id: active.id,
            hash: h,
          },
          task: {
            id: active.id,
            hash: h,
          },
        },
      },
    );
    expect(result1.errors).toBeFalsy();
    expect(result1.data).toMatchSnapshot();
  });

  test("apply field edits retroactively", async () => {
    const cs = await getFieldByName(ROOT, "Comments");
    const result = await execute(
      schema,
      TestRuntimeApplyFieldEditsMutationDocument,
      {
        entity: ROOT.id,
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
      node: ROOT.id,
    });
    expect(result.errors).toBeFalsy();
    expect(result.data).toMatchObject({
      node: {
        chain: {
          edges: [
            {
              node: {
                name: {
                  value: "Run",
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              node: {
                name: {
                  value: "Idle Time",
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
            {
              node: {
                name: {
                  value: "Downtime",
                },
                state: {
                  __typename: "Closed",
                },
              },
            },
          ],
          totalCount: 3,
        },
        chainAgg: [
          {
            group: "Downtime",
            value: expect.any(String),
          },
          {
            group: "Idle Time",
            value: expect.any(String),
          },
          {
            group: "Runtime",
            value: "86400.000000", // overrides are taken into account
          },
        ],
        parent: {
          name: {
            value: "Mixing Line",
          },
        },
      },
    });
  });

  beforeAll(async () => {
    CUSTOMER = await createCustomer(new Date().toLocaleString(), ctx);
  });

  afterAll(async () => {
    const rows = await sql`
      select id, systagtype as status
      from public.workinstance
      inner join public.systag on workinstancestatusid = systagid
      where
          workinstancecustomerid in (
              select customerid
              from public.customer
              where customeruuid = ${CUSTOMER._id}
          )
          and workinstancestatusid = 707
      ;
    `;

    // Note that there WILL be lingering Opens. This is expected since we create
    // initial instances as part of customer create. With the recent changes to
    // support "real on-demand" this is no longer necessary and should be
    // removed, though it requires refactoring this test to not depend on
    // initial instances being available and so I am punting for now :)
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
  });
});
